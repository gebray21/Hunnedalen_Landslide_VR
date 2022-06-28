using System;
using System.Collections.Generic;
using System.Linq;
using Breach.WildWaters.Player;
using Breach.WildWaters.UI;
using UnityEngine;
using Object = UnityEngine.Object;

namespace Breach.WildWaters.Apps
{
    public class SimulationMode : WildWatersMode, IPlaybackControls
    {
        private SimulationManager simulationManager;
        private GameObject simulationUIPrefab;
        private GameModeSelector gameMode;
        private bool playerAffectedByWater;

        public SimulationMode(
            IWildWatersSubscriber subscriber, string scene, GameObject playerPrefab,
            GameObject simulationUIPrefab, GameModeSelector gameMode, bool playerAffectByWater
        ) : base(subscriber, scene, playerPrefab)
        {
            this.simulationUIPrefab = simulationUIPrefab;
            this.gameMode = gameMode;
            this.playerAffectedByWater = playerAffectByWater;
        }

        protected override void SetupMode()
        {
            Log.I($"Setup mode with mode: {this.gameMode}");
            base.SetupMode();

            simulationManager = Object.FindObjectOfType<SimulationManager>();
            if (simulationManager == null) throw new InvalidOperationException("No water SimulationManager in the scene. Application will not work correctly. Please add the WaterSimulation-prefab to the scene");

            if (gameMode == GameModeSelector.Simulation)
            {
                // Do editor specific setup if player is EditorPlayer
                if (player is EditorPlayer editorPlayer)
                {
                    editorPlayer.SetSimulationController(this as IPlaybackControls);
                }

                // Setup Simulation control panel UI
                var simUI = GameObject.Instantiate(simulationUIPrefab, player.transform).GetComponent<SimulationControlsUI>();
                simUI.transform.localPosition = new Vector3(0f, 0f, 1.2f);
                simUI.SetSimulationController(this as IPlaybackControls);
                simUI.SetVisible(false);
                player.SetUIControl(simUI);

                // Enabled player effects
                GameObject.FindObjectOfType<PlayerEffects>(includeInactive: true).gameObject.SetActive(true);
            }

            if (playerAffectedByWater)
            {
                if (player is XRPlayerController xrPlayer)
                {
                    // TODO: Add watersubject to XRPlayer
                    // FIXME: We need to upgrade waterSubject to be able to use Capsule-Collider
                    // var playerWaterSubject = player.gameObject.AddComponent<WaterSubject>();
                    // playerWaterSubject.SetManager(graphicsManager);
                }
            }

            Play();
        }

        public override void Dispose() { }

        #region SimulationControls

        public void Play()
        {
            Log.I("Playing");
            simulationManager.SetPlaying(true);
        }

        public void Pause()
        {
            Log.I("Pausing");
            simulationManager.SetPlaying(false);
        }

        public void Stop()
        {
            Log.I("Stopping");
            Pause();
            Reset();
        }

        private void Reset()
        {
            Log.I("Resetting");
            simulationManager.AnimationFrame = 1;
        }

        #endregion

        private void ExitToLobby() => subscriber.CreateLobby();
    }
}