// Copyright (c) Breach AS. All rights reserved.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Reflection;
using UnityEngine;
using Object = UnityEngine.Object;
using Breach.Packages.Logger;


namespace Breach
{

    public static class Log
    {
        private static bool _initialized;
        private static bool _selfInitialized;

        private static List<LoggerBase> CustomLogs { get; set; }

        private static bool _includeFileData = false;


        #region Constructors

        public static void Initialize(LoggerBase[] loggerBases, bool fileData = false)
        {
            CustomLogs = loggerBases.ToList();
            _initialized = true;
            _includeFileData = fileData;
        }

        public static void Initialize(LoggerBase loggerBase, bool fileData = false)
        {
            CustomLogs = new[] { loggerBase }.ToList();
            _initialized = true;
            _includeFileData = fileData;
        }

        private static void SelfInitialize()
        {
            if (_selfInitialized) return;

            CustomLogs = new List<LoggerBase> { new UnityConsoleLogger(LogLevel.Info) };
            _selfInitialized = true;
            _includeFileData = false;
        }

        #endregion


        #region Public Methods

        #region Log.X(object msg)

        public static void I(object msgRaw, Color? color = null)
        {
            //if (!_initialized) throw new InvalidOperationException("Breach.Log must be initialized before working");
            if (!_initialized)
                SelfInitialize();

            var entry = BuildLogEntry(msgRaw, LogLevel.Info, color);
            foreach (var iLog in CustomLogs)
            {
                if (!ShouldLog(entry, iLog)) continue;
                iLog.LogInfoOnEnabled(ref entry);
            }
        }

        public static void W(object msgRaw, Color? color = null)
        {
            //if (!_initialized) throw new InvalidOperationException("Breach.Log must be initialized before working");
            if (!_initialized)
                SelfInitialize();

            var entry = BuildLogEntry(msgRaw, LogLevel.Warning, color: color);
            foreach (var iLog in CustomLogs)
            {
                if (!ShouldLog(entry, iLog)) continue;
                iLog.LogWarningOnEnabled(ref entry);
            }
        }

        public static void E(object msgRaw, Color? color = null)
        {
            //if (!_initialized) throw new InvalidOperationException("Breach.Log must be initialized before working");
            if (!_initialized)
                SelfInitialize();

            var entry = BuildLogEntry(msgRaw, LogLevel.Error, color: color);
            foreach (var iLog in CustomLogs)
            {
                if (!ShouldLog(entry, iLog)) continue;
                iLog.LogErrorOnEnabled(ref entry);
            }
        }

        #endregion

        #region Log.X(object msg, Object context)

        public static void I(object msgRaw, Object context, Color? color = null)
        {
            if (!_initialized) throw new InvalidOperationException("Breach.Log must be initialized before working");

            var entry = BuildLogEntry(msgRaw, LogLevel.Info, color, context);
            foreach (var iLog in CustomLogs)
            {
                if (!ShouldLog(entry, iLog)) continue;
                iLog.LogInfoOnEnabled(ref entry);
            }
        }

        public static void W(object msgRaw, Object context, Color? color = null)
        {
            if (!_initialized) throw new InvalidOperationException("Breach.Log must be initialized before working");

            var entry = BuildLogEntry(msgRaw, LogLevel.Warning, color, context);
            foreach (var iLog in CustomLogs)
            {
                if (!ShouldLog(entry, iLog)) continue;
                iLog.LogWarningOnEnabled(ref entry);
            }
        }

        public static void E(object msgRaw, Object context, Color? color = null)
        {
            if (!_initialized) throw new InvalidOperationException("Breach.Log must be initialized before working");

            var entry = BuildLogEntry(msgRaw, LogLevel.Error, color, context);
            foreach (var iLog in CustomLogs)
            {
                if (!ShouldLog(entry, iLog)) continue;
                iLog.LogErrorOnEnabled(ref entry);
            }
        }

        #endregion

        #endregion

        #region Private Methods

        public static string SecondsToTimeString()
        {
            return SecondsToTimeString(Time.time);
        }

        public static string ColorToString(Color c)
        {
            return "#" + ColorUtility.ToHtmlStringRGB(c);
        }

        private static string SecondsToTimeString(float secs)
        {
            var minutes = (int)secs / 60;
            var seconds = (int)secs - 60 * minutes;
            return $"{minutes:00}:{seconds:00}";
        }

        /// <summary>
        /// Checks if this log-entry should be logged based on its reference level
        /// </summary>
        /// <param name="reference">Reference to check against</param>
        /// <param name="entry">Created entry for log message.</param>
        /// <returns></returns>
        private static bool ShouldLog(LogEntry entry, LoggerBase loggerBase)
        {
            var classLevel = entry.InvokerClass.GetCustomAttribute<LogAttribute>()?.Level;
            var methodLevel = entry.InvokerMethod.GetCustomAttribute<LogAttribute>()?.Level;

            if (classLevel.HasValue && methodLevel.HasValue)
            {
                return ReferencePassing(entry.Level, loggerBase.DefaultLogLevel, classLevel.Value,
                    methodLevel.Value);
            }
            else if (classLevel.HasValue && !methodLevel.HasValue)
            {
                return ReferencePassing(entry.Level, loggerBase.DefaultLogLevel, classLevel.Value);
            }
            else if (!classLevel.HasValue && methodLevel.HasValue)
            {
                return ReferencePassing(entry.Level, loggerBase.DefaultLogLevel, methodLevel.Value);
            }
            else
            {
                return ReferencePassing(entry.Level, loggerBase.DefaultLogLevel);
            }
        }

        /// <summary>
        /// Compares a reference to a set log-level to see if the reference passes and should be logged
        /// </summary>
        /// <param name="reference">Log-level of the message</param>
        /// <param name="topLevel">Level of the highest controlling entity</param>
        /// <returns>True if passing</returns>
        private static bool ReferencePassing(LogLevel reference, LogLevel topLevel)
        {
            if (reference >= topLevel) return true;
            return false;
        }

        private static bool ReferencePassing(LogLevel reference, LogLevel topLevel, LogLevel bottomLevel)
        {
            if (reference >= topLevel) return true;
            if (reference >= bottomLevel) return true;
            return false;
        }

        private static bool ReferencePassing(LogLevel reference, LogLevel topLevel, LogLevel midLevel,
            LogLevel bottomLevel)
        {
            if (reference >= topLevel) return true;
            if (reference >= midLevel) return true;
            if (reference >= bottomLevel) return true;
            return false;
        }

        private static LogEntry BuildLogEntry(object messageObject, LogLevel level, Color? color, Object context = null)
        {
            // Grabs the grand-parent of the stack trace which _should_ be the method where Log.X() was invoked
            // FIXME: This approach does not work with Unity Coroutines as the coroutine will be invoked deep withing a tree of runner-methods
            var invokerFrame = new StackTrace(_includeFileData).GetFrame(2);
            return new LogEntry(invokerFrame, messageObject, level, color, context);
        }

        #endregion

    }

}
