// Copyright (c) Breach AS. All rights reserved.

using System;
using System.Collections;
using UnityEngine;

namespace Breach.Packages.Logger.Samples
{

    /// <summary>
    /// This is the actual Logger that will log stuff for you.
    /// It has access to the LogEntry <see cref="LogEntry"/> where all information about the logged thing exist.
    /// This class is created by <see cref="MyCustomLoggerConfigurator"/>.
    ///
    /// Because this class inherits from <seealso cref="LoggerBase"/> it HAS to implement the methods <see cref="LogInfo"/>,
    /// <see cref="LogWarning"/> and <see cref="LogError"/>. This is where you can make magic happen.
    /// </summary>
    public class MyCustomLogger : LoggerBase
    {
        public MyCustomLogger(ColorScheme scheme, LogLevel level = LogLevel.Error) : base(scheme, level) { }

        protected override void LogInfo(ref LogEntry entry)
        {

            // Here you can implement your own logging behaviour.
            // Take a look at what the LogEntry class gives you access to.

            // So for example. A Unity console logger would do something like this:
            Debug.Log(entry.Msg, entry.Context);
        }

        protected override void LogWarning(ref LogEntry entry)
        {
            // Here you can implement your own logging behaviour.
            // Take a look at what the LogEntry class gives you access to.

            // So for example. A Unity console logger would do something like this:
            Debug.LogWarning(entry.Msg, entry.Context);
        }

        protected override void LogError(ref LogEntry entry)
        {
            // Here you can implement your own logging behaviour.
            // Take a look at what the LogEntry class gives you access to.

            // So for example. A Unity console logger would do something like this:
            Debug.LogError(entry.Msg, entry.Context);
        }
    }

}
