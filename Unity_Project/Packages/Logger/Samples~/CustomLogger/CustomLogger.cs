// Copyright (c) Breach AS. All rights reserved.

using UnityEngine;
using TMPro;

namespace Breach.Packages.Logger.Samples
{

    /// <summary>
    /// This is a custom logger that instantiates Cubes in the scene for each time
    /// Log.X is called. The logger counts the amount og Infos, Warnings and Errors and
    /// uses it to place the Cubes higher and higher up.
    /// Info, Warning and Error have different colors, so we change the color of the material also.
    /// </summary>
    public class CustomLogger : LoggerBase
    {
        private readonly GameObject _item;

        private static readonly int Color1 = Shader.PropertyToID("_Color");

        private int _infos;
        private int _warnings;
        private int _errors;

        public CustomLogger(GameObject prefab, ColorScheme scheme, LogLevel level) : base(scheme, level)
        {
            _item = prefab;
        }

        protected override void LogInfo(ref LogEntry entry)
        {
            var go = Instantiate(entry);

            ChangeText(go, entry);
            ChangeColor(go);

            _infos++;
        }

        protected override void LogWarning(ref LogEntry entry)
        {
            var go = Instantiate(entry);

            ChangeText(go, entry);
            ChangeColor(go);

            _warnings++;
        }

        protected override void LogError(ref LogEntry entry)
        {
            var go = Instantiate(entry);

            ChangeText(go, entry);
            ChangeColor(go);

            _errors++;
        }

        private GameObject Instantiate(LogEntry entry)
        {
            var go = GameObject.Instantiate(_item);
            var xPosition = LogLevelToXPosition(entry.Level);
            var yPosition = LogLevelToHeight(entry.Level);
            go.transform.position = new Vector3(xPosition, yPosition, 0);
            return go;
        }

        private static int LogLevelToXPosition(LogLevel level)
        {
            switch (level)
            {
                case LogLevel.Info:
                    return -1;

                case LogLevel.Warning:
                    return 0;

                case LogLevel.Error:
                    return 1;

                default:
                    return 0;
            }
        }

        private int LogLevelToHeight(LogLevel level)
        {
            switch (level)
            {
                case LogLevel.Info:
                    return _infos;

                case LogLevel.Warning:
                    return _warnings;

                case LogLevel.Error:
                    return _errors;

                default:
                    return 0;
            }
        }

        private static void ChangeText(GameObject go, LogEntry entry)
        {
            go.GetComponentInChildren<TextMeshPro>().text = entry.Msg;
        }

        private void ChangeColor(GameObject go)
        {
            var renderer = go.GetComponent<Renderer>();

            var block = new MaterialPropertyBlock();
            renderer.GetPropertyBlock(block);
            block.SetColor(Color1, MessageColor);
            renderer.SetPropertyBlock(block);
        }

    }

}
