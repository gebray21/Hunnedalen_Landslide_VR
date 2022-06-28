using System.Collections;
using System;
using UnityEngine;


/// <summary>
/// Reads the points from the data.
/// Splits the points into multiple children each of which is a PointCloud object with a portion of the points.
/// </summary>
public class PointCloudGenerator : MonoBehaviour {

    const int MAX_NUMBER_OF_POINTS_PER_MESH = 65536 / 3;    // Maximum number of vertices allowed per single mesh...


    private GameObject mainPointCloudParent;
    private GameObject[] pointClouds;                   // Maintained reference to the generated children (point cloud objects)...

    private string meshName;
    private static Vector3[,] data;                         // Points read from the data file..
    private static Vector3[,] normals;                      // Normals read from the data file..
    private static Vector3[,] nextNormals;                  // Next frame's normals read from the data file..
    private static Vector2[,] nextDataOffsets, vels, nextVels;
    private Material materialToUse;

    private int numPoints = 0;                          // Total number of points from the data source...
    private int numDivisions = 0;                       // Number of point clouds that will be generated...
    private int numPointsPerCloud = 0;                  // Number of points per generated point cloud...
    private int numRowsInLastCloud = 0;               // Number of points in the last cloud
    private int dataOffset = 0;


    public IEnumerator prepareAndCreate(MapData info, MapData nextInfo, Matrix lowerBoundsMat, string myName, Material material, Vector3 scaleMultiplyer, Action<GameObject> onCreatedCallback = null) {
        yield return prepareScannedData(info, nextInfo, lowerBoundsMat, myName, material, scaleMultiplyer);
        yield return createPointClouds(onCreatedCallback);
        Destroy(gameObject);
    }

    private IEnumerator prepareScannedData(MapData info, MapData nextInfo, Matrix lowerBoundsMat, string myName, Material material, Vector3 scaleMultiplyer) {
        var mat = info.Elevation;
        var n = mat.N;
        var m = mat.M;

        var nextMat = nextInfo?.Elevation;
        if (data is null || data.GetLength(0) != n || data.GetLength(1) != m) {
            data = new Vector3[n, m];

            if (info.Normal != null)
                normals = new Vector3[n, m];

            if (nextMat != null) {
                nextDataOffsets = new Vector2[n, m];
                vels = new Vector2[n, m];
                nextVels = new Vector2[n, m];
                nextNormals = new Vector3[n, m];
            }
        }

        GameObject PointCloudParent = new GameObject();
        PointCloudParent.transform.parent = transform.parent;
        PointCloudParent.transform.rotation = Quaternion.Euler(new Vector3(-90.0f, 0.0f, 0.0f));
        PointCloudParent.name = meshName = myName;
        mainPointCloudParent = PointCloudParent;
        materialToUse = material;

        var loop = GenFunctions.ParallelForAsync(0, mat.N, poolSize: 100, i => {
            for (int j = 0; j < mat.M; j++) {
                var lowerBound = lowerBoundsMat != null ? lowerBoundsMat[i, j] : -1;
                if (mat[i, j] < -999.0f) { // this frame is bad
                    var d = new Vector3(i, j, lowerBound);
                    d.Scale(scaleMultiplyer);
                    if (nextDataOffsets != null) {
                        if (nextMat[i, j] < -999f) { // ... (a) and next frame is bad as well
                            nextDataOffsets[i, j] = new Vector2(0, 0);
                            nextVels[i, j] = new Vector2 (0, 0);
                            nextNormals[i, j] = Vector3.up;
                        } else { // ... or (b) next frame is good
                            nextDataOffsets[i, j] = new Vector2(nextMat[i, j] - lowerBound, 0);
                            var nextVel = new Vector2(nextInfo.Velx[i, j], nextInfo.Vely[i, j]);
                            nextVels[i, j] = nextVel.sqrMagnitude > 1000 ? Vector2.zero : nextVel;
                            nextNormals[i, j] = nextInfo.Normal[i, j];
                        }
                        vels[i, j] = new Vector2 (0, 0);
                    }
                    data[i, j] = d;
                    normals[i, j] = Vector3.forward;
                } else {
                    var pos = new Vector3(i, j, mat[i, j]);
                    pos.Scale(scaleMultiplyer);
                    data[i, j] = pos;
                    normals[i, j] = info.Normal[i, j];
                    if (nextMat != null) {
                        if (nextMat[i, j] < -999f) { // dont animate to -9999
                            nextDataOffsets[i, j] = new Vector2(lowerBound - mat[i, j], 0);
                            nextVels[i, j] = new Vector2 (0, 0);
                            nextNormals[i, j] = Vector3.up;
                        } else {
                            nextDataOffsets[i, j] = new Vector2(nextMat[i, j] - mat[i, j], 0);
                            var nextVel = new Vector2(nextInfo.Velx[i, j], nextInfo.Vely[i, j]);
                            nextVels[i, j] = nextVel.sqrMagnitude > 1000 ? Vector2.zero : nextVel;
                            nextNormals[i, j] = nextInfo.Normal[i, j];
                        }
                        var vel = new Vector2(info.Velx[i, j], info.Vely[i, j]);
                        vels[i, j] = vel.sqrMagnitude > 1000 ? Vector2.zero : vel;
                    }
                }

            }
        });

        yield return new WaitUntil(() => loop.IsCompleted);

        dataOffset = mat.M;
        numPoints = data.Length;
        if (numPoints <= 0) {
            print("Error: failed to read the points from file");
        }

        // Calculate the appropriate division of points
        int rowsPerDivision = MAX_NUMBER_OF_POINTS_PER_MESH / mat.M - 1;
        numDivisions = mat.N / rowsPerDivision + 1; // +1 for the remainder
        numRowsInLastCloud = mat.N - ((numDivisions-1) * rowsPerDivision);
        numPointsPerCloud = rowsPerDivision * mat.M;
    }

