// Copyright (c) Breach AS. All rights reserved.

using UnityEngine;

namespace Breach.Packages.Logger.Samples
{

    // By adding this override, we say that this class should output warnings and above
    [Log(LogLevel.Warning)]
    public class LogAttributesClassAndMethodSample : MonoBehaviour
    {
        // Then we can also add this override to specify that this method should output info and above
        [Log(LogLevel.Info)]
        private void Awake()
        {
            var scheme = new ColorScheme(Color.cyan, Color.magenta, Color.white, Color.yellow, Color.red);

            Log.Initialize(new UnityConsoleLogger(scheme, LogLevel.Info));

            Log.I("Log Method Attribute Awake");
            Log.W("Log Method Attribute Awake");
            Log.E("Log Method Attribute Awake");
        }

        // Then we can also add this override to specify that this method should output info and above
        [Log(LogLevel.Info)]
        private void OnEnable()
        {
            Log.I("Log Method Attribute OnEnable");
            Log.W("Log Method Attribute OnEnable");
            Log.E("Log Method Attribute OnEnable");
        }

        // Since there's no override attribute here, so this should output warning and above (due to class-level)
        private void Start()
        {
            Log.I("Log Method Attribute Start");
            Log.W("Log Method Attribute Start");
            Log.E("Log Method Attribute Start");
        }
    }

}
