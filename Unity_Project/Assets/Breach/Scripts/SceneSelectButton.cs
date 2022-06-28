using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

namespace Breach.WildWaters
{
    [RequireComponent(typeof(TextMeshProUGUI))]
    public class SceneSelectButton : MonoBehaviour
    {
        private LobbyMenu menu;
        private SceneMetadata data;

        private TextMeshProUGUI textComponent;
        public void SelectScene()
        {
            menu.SelectLevel(data);
        }

        private void Awake()
        {
            textComponent = GetComponentInChildren<TextMeshProUGUI>();
            if (textComponent == null) Debug.LogError("No text component found");
        }

        // private void Start()
        // {
        //     textComponent.text = data.Name;
        // }

        public void Setup(LobbyMenu parent, SceneMetadata data)
        {
            menu = parent;
            this.data = data;
            textComponent.text = data.Name;
        }
    }
}
