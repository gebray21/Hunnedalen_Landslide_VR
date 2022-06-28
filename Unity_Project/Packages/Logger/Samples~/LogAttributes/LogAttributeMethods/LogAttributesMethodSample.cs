// Copyright (c) Breach AS. All rights reserved.

using UnityEngine;

namespace Breach.Packages.Logger.Samples
{

    public class LogAttributesMethodSample : MonoBehaviour
    {
        // The global log level is LogLevel.Error, which means only Errors should be output to the log by default
        // By adding this tag to the method we can override that, and have this method print warning and above
        [Log(LogLevel.Warning)]
        private void Awake()
        {
            var scheme = new ColorScheme(Color.cyan, Color.magenta, Color.white, Color.yellow, Color.red);

            Log.Initialize(new UnityConsoleLogger(scheme, LogLevel.Info));

            Log.I("My message");
            Log.W("My message");
            Log.E("My message");

            Log.I(this);
            Log.I(gameObject);
            Log.I(transform);
        }

        // In this method we can override the global to ouput info and above
        [Log(LogLevel.Info)]
        private void OnEnable()
        {
            Log.I("Log Method Attribute OnEnable");
            Log.W("Log Method Attribute OnEnable");
            Log.E("Log Method Attribute OnEnable");
        }

        // Since there's no override attribute here, only the error should output (due to global level)
        private void Start()
        {
            Log.I("Log Method Attribute Start");
            Log.W("Log Method Attribute Start");
            Log.E("Log Method Attribute Start");
        }
    }

}
