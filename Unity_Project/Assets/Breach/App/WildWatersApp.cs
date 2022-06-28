using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.XR;

namespace Breach.WildWaters.Apps
{
    public class WildWatersApp : App, IWildWatersSubscriber
    {
        public WildWatersApp(AppSettings settings) : base(settings)
        {
            Log.I("");

            if (CurrentSceneInSceneData && Application.isEditor)
            {
                // Start playing Simulation mode in the existing scene, to speed up iteration
                if (!HasHMDAttached) CreateEditorSimulation();
                else CreateSimulationGame(null);
            }
            else CreateLobby();
        }

        /// <summary>
        /// Disposes the old mode and sets the new
        /// </summary>
        /// <param name="newMode"></param>
        protected void ChangeMode(AppMode newMode)
        {
            Log.I("Change mode");
            this.mode?.Dispose();
            this.mode = newMode;
            this.mode.Initialize();
        }

        #region AppMode Creation
        public void CreateLobby()
        {
            Log.I("Creating new lobby game");
            var currentScene = SceneManager.GetActiveScene().name;
            ChangeMode(new LobbyMode(this as IWildWatersSubscriber, currentScene != settings.LobbyScene ? settings.LobbyScene : null, settings.XRPlayer, settings.LobbyMenu));
        }

        public void CreateSimulationGame(string level)
        {
            Log.I("Creating new sandbox game in mode: ");
            ChangeMode(new SimulationMode(this as IWildWatersSubscriber, level, settings.XRPlayer, settings.SimulationUIPrefab, settings.GameModeSelector, settings.PlayerAffectedByWater));
        }

        public void CreateEditorSimulation()
        {
            Log.I($"Create editor with mode: {settings.GameModeSelector}");
            ChangeMode(new SimulationMode(this as IWildWatersSubscriber, null, settings.EditorPlayer, settings.SimulationUIPrefab, settings.GameModeSelector, settings.PlayerAffectedByWater));
        }

        #endregion

        private bool HasHMDAttached
        {
            get 
            {
                var xrDisplaySubsystems = new List<XRDisplaySubsystem>();
                SubsystemManager.GetInstances(xrDisplaySubsystems);
                return xrDisplaySubsystems.Count > 0;
            }
        }

        private bool CurrentSceneInSceneData
        {
            get
            {
                var currentScene = SceneManager.GetActiveScene().name;
                return settings.SceneData.Data.Any(e => e.Name == currentScene);
            }
        }
    }
}
