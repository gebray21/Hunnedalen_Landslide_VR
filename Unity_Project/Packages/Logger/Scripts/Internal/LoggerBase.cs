// Copyright (c) Breach AS. All rights reserved.

using System;
using UnityEngine;

namespace Breach.Packages.Logger
{

    public abstract class LoggerBase
    {
        public readonly LogLevel DefaultLogLevel;

        protected ColorScheme Scheme;

        private readonly bool _usesScheme;
        private Color _specifiedColor;
        protected string MessageColorAsHtml => $"#{ColorUtility.ToHtmlStringRGB(_specifiedColor)}";
        protected Color MessageColor => _specifiedColor;

        internal bool Enabled { get; set; } = true;


        protected LoggerBase(ColorScheme scheme, LogLevel level = LogLevel.Error)
        {
            DefaultLogLevel = level;
            Scheme = scheme;
            _usesScheme = true;
        }

        protected LoggerBase(LogLevel level = LogLevel.Error)
        {
            DefaultLogLevel = level;
            _usesScheme = false;
        }

        /// <summary>
        /// Running method when Log.I() is called.
        /// Own implementation of a logger can be done in this virtual.
        /// The base of this method makes sure colors are set correctly in the "entry" based on provided color in Log.I() and the ColorScheme.
        /// Don't include base.LogInfo() if you want to implement it on your own.
        /// Include base.LogInfo() if you trust your coloring, but want a different logging behaviour.
        /// </summary>
        /// <param name="entry"> The created LogEntry </param>
        protected abstract void LogInfo(ref LogEntry entry);

        internal void LogInfoOnEnabled(ref LogEntry entry)
        {
            if (!Enabled) return;
            SetMessageColorFrom(ref entry);
            LogInfo(ref entry);
        }

        /// <summary>
        /// Running method when Log.W() is called.
        /// Own implementation of a logger can be done in this virtual.
        /// The base of this method makes sure colors are set correctly in the "entry" based on provided color in Log.W() and the ColorScheme.
        /// Don't include base.LogInfo() if you want to implement it on your own.
        /// Include base.LogWarning() if you trust your coloring, but want a different logging behaviour.
        /// </summary>
        /// <param name="entry"> The created LogEntry </param>
        protected abstract void LogWarning(ref LogEntry entry);

        internal void LogWarningOnEnabled(ref LogEntry entry)
        {
            if (!Enabled) return;
            SetMessageColorFrom(ref entry);
            LogWarning(ref entry);
        }

        /// <summary>
        /// Running method when Log.E() is called.
        /// Own implementation of a logger can be done in this virtual.
        /// The base of this method makes sure colors are set correctly in the "entry" based on provided color in Log.E() and the ColorScheme.
        /// Don't include base.LogInfo() if you want to implement it on your own.
        /// Include base.LogError() if you trust your coloring, but want a different logging behaviour.
        /// </summary>
        /// <param name="entry"> The created LogEntry </param>
        protected abstract void LogError(ref LogEntry entry);

        internal void LogErrorOnEnabled(ref LogEntry entry)
        {
            if (!Enabled) return;
            SetMessageColorFrom(ref entry);
            LogError(ref entry);
        }


        /// <summary>
        /// Sets the entry's message color based on provided color in Log.X() and the provided color scheme.
        /// Log.X() with color (overrides)  >  ColorScheme (overrides)  >  default
        /// </summary>
        /// <param name="entry"></param>
        /// <exception cref="ArgumentOutOfRangeException"></exception>
        private void SetMessageColorFrom(ref LogEntry entry)
        {
            // If message color has value, it means color was specified in Log.X(). We don't wanna mess with that color.
            if (entry.MessageColor.HasValue)
            {
                _specifiedColor = entry.MessageColor.Value;
                return;
            }

            // However, if it was not specified, we need to check our scheme and set the message color to their respective defaults.
            if (_usesScheme)
            {
                // C# 8.0 Supports switch expression. That came in 2020.2.0
#if UNITY_2020_2_OR_NEWER
                _specifiedColor = entry.Level switch
                {
                    LogLevel.Info => Scheme.InfoColor,
                    LogLevel.Warning => Scheme.WarningColor,
                    LogLevel.Error => Scheme.ErrorColor,
                    _ => throw new ArgumentOutOfRangeException()
                };
#else
                switch (entry.Level)
                {
                    case LogLevel.Info:
                        _specifiedColor = Scheme.InfoColor;
                        break;

                    case LogLevel.Warning:
                        _specifiedColor = Scheme.WarningColor;
                        break;

                    case LogLevel.Error:
                        _specifiedColor = Scheme.ErrorColor;
                        break;

                    default:
                        throw new ArgumentOutOfRangeException();
                }
#endif
            }
        }
    }

}
