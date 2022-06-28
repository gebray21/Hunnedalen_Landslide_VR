// Copyright (c) Breach AS. All rights reserved.

using UnityEngine;
using UnityEngine.Serialization;

namespace Breach.Packages.Logger
{

    /// <summary>
    /// This class makes sure to get all components on its GO and register them with the Log class.
    /// </summary>
    // TODO: Execution Order on this class.
    public class MasterLogger : MonoBehaviour
    {
        [SerializeField] private LoggerConfigurator[] loggerConfigs;

        private void Awake()
        {
            // Array for when using Log.Initialize(LoggerBase[]).
            var loggers = new LoggerBase[loggerConfigs.Length];

            for (var i = 0; i < loggerConfigs.Length; i++)
            {
                // Force them to create their loggers. We put that in our array.
                loggers[i] = loggerConfigs[i].InitializeLogger();
            }

            // We Initialize the Log class with all our created loggers.
            Log.Initialize(loggers);
        }

    }

}
