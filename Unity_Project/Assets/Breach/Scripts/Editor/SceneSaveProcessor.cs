using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Text.RegularExpressions;
using System.IO;
using System.Linq;

namespace Breach.WildWaters
{
    public class SceneSaveProcessor : AssetModificationProcessor
    {
        private static string sceneDataPath = "Assets/Breach/Scenes/SceneDataObject.asset";
        private static string location = "Assets/Breach/Scenes/DynamicScenes/";
        // private static Regex folderPattern = new Regex(@"(?<=Assets\/Breach\/Scenes\/DynamicScenes\/)(.*)\.unity(?!=\.meta)$");
        private static Regex folderPattern = new Regex(@"(Assets\/Breach\/Scenes\/DynamicScenes\/.*\.unity)");
        private static Regex sceneFromMeta = new Regex(@"(.*\.unity)(?=\.meta$)");

        #region File Callbacks

        private static AssetMoveResult OnWillMoveAsset(string sourcePath, string destinationPath)
        {
            // NOTE: Renaming a scene will trigger as a move event
            // and thus these should be separate if's and not if / else

            // Moved a scene out of the folder
            if (TouchedSceneFolder(sourcePath)) SceneRemoved(sourcePath);
            
            // moved a scene into of scene folder
            if (TouchedSceneFolder(destinationPath)) SceneAdded(destinationPath);

            return AssetMoveResult.DidNotMove;
        }

        static void OnWillCreateAsset(string path)
        {
            // Only unity.meta gets this callback thus we need to extract only the scene path
            if (TouchedSceneFolder(path))
            {
                if (IsMetaFile(path))
                {
                    SceneAdded(GetSceneFromMeta(path));
                }
            }
        }

        private static AssetDeleteResult OnWillDeleteAsset(string path, RemoveAssetOptions options)
        {
            if (TouchedSceneFolder(path)) SceneRemoved(path);

            return AssetDeleteResult.DidNotDelete;
        }

        #endregion

        #region Helpers

        /// <summary>
        /// Returns true if the path matches the folder-pattern
        /// </summary>
        /// <param name="path"></param>
        /// 
        private static bool TouchedSceneFolder(string path) => folderPattern.Matches(path).Any();
        private static SceneMetadata GetMetadata(string path)
        {
            return new SceneMetadata() { Name = Path.GetFileNameWithoutExtension(path), Path = path };
        }

        private static string GetSceneFromMeta(string path)
        {
            var mathces = sceneFromMeta.Matches(path);
            if (mathces.Count <= 0) return "";
            else return mathces[0].Value;
        }

        private static bool IsMetaFile(string path) => sceneFromMeta.Match(path).Success;

        /// <summary>
        /// Creates or loads the scene-asset data
        /// </summary>
        private static SceneData GetSceneData()
        {
            var so = AssetDatabase.LoadAssetAtPath<SceneData>(sceneDataPath);
            if (so == null)
            {
                // Debug.Log("No asset found, creating");
                so = ScriptableObject.CreateInstance<SceneData>();
                so.Data = new List<SceneMetadata>();
                AssetDatabase.CreateAsset(so, sceneDataPath);
            }
            return so;
        }

        #endregion

        #region Scene Data Object
        // This is so that we can get scenes to an asset that we can read from during runtime
        // needed for dynamic level select list

        private static void SceneAdded(string scenePath)
        {
            // Log.I($"Scene added: {scenePath}");

            var sceneAsset = GetSceneData();
            var metadata = GetMetadata(scenePath);
            
            sceneAsset.Data.Add(metadata);
            AddToBuildSetting(metadata);

            EditorUtility.SetDirty(sceneAsset);
            AssetDatabase.SaveAssets();
        }

        private static void SceneRemoved(string scenePath)
        {
            // Debug.Log("Scene removed");
            var sceneAsset = GetSceneData();
            var metadata = GetMetadata(scenePath);
            
            var match = sceneAsset.Data.FirstOrDefault(e => e.Path == metadata.Path);
            if (match == null)
            {
                Debug.LogError("Found no match");
                return;
            }

            sceneAsset.Data.Remove(match);
            RemoveFromBuildSettings(match);

            EditorUtility.SetDirty(sceneAsset);
            AssetDatabase.SaveAssets();
        }

        #endregion

        #region Editor Build Settings

        private static void AddToBuildSetting(SceneMetadata scene)
        {
            // Debug.Log($"Adding {scene.Path} to build settings");
            var currentBuildScenes = EditorBuildSettings.scenes.ToList();
            if (!currentBuildScenes.Any(e => e.path == scene.Path))
            {
                currentBuildScenes.Add(new EditorBuildSettingsScene(scene.Path, true));
            }
            EditorBuildSettings.scenes = currentBuildScenes.ToArray();
        }

        private static void RemoveFromBuildSettings(SceneMetadata scene)
        {
            // Debug.Log($"Removing {scene.Path} from build settings");
            EditorBuildSettings.scenes = EditorBuildSettings.scenes.Where(e => e.path != scene.Path).ToArray();
        }

        #endregion
    }
}
