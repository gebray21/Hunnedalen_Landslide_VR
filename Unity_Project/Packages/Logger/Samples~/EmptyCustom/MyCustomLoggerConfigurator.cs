// Copyright (c) Breach AS. All rights reserved.

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Breach.Packages.Logger.Samples
{

    /// <summary>
    /// This is a scriptable object, so we need to create it somehow.
    /// 
    /// After it is created, and colors are defined:
    /// Place a MasterLogger.cs in the Scene somewhere and
    /// drag your created ScriptableObject of this class into the logger Array.
    /// </summary>
    [CreateAssetMenu(fileName = "MyCustomLogger", menuName = "Logger/My Custom Logger", order = 1)]
    public class MyCustomLoggerConfigurator : ColoredLoggerConfigurator
    {

        protected override LoggerBase CreateLogger()
        {
            // We have a ColorScheme and a default logLevel to work with from the parent class.
            return new MyCustomLogger(ColorScheme, logLevel);
        }
    }

}
