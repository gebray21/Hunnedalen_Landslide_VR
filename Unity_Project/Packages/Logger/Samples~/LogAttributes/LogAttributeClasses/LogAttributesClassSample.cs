// Copyright (c) Breach AS. All rights reserved.

using UnityEngine;

namespace Breach.Packages.Logger.Samples
{

    // The global log level is LogLevel.Error, which means only Errors should be output to the log by default
    // By adding this tag to the class we can override that, and have all Log.X in this class output warning AND errors
    [Log(LogLevel.Warning)]
    public class LogAttributesClassSample : MonoBehaviour
    {
        private void Awake()
        {
            var scheme = new ColorScheme(Color.cyan, Color.magenta, Color.white, Color.yellow, Color.red);

            Log.Initialize(new UnityConsoleLogger(scheme, LogLevel.Info));

            Log.I("Log Class Attribute Awake");
            Log.W("Log Class Attribute Awake");
            Log.E("Log Class Attribute Awake");
        }

        private void OnEnable()
        {
            Log.I("Log Class Attribute OnEnable");
            Log.W("Log Class Attribute OnEnable");
            Log.E("Log Class Attribute OnEnable");
        }

        private void Start()
        {
            Log.I("Log Class Attribute Start");
            Log.W("Log Class Attribute Start");
            Log.E("Log Class Attribute Start");
        }
    }

}
