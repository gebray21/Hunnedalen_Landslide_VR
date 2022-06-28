using System.Linq;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;

public static class RequiredLayers
{

    private const string MENU_ITEM = "RealSnowAndRainEffect/Sync Layers";
    private const string ALREADY_ASKED_KEY = "AssetAddLayersAsked";
    private static readonly string[] requiredLayers = new[] {
        "water",
        "ground",
        "wind",
    };

    private static bool AlreadyAsked
    {
        get { return PlayerPrefs.GetInt(ALREADY_ASKED_KEY, 0) == 1; }
        set { PlayerPrefs.SetInt(ALREADY_ASKED_KEY, value ? 1 : 0); }
    }

    [InitializeOnLoadMethod]
    private static void Init()
    {
        if (AlreadyAsked) return;

        var containsAll = requiredLayers.All(l => LayerAlreadyExists(l));

        if (containsAll) return; // Nothing to do

        var layersFormatted = string.Join(", ", requiredLayers);

        if (EditorUtility.DisplayDialog("Adding New Layers",
                string.Format("Would you like to add the following layers ({0}) to this project?", layersFormatted) +
                " You will not be able to use Colliding effect without these layers.", "Yes", "No"))
        {
            SyncLayers();
        }
        else
        {
            AlreadyAsked = true;
        }
    }

    [MenuItem(MENU_ITEM)]
    private static void SyncLayers()
    {
        foreach (var layer in requiredLayers)
            AddLayer(layer);

        EditorUtility.DisplayDialog(
            "Layers were added",
            "The requested layers were added to project. You can now use colliding effect",
            "OK"
        );
    }

    public static void AddLayer(string layerName)
    {
        if (LayerAlreadyExists(layerName))
        {
            return; // Already present
        }

        var fileAssets = AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/TagManager.asset");

        if (fileAssets == null)
        {
            Debug.LogError("Tag manager file not found");
            return;
        }

        var tagManager = fileAssets.FirstOrDefault();

        if (!tagManager)
        {
            Debug.LogError("Tag manager file not found");
            return;
        }

        var serializedObject = new SerializedObject(tagManager);
        var layers = serializedObject.FindProperty("layers");

        for (int i = 0; i < layers.arraySize; i++)
        {
            if (string.IsNullOrWhiteSpace(layers.GetArrayElementAtIndex(i).stringValue))
            {
                layers.GetArrayElementAtIndex(i).stringValue = layerName;
                serializedObject.ApplyModifiedProperties();
                serializedObject.Update();
                if (layers.GetArrayElementAtIndex(i).stringValue == layerName)
                {
                    return; // To avoid unity locked layer
                }
            }
        }
    }

    public static bool LayerAlreadyExists(string layerName)
    {
        return InternalEditorUtility.layers.Contains(layerName);
    }

}