    class DivisionData {
        public Vector3[] positions;
        public Vector3[] ns, nextNs;

        public Vector2[] nextFrameOffsets;
        public Vector2[] vel, nextVel;

    }

    public IEnumerator createPointClouds(Action<GameObject> onCreatedCallback = null) {

        if (numDivisions != 0) {
            pointClouds = new GameObject[numDivisions];

            PointCloud.SetDivisionsCount(numDivisions);

            DivisionData[] divisions = new DivisionData[numDivisions];

            // generate point cloud objects, each with the same number of points
            var loop = GenFunctions.ParallelForAsync(0, numDivisions, poolSize: 3, i => {
                int offset = i * numPointsPerCloud;
                DivisionData div = divisions[i] = new DivisionData();

                // generate a subset of data for this point cloud
                int numPoints;
                if (i == numDivisions - 1)
                    numPoints = numRowsInLastCloud * dataOffset;
                else
                    numPoints = numPointsPerCloud + dataOffset;

                div.positions = new Vector3[numPoints];
                div.ns = new Vector3[numPoints];
                div.nextNs = new Vector3[numPoints];

                if (nextDataOffsets != null) {
                    div.nextFrameOffsets = new Vector2[numPoints];
                    div.vel = new Vector2[numPoints];
                    div.nextVel = new Vector2[numPoints];
                }

                for(int j = 0; j < numPoints; j++) {
                    var n = (offset + j) / data.GetLength(1);
                    var m = (offset + j) % data.GetLength(1);

                    div.positions[j] = data[n, m];
                    div.ns[j] = normals[n, m];
                    div.nextNs[j] = nextNormals[n, m];
                    if (div.nextFrameOffsets != null) {
                        div.nextFrameOffsets[j] = nextDataOffsets[n, m];
                        div.vel[j] = vels[n, m];
                        div.nextVel[j] = nextVels[n, m];
                    }
                }
            });

            yield return new WaitUntil(() => loop.IsCompleted);

            for (int i = 0; i < numDivisions; i++) {
                GameObject newObj = new GameObject("Mesh_" + i.ToString());

                if (mainPointCloudParent == null)
                    yield break;

                newObj.transform.SetParent(mainPointCloudParent.transform, false);

                newObj.AddComponent<PointCloud>().CreateSimpleMesh(divisions[i].positions, divisions[i].ns, divisions[i].nextNs, divisions[i].nextFrameOffsets, divisions[i].vel, divisions[i].nextVel, dataOffset);
                newObj.GetComponent<MeshRenderer>().material = materialToUse;

                pointClouds[i] = newObj;

                yield return null;
            }

            onCreatedCallback?.Invoke(mainPointCloudParent);
        }
    }

}

