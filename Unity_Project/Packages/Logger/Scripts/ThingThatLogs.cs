// Copyright (c) Breach AS. All rights reserved.

using UnityEngine;

namespace Breach.Packages.Logger
{

    public class ThingThatLogs : MonoBehaviour
    {
        private float _elapsedTime = 0;
        private int _i = 0;

        private void Update()
        {
            _elapsedTime += Time.deltaTime;
            if (!(_elapsedTime > 2f)) return;

            _elapsedTime = 0;

            Log.I($"Log after {_i} seconds");
            Log.W($"Warning after {_i} seconds.");
            Log.E($"Error after {_i} seconds.");
            _i += 2;
        }
    }


}
