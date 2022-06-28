using System.IO;
using UnityEngine;
using UnityEditor;

// [CustomEditor(typeof(PreProcessingScript))]
public class PreProcessingEditor : EditorWindow
{
    [MenuItem("Window/Breach/Pre Processing")]
    public static void ShowWindow()
    {
        EditorWindow.GetWindow<PreProcessingEditor>();
    }

    private string sourcePath = null, destPath = null;

    private readonly string opDir = Path.Combine(Application.streamingAssetsPath, "SceneData");

    private void OnGUI()
    {
        // DrawDefaultInspector();
        // PreProcessingScript script = (PreProcessingScript) target;

        if (GUILayout.Button("Select folder to process")) {
            sourcePath = EditorUtility.OpenFolderPanel("Select folder containing 3 folders with ASC source files for elevation, velocity x, and velocity y", opDir, "");
        }

        if (GUILayout.Button("Select destination folder")) {
            destPath = EditorUtility.OpenFolderPanel("Select folder where processed data will be stored", opDir, "");
        }

        GUILayout.Label("Source path: " + sourcePath);
        GUILayout.Label("Destination path: " + destPath);

        if (sourcePath == null || sourcePath.Length == 0 || destPath == null || destPath.Length == 0)
            GUI.enabled = false;

        if (GUILayout.Button("Process")) {
            GUILayout.Label("Please wait, processing...");
            PreProcessing.PreProcess_Data(sourcePath, destPath);
        }

        GUI.enabled = true;
    }
}
