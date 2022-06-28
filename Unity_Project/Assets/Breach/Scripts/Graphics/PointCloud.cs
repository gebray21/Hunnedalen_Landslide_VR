//#define MEASURE_MESH_CREATION

using UnityEngine;
using UnityEngine.Rendering;

#if MEASURE_MESH_CREATION
using D = System.Diagnostics;
#endif

/// <summary>
/// Creates a mesh where each vertex is a point, and the color for each vertex is proportional to its signal strength.
/// </summary>
[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class PointCloud : MonoBehaviour {

    private static Mesh[] meshes;
    private static int meshCounter;


    public static void SetDivisionsCount(int i) {
        if (meshes is null || meshes.Length < 2*i) {
            meshes = new Mesh[2 * i];
            meshCounter = 0;
        }
    }


    public void CreateSimpleMesh(Vector3[] points, Vector3[] normals, Vector3[] nextNormals, Vector2[] offsets, Vector2[] vel, Vector2[] nextVel, int dataOffset) {
    #if MEASURE_MESH_CREATION
        var clock = new D.Stopwatch();
        clock.Start();
    #endif

        GetComponent<MeshRenderer>().shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;

        var zeroFlags = MeshUpdateFlags.DontNotifyMeshUsers | MeshUpdateFlags.DontValidateIndices | MeshUpdateFlags.DontResetBoneBounds | MeshUpdateFlags.DontRecalculateBounds;

        var mesh = GetComponent<MeshFilter>().mesh = getBufferedMesh();
        mesh.Clear(keepVertexLayout: true);

        mesh.SetVertices(points, 0, points.Length, zeroFlags);

        var (indices, indicesLength) = SetTriangles(points, offsets, dataOffset);
        mesh.SetIndices(indices, 0, indicesLength, MeshTopology.Triangles, 0, calculateBounds: false);

        if (normals != null)
            mesh.SetNormals(normals, 0, normals.Length, zeroFlags);
        else
            mesh.RecalculateNormals();

        if (offsets != null)
            mesh.SetUVs(0, offsets, 0, offsets.Length, zeroFlags);

        if (vel != null)
            mesh.SetUVs(1, vel, 0, vel.Length, zeroFlags);

        if (nextVel != null)
            mesh.SetUVs(2, nextVel, 0, nextVel.Length, zeroFlags);

        if (nextNormals != null)
            mesh.SetUVs(3, nextNormals, 0, nextNormals.Length, zeroFlags);

        // now recalculate bounds & notify users
        mesh.RecalculateBounds();
        mesh.MarkModified();

        // Make sure data gets uploaded to GPU this frame
        mesh.UploadMeshData(markNoLongerReadable: false);

    #if MEASURE_MESH_CREATION
        Debug.Log("Mesh creation elapsed time: " + clock.ElapsedMilliseconds + "ms");
    #endif
    }

    public void CreateQuadMesh(Vector3[] points, int dataOffset, GameObject wQ) {
        int dataLength = points.Length;
        int repetitions = (dataLength / dataOffset) - 1;
        //int[] triangles = new int[repetitions * dataOffset * 6];

        for (int v = 0; v < (repetitions * dataOffset) - 1; v++) {
            if (points[v].z != 0.0f) {

                GameObject temp = Instantiate(wQ, transform);
                Mesh myMesh = temp.GetComponent<MeshFilter>().mesh;

                Vector3[] vPoses = new Vector3[4];

                vPoses[0] = points[v];
                vPoses[1] = points[dataOffset + v];
                vPoses[2] = points[v + 1];
                vPoses[3] = points[dataOffset + v + 1];

                myMesh.vertices = vPoses;

            }
        }
    }

    private static int[] indicesBuffer;

    private (int[], int) SetTriangles(Vector3[] points, Vector2[] offsets, int dataOffset) {
        int repetitions = (points.Length / dataOffset) - 1;
        var length = repetitions * dataOffset * 6;
        var triangles = indicesBuffer;
        if (triangles is null || triangles.Length < length)
            indicesBuffer = triangles = new int[length];

        for (int i = 0, v = 0; v < (repetitions * dataOffset) - 1; i += 6, v++) {
            if(points[v].z > -1f) {
                if ((v+1) % dataOffset != 0) {
                    triangles[i] = v;
                    triangles[i + 1] = triangles[i + 4] = dataOffset + v;
                    triangles[i + 2] = triangles[i + 3] = v + 1;
                    triangles[i + 5] = dataOffset + v + 1;
                }
            }
        }

        return (triangles, length);
    }

    private Color[] SetMyColors(int vertexCount, Color theColor) {
        Color[] colors = new Color[vertexCount];
        for (int i = 0; i < vertexCount; ++i) {
            colors[i] = theColor;
        }
        return colors;
    }

    void OnDestroy() {
    }


    private Mesh getBufferedMesh() {
        var i = meshCounter++ % meshes.Length;

        if (meshes[i] != null)
            return meshes[i];
        else
            return meshes[i] = createMesh();
    }

    private Mesh createMesh() {
        var m = new Mesh();
        m.name = "FlowMesh";
        m.indexFormat = IndexFormat.UInt16;
        m.MarkDynamic();
        return m;
    }
}
