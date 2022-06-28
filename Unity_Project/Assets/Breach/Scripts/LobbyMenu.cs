using System;
using System.Collections;
using System.Collections.Generic;
using Breach.WildWaters.Apps;
using UnityEngine;

namespace Breach.WildWaters
{
    public class LobbyMenu : MonoBehaviour
    {
        public event Action<string> NewGame;
        private static string sceneDataPath = "Assets/Breach/Scenes/SceneDataObject.asset";
        private SceneMetadata selectedLevel;
        [SerializeField] private GameObject sceneSelectButton;
        [SerializeField] private RectTransform sceneSelectList;
        [SerializeField] private SceneData sceneDataList;
        private LobbyMode mode;

        public void SetAppMode(LobbyMode mode)
        {
            this.mode = mode;
        }

        void Start()
        {
            PopulateLevelList();
        }

        private void PopulateLevelList()
        {
            foreach (var data in sceneDataList.Data)
            {
                var buttonGo = Instantiate(sceneSelectButton, sceneSelectList);
                var selectButton = buttonGo.GetComponent<SceneSelectButton>();
                selectButton.Setup(this, data);
            }
            selectedLevel = sceneDataList.Data[0];
        }

        public void SelectLevel(SceneMetadata data)
        {
            // Debug.Log($"Level {data.Name} selected");
            selectedLevel = data;
        }

        public void LoadSelectedLevel()
        {
            NewGame?.Invoke(selectedLevel.Path);
        }
    }
}