using System;
using Breach.WildWaters.Player;
using UnityEngine;

namespace Breach.WildWaters.Apps
{
    public class WildWatersMode : AppMode
    {
        protected IWildWatersSubscriber subscriber;
        private GameObject playerPrefab;
        private string scene;
        protected BasePlayerController player;

        public WildWatersMode(IWildWatersSubscriber subscriber, string scene, GameObject playerPrefab)
        {
            this.subscriber = subscriber;
            this.playerPrefab = playerPrefab;
            this.scene = scene;
        }

        public override void Initialize()
        {
            if (String.IsNullOrEmpty(scene)) SetupMode();
            else LoadScene(scene, SetupMode);
        }

        protected override void SetupMode()
        {
            // Setup player
            player = SpawnPlayer();
        }

        public override void Dispose() { }

        /// <summary>
        /// Spawns a player in the world
        /// </summary>
        /// <returns>Reference to the spawned player</returns>
        protected BasePlayerController SpawnPlayer()
        {
            // Fetch player spawn
            var spawnPoint = GameObject.FindObjectOfType<PlayerSpawn>();
            if (spawnPoint == null) Log.W("No PlayerSpawn in scene, spawning player at origin instead");
            
            // Fetch or create player if not exist
            return GameObject.FindObjectOfType<BasePlayerController>()
                ?? GameObject.Instantiate(playerPrefab, 
                    spawnPoint ? spawnPoint.transform.position : Vector3.zero, 
                    spawnPoint ? spawnPoint.transform.rotation : Quaternion.identity
                ).GetComponent<BasePlayerController>();
        }
    }
}
