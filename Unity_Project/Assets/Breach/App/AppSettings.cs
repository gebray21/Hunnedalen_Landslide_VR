using UnityEngine;

namespace Breach.WildWaters.Apps
{
    [CreateAssetMenu(fileName = "AppSettings", menuName = "Breach/App/Settings", order = 1)]
    public class AppSettings : ScriptableObject
    {
        [Header("Configurable Game Rules")]

        [Tooltip("Defines which mode to play the game in")]
        public GameModeSelector GameModeSelector;

        [Tooltip("If true, the player will be dragged by the water-stream")]
        public bool PlayerAffectedByWater;

        [Space]
        [Header("Player Controllers")]
        public GameObject XRPlayer;
        public GameObject EditorPlayer;
        public string LobbyScene;
        public SceneData SceneData;
        
        [Space]
        [Header("UI")]
        public GameObject LobbyMenu;
        public GameObject SimulationUIPrefab;
    }
}
