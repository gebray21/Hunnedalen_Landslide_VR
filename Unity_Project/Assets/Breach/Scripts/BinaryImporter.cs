using System;
using System.Globalization;
using System.Threading;
using System.Text.RegularExpressions;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;
using System.Collections.Concurrent;
using UnityEngine;

sealed class FindTypeBinder : SerializationBinder
{
    public override Type BindToType(string assemblyName, string typeName)
    {
        Type typeToDeserialize = null;

        if (typeName.Contains("Matrix"))
            typeToDeserialize = typeof(Matrix);
        else if (typeName.Contains("MapData"))
            typeToDeserialize = typeof(MapData);
        else if (typeName.Contains("MapInfo"))
            typeToDeserialize = typeof(MapInfo);
        else
            Debug.Log("Failed to set deserialization assembly for " + typeName);

        return typeToDeserialize;
    }
}

[Serializable]
public class MapData
{
    public Matrix Elevation;
    public Matrix Velx;
    public Matrix Vely;
    public byte[] EncodedNormal = null;
    public Vector3[,] Normal = null;
}
[Serializable]
public class MapInfo
{
    public float XCenter;
    public float YCenter;
    public float cellSize;
    public float noValue;
    public MapData myMapData;

    public MapInfo() {
    }

    public MapInfo(MapData theData, float xcenter, float ycenter, float cellsize, float novalue)
    {
        XCenter = xcenter;
        YCenter = ycenter;
        cellSize = cellsize;
        noValue = novalue;
        myMapData = theData;
    }

    /// <summary>
    /// Loads the frame from a binary input file. Decodes all normals in the process.
    /// </summary>
    public static MapInfo Load(string filepath)
    {
        var fmt = new BinaryFormatter();
        fmt.Binder = new FindTypeBinder();
        var stream = new FileStream(filepath, FileMode.Open);
        try {
            MapInfo m = (MapInfo)fmt.Deserialize(stream);
            m.DecodeNormals();
            return m;
        } finally {
            stream.Close();
        }
    }

    /// <summary>
    /// Makes sure we have an array to store the encoded normals ready.
    /// </summary>
    public void EnsureEncodedNormalArray() {
        if (myMapData.EncodedNormal is null || myMapData.EncodedNormal.Length == 0)
            myMapData.EncodedNormal = new byte[3 * myMapData.Elevation.N * myMapData.Elevation.M];
    }

    /// <summary>
    /// Given an index into the data and a normal, encode and store it.
    /// </summary>
    /// <param name="i">Index i</param>
    /// <param name="j">Index j</param>
    /// <param name="n">The normal to store</param>
    public void EncodeNormal(int i, int j, Vector3 n) {
        var (r, g, b) = GenFunctions.EncodeNormalizedVector(n);
        myMapData.EncodedNormal[3*i*myMapData.Elevation.M + 3*j] = r;
        myMapData.EncodedNormal[3*i*myMapData.Elevation.M + 3*j + 1] = g;
        myMapData.EncodedNormal[3*i*myMapData.Elevation.M + 3*j + 2] = b;
    }

    /// <summary>
    /// Needs to have data already loaded into the `EncodedNormal` array.
    /// Decodes all the normals, allocates the `Normal` array and writes the decoded normals into it.
    /// </summary>
    public void DecodeNormals() {
        myMapData.Normal = new Vector3[myMapData.Elevation.N, myMapData.Elevation.M];
        for (int i = 0; i < myMapData.Elevation.N; i++)
            for (int j = 0; j < myMapData.Elevation.M; j++) {
                int ix = 3*i*myMapData.Elevation.M + 3*j;
                myMapData.Normal[i,j] = GenFunctions.DecodeVector3(myMapData.EncodedNormal[ix], myMapData.EncodedNormal[ix+1], myMapData.EncodedNormal[ix+2]);
            }
    }
}

public static class BinaryImporter
{
    private static string dataPath;
    private static string dataId;

    private static CancellationTokenSource Cts = null;
    private static BlockingCollection<int> loadingQueue = null;

    private static ConcurrentDictionary<(string, int), MapInfo> frames = new ConcurrentDictionary<(string, int), MapInfo>();

    private static int? numFrames = null;

    // ****** Interface ******
    // Path inside StreamingAssets/SceneData
    public static void SetDataPath(string path) {
        StopThread();
        dataId = path;
        dataPath = Path.Combine(Application.streamingAssetsPath, $"SceneData/{path}");
        StartThread();
    }

    public static void StartThread() {
        Cts = new CancellationTokenSource();
        loadingQueue = new BlockingCollection<int>(new ConcurrentQueue<int>());
        new Thread(new ThreadStart(() => loadingThread(Cts.Token))).Start();
    }

    public static void StopThread() =>
        Cts?.Cancel();

    public static void EnqueueFrame(int frame) {
        if (!frames.ContainsKey((dataId, frame)))
            loadingQueue.Add(frame);
    }

    public static MapInfo GetFrame(int i) {
        if (frames.ContainsKey((dataId, i)))
            return frames[(dataId, i)];
        else {
            //Debug.LogWarning("Requested a frame that hasn't been loaded yet!");
            return null;
        }
    }

    public static double GetFileIndex(string f, string ext) {
        Regex namePattern = new Regex(@"_(?<time>[0-9]+(.[0-9]+)?)." + ext);
        Match m = namePattern.Match(f);
        return Convert.ToDouble(m.Groups["time"].Value, CultureInfo.InvariantCulture);
    }

    public static int GetNumFrames() {
        if (numFrames.HasValue) return numFrames.Value;

        string[] allFiles = System.IO.Directory.GetFiles(dataPath);

        int maxFrame = 0;
        foreach (string f in allFiles) {
            if (!f.Contains(".meta"))
                maxFrame = Math.Max(maxFrame, (int)GetFileIndex(f, "bin"));
        }

        numFrames = maxFrame;
        return numFrames.Value;
    }

    // ****** Private functinality (runs on a different thread) ******
    private static void loadingThread(CancellationToken ct) {
        try {
            while(!loadingQueue.IsAddingCompleted)
                if (loadingQueue.TryTake(out int frameToLoad, -1, ct))
                    if (!frames.ContainsKey((dataId, frameToLoad)))
                        LoadMapData(frameToLoad);
        } catch (OperationCanceledException e) {
            Debug.Log($"Loader thread canceled: {e.Message}");
        } catch (Exception e) {
            Debug.LogError($"Error in loader thread: {e.Message}");
        }
    }

    private static void LoadMapData(int frame) {
        //Debug.Log($"(A) Loading frame {dataId}/{frame}");

        string currentDataId = new string(dataId);
        string[] allFiles = System.IO.Directory.GetFiles(dataPath);
        string fileToLoad = Array.Find(allFiles, f => GetFileIndex(f, "bin") == frame && !f.Contains(".meta"));

        if (string.IsNullOrEmpty(fileToLoad)) {
            // Debug.LogError($"Failed to find requested frame! dataPath: {dataPath}, frame: {frame}");
            Debug.LogWarning($"Failed to find requested frame! you may reac to the last frame. dataPath: {dataPath}, is your lastframe: {frame} ?");
            return;
        }

        //Debug.Log($"(B) Loading frame {currentDataId}/{fileToLoad}");

        frames[(currentDataId, frame)] = MapInfo.Load(fileToLoad);
    }
}
