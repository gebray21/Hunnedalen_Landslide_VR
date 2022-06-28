// Copyright (c) Breach AS. All rights reserved.

using UnityEngine;

namespace Breach.Packages.Logger.Samples
{

    /// <summary>
    /// This is a direct implementation of the BaseLogger.
    /// This is a Scriptable Object!
    /// </summary>
    [CreateAssetMenu(fileName = "CustomLogger", menuName = "Logger/Custom Logger", order = 1)]
    public class CustomLoggerConfigurator : ColoredLoggerConfigurator
    {
        [SerializeField] private GameObject loggerItemPrefab;

        /// <summary>
        /// Creates its own instance of LoggerBase of type CustomLogger.
        /// </summary>
        /// <returns></returns>
        protected override LoggerBase CreateLogger()
        {
            return new CustomLogger(loggerItemPrefab, ColorScheme, logLevel);
        }
    }

}
