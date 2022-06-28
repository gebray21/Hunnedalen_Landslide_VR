using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


[CustomEditor(typeof(TerrainImportTool))]
public class TerrainImportToolEditor : Editor
{
    SerializedProperty inputFilePath, outputFilePath;

    SerializedProperty resolution, nodata, width, length, maxHeight;

    SerializedProperty targetTerrainObject, transposeTerrain, mirrorX, mirrorY;


    private ASCReaderData loadedASC = null;
    private void OnEnable() {
        inputFilePath = serializedObject.FindProperty("InputFile");
        outputFilePath = serializedObject.FindProperty("OutputFile");

        resolution = serializedObject.FindProperty("Resolution");
        nodata = serializedObject.FindProperty("NoDataValue");
        width = serializedObject.FindProperty("Width");
        length = serializedObject.FindProperty("Length");
        maxHeight = serializedObject.FindProperty("MaximumHeight");

        targetTerrainObject = serializedObject.FindProperty("TargetTerrain");
        transposeTerrain = serializedObject.FindProperty("TransposeTerrain");
        mirrorX = serializedObject.FindProperty("MirrorX");
        mirrorY = serializedObject.FindProperty("MirrorY");
    }

    public override void OnInspectorGUI() {
        serializedObject.Update();

        // Input file
        EditorGUILayout.LabelField("Input File", EditorStyles.boldLabel);
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.PropertyField(inputFilePath);
        if (GUILayout.Button("Browse...", GUILayout.Width(100))) {
            inputFilePath.stringValue = EditorUtility.OpenFilePanel("Import ASC terrain", Application.streamingAssetsPath, "asc");
        }
        EditorGUILayout.EndHorizontal();

        EditorGUI.BeginDisabledGroup(string.IsNullOrEmpty(inputFilePath.stringValue));
        if (GUILayout.Button("Load")) {
            loadedASC = ASCReader.getDepthPoints(inputFilePath.stringValue);

            if (loadedASC is not null) {
                initSettingsFromASC();
                outputFilePath.stringValue = inputFilePath.stringValue.Replace(".asc", ".raw");
            }
        }
        EditorGUI.EndDisabledGroup();

        // Settings for import
        EditorGUILayout.Separator();
        EditorGUILayout.LabelField("Import Settings", EditorStyles.boldLabel);
        EditorGUILayout.PropertyField(resolution);
        EditorGUILayout.PropertyField(nodata);
        EditorGUILayout.PropertyField(width);
        EditorGUILayout.PropertyField(length);
        EditorGUILayout.PropertyField(maxHeight);

        // Importing to target terrain
        EditorGUILayout.Separator();
        EditorGUILayout.LabelField("Terrain Object", EditorStyles.boldLabel);
        EditorGUILayout.PropertyField(targetTerrainObject);
        EditorGUILayout.PropertyField(transposeTerrain);
        EditorGUILayout.PropertyField(mirrorX);
        EditorGUILayout.PropertyField(mirrorY);

        EditorGUI.BeginDisabledGroup(loadedASC is null);
        if (GUILayout.Button("Import")) {
            var terrain = targetTerrainObject.objectReferenceValue as Terrain;
            if (terrain is null) {
                Debug.Log("No terrain game object set, creating a new one");
                // TODO: Create terrain
            }


            // scale to use of all the available space in the terrain
            terrain.terrainData.heightmapResolution = resolution.intValue + 1;
            var scaled = Matrix.ScaleBilinear(loadedASC.data, resolution.intValue, resolution.intValue);

            // terrain needs elevation values in [0,1] range
            float c = 1f / maxHeight.floatValue;
            scaled.Map(f => Mathf.Max(0, c*f));

            // sometimes the coordinate system used by the terrain are different than the rest of the project
            if (transposeTerrain.boolValue)
                scaled = Matrix.MatrixTranspose(scaled);

            // sometimes the coordinate system needs to be mirrored along an axis
            if (mirrorX.boolValue) {
                var copy = new Matrix(scaled);
                for (int i = 0; i < scaled.N; i++)
                    for (int j = 0; j < scaled.M; j++)
                        scaled[scaled.N - i - 1, j] = copy[i, j];
            }

            if (mirrorY.boolValue) {
                var copy = new Matrix(scaled);
                for (int i = 0; i < scaled.N; i++)
                    for (int j = 0; j < scaled.M; j++)
                        scaled[i, scaled.M - j -1] = copy[i, j];
            }

            terrain.terrainData.SetHeights(0, 0, scaled.RawData);
            terrain.terrainData.size = new Vector3(width.floatValue, maxHeight.floatValue, length.floatValue);
            terrain.transform.localPosition = new Vector3(0f, 0f, -length.floatValue);
        }
        EditorGUI.EndDisabledGroup();

        serializedObject.ApplyModifiedProperties();
    }

    private void initSettingsFromASC() {
        resolution.intValue = Mathf.Max(Mathf.NextPowerOfTwo(loadedASC.data.M), Mathf.NextPowerOfTwo(loadedASC.data.N));
        width.floatValue = loadedASC.cellSize * loadedASC.data.N;
        length.floatValue = loadedASC.cellSize * loadedASC.data.M;

        float maxVal = float.MinValue;
        for (int i = 0; i < loadedASC.data.N; i++)
            for (int j = 0; j < loadedASC.data.M; j++)
                maxVal = Mathf.Max(maxVal, loadedASC.data[i, j]);
        maxHeight.floatValue = maxVal;
    }
}
