// Copyright (c) Breach AS. All rights reserved.

using UnityEngine;

namespace Breach.Packages.Logger.Samples
{

    [CreateAssetMenu(fileName = "UnityConsoleLogger", menuName = "Logger/Unity Console Logger", order = 1)]
    [Log(LogLevel.Info)]
    public class UnityLoggerConfigurator : ColoredLoggerConfigurator
    {
        /// <summary>
        /// Creates its own instance of a LoggerBase object of type UnityLogger.
        /// </summary>
        /// <returns></returns>
        protected override LoggerBase CreateLogger()
        {
            return new UnityConsoleLogger(ColorScheme, logLevel);
        }

    }

}
