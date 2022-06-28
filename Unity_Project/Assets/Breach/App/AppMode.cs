using System;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Breach.WildWaters.Apps
{
    public abstract class AppMode : IDisposable
    {
        /// <summary>
        /// Initializes the app mode. Must be called for the app mode to work. Must be called after constructor has been completed.
        /// </summary>
        public abstract void Initialize();

        /// <summary>
        /// Should be called to perform all setup that is required to happen after the correct level has been loaded
        /// </summary>
        protected abstract void SetupMode();

        public abstract void Dispose();
        protected void LoadScene(string level, Action callback)
        {
            SceneManager.LoadSceneAsync(level, LoadSceneMode.Single)
                .completed 
                    += (AsyncOperation operation) => callback?.Invoke();
        }
    }
}
