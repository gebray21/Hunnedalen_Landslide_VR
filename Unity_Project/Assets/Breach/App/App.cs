using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UnityEngine;

namespace Breach.WildWaters.Apps
{
    public class App : IQuittableApp
    {
        protected AppMode mode;
        protected AppSettings settings { get; private set; }
        public App(AppSettings settings)
        {
            Log.I("");
            this.settings = settings;
        }

        // TODO: Save Game
        // TODO: Load Game

        public virtual void QuitApp() => Application.Quit();
    }
}
