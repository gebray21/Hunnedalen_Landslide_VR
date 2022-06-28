using System;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;

using UnityEngine;

public static class PreProcessing {
    private static List<string> allElevationFiles;
    private static List<string> allVelocityXFiles;
    private static List<string> allVelocityYFiles;

    private static ASCReaderData Terrain;
    private static Vector2 TerrainScale;

    private static Texture2D BufferTex;

    private static SemaphoreSlim IOSemaphore = new SemaphoreSlim(1);


    public static void PreProcess_Data(string sourcePath, string destPath) {

        allElevationFiles = Directory.GetFiles(Path.Combine(sourcePath, "Elevation"), "*.*", SearchOption.TopDirectoryOnly)
               .Where(file => new string[] { ".asc" }
               .Contains(Path.GetExtension(file)))
               .ToList();

        allVelocityXFiles = Directory.GetFiles(Path.Combine(sourcePath, "Velocity_X"), "*.*", SearchOption.TopDirectoryOnly)
            .Where(file => new string[] { ".asc" }
            .Contains(Path.GetExtension(file)))
            .ToList();

        allVelocityYFiles = Directory.GetFiles(Path.Combine(sourcePath, "Velocity_Y"), "*.*", SearchOption.TopDirectoryOnly)
            .Where(file => new string[] { ".asc" }
            .Contains(Path.GetExtension(file)))
            .ToList();

        if (allElevationFiles.Count == allVelocityXFiles.Count && allElevationFiles.Count == allVelocityYFiles.Count) {
            var terrainFile = Directory.GetFiles(sourcePath, "*.asc", SearchOption.TopDirectoryOnly)
                .Where(file => file.Contains("terrain", StringComparison.InvariantCultureIgnoreCase))
                .FirstOrDefault();
            if (string.IsNullOrEmpty(terrainFile)) {
                Debug.LogError("Failed to find terrain file! Make sure there is a file named `Terrain.*\\.asc` in the source directory.");
                return;
            }
            Terrain = ASCReader.getDataPoints(IOSemaphore, terrainFile);


            SortData();

            Parallel.For(0, allElevationFiles.Count, i => {
                var myMapDatas = new MapInfo();
                myMapDatas.myMapData = new MapData();
                LoadData(myMapDatas, i);

                ProcessCurrentData(myMapDatas);

                IOSemaphore.Wait();
                WriteData(myMapDatas, destPath, i);
                IOSemaphore.Release();
            });

        }

    }


    private static void WriteData(MapInfo myMapDatas, string destPath, int index) {
        var myFormatter = new BinaryFormatter();
        using (Stream writer = new FileStream(Path.Combine(destPath, "Frame_" + index.ToString() + ".bin"), FileMode.Create, FileAccess.Write)) {
            myFormatter.Serialize(writer, myMapDatas);
        }
    }

    private static void LoadData(MapInfo myMapDatas, int i) {
        var el = ASCReader.getDataPoints(IOSemaphore, allElevationFiles[i]);
        var velX = ASCReader.getDataPoints(IOSemaphore, allVelocityXFiles[i]);
        var velY = ASCReader.getDataPoints(IOSemaphore, allVelocityYFiles[i]);

        myMapDatas.cellSize = el.cellSize;
        myMapDatas.noValue = el.noValue;
        myMapDatas.XCenter = el.xCenter;
        myMapDatas.YCenter = el.yCenter;

        myMapDatas.myMapData.Elevation = el.data;
        myMapDatas.myMapData.Velx = velX.data;
        myMapDatas.myMapData.Vely = velY.data;

        TerrainScale = new Vector2(Terrain.data.N, Terrain.data.M) / new Vector2(el.data.N, el.data.M);
    }

    private static void SortData() {
        allElevationFiles.Sort((a, b) => BinaryImporter.GetFileIndex(a, "asc").CompareTo(BinaryImporter.GetFileIndex(b, "asc")));
        allVelocityXFiles.Sort((a, b) => BinaryImporter.GetFileIndex(a, "asc").CompareTo(BinaryImporter.GetFileIndex(b, "asc")));
        allVelocityYFiles.Sort((a, b) => BinaryImporter.GetFileIndex(a, "asc").CompareTo(BinaryImporter.GetFileIndex(b, "asc")));
    }

    private static void ProcessCurrentData(MapInfo myMapDatas) {

        // Extrapolate elevation points near the surface to minimize sharp clipping into the terrain
        myMapDatas.myMapData.Elevation = Matrix.MapC(myMapDatas.myMapData.Elevation, (i, j, x) => {
            if (Mathf.Approximately(x, myMapDatas.noValue)) {
                var nh = getNeighbourhood(myMapDatas.myMapData.Elevation, i, j, 5);
                nh = nh.Where(x => !Mathf.Approximately(x, myMapDatas.noValue)).ToList();
                //if (nh.Count >= 3) {
                //    Plane p = new Plane(nh[0], nh[1], nh[2]); // make sure these are not on a line in XY plane
                if (nh.Count > 0) {
                    var tEl = Terrain.data.Sample(TerrainScale.x*i, TerrainScale.y*j);
                    var exterpolatedEl = nh.Aggregate((x,y) => 0.5f*(x+y));
                    return Mathf.Min(exterpolatedEl, tEl);
                }
            }

            return x;
        });

        // Calculate normals and encode them into 8 bits per component.
        var el = myMapDatas.myMapData.Elevation;
        var s = myMapDatas.cellSize;
        myMapDatas.EnsureEncodedNormalArray();
        for (int i = 0; i < el.N; i++) {
            for (int j = 0; j < el.M; j++) {
                if (i == 0 || j == 0 || i == el.N-1 || j == el.M-1) {
                    myMapDatas.EncodeNormal(i, j, Vector3.forward);
                } else {
                    Vector3 here = new Vector3(s*i, s*j, el[i, j]);
                    Vector3[] nbs = new Vector3[] {
                        new Vector3(s*(i+1), s*j, el[i+1, j]),
                        new Vector3(s*i, s*(j+1), el[i, j+1]),
                        new Vector3(s*(i-1), s*j, el[i-1, j]),
                        new Vector3(s*i, s*(j-1), el[i, j-1])
                    };
                    Plane[] nbPlanes = new Plane[] {
                        new Plane(here, nbs[0], nbs[1]),
                        new Plane(here, nbs[1], nbs[2]),
                        new Plane(here, nbs[2], nbs[3]),
                        new Plane(here, nbs[3], nbs[0])
                    };
                    Vector3 normal = nbPlanes.Aggregate(Vector3.zero, (acc, p) => acc + p.normal).normalized;
                    myMapDatas.EncodeNormal(i, j, normal);
                }
            }
        }

        // If we have no velocity data, we should set it to 0
        myMapDatas.myMapData.Velx.Map(f => Mathf.Approximately(f, myMapDatas.noValue) ? 0f : f);
        myMapDatas.myMapData.Vely.Map(f => Mathf.Approximately(f, myMapDatas.noValue) ? 0f : f);
    }

    private static List<float> getNeighbourhood(Matrix m, int x, int y, int size = 3) {
        var s2 = size/2;
        x = Mathf.Clamp(x, s2, m.N-s2);
        y = Mathf.Clamp(y, s2, m.M-s2);

        var res = new List<float>();
        for (int i = x-s2; i < x+s2; i++)
            for (int j = y-s2; j < y+s2; j++)
                if (i != x || j != y)
                    res.Add(m[i, j]);

        return res;
    }
}
