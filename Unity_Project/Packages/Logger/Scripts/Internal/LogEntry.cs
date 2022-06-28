// Copyright (c) Breach AS. All rights reserved.

using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using UnityEngine;
using Object = UnityEngine.Object;

namespace Breach.Packages.Logger
{

    /// <summary>
    /// Logger item data struct.
    /// </summary>
    public readonly struct LogEntry
    {
        public LogEntry(StackFrame invokerFrame, object messageObject, LogLevel level, Color? color, Object context = null)
        {
            InvokerMethod = invokerFrame.GetMethod();
            InvokerClass = invokerFrame.GetMethod().DeclaringType;
            Msg = messageObject.ToString();
            RawObject = messageObject;
            Level = level;
            Time = DateTime.Now;
            FileName = Path.GetFileName(invokerFrame.GetFileName());    // FIXME: These return null if includeFileData = false
            LineNumber = invokerFrame.GetFileLineNumber();                  // FIXME: These return null if includeFileData = false
            ColNumber = invokerFrame.GetFileColumnNumber();                 // FIXME: These return null if includeFileData = false
            Context = context;
            MessageColor = color;
        }

        /// <summary>
        /// The raw log message string.
        /// </summary>
        public readonly string Msg;

        /// <summary>
        /// Name of the invoking class
        /// </summary>
        public readonly Type InvokerClass;

        /// <summary>
        /// Name of the invoking method
        /// </summary>
        public readonly MethodBase InvokerMethod;

        public string ClassName => InvokerClass.Name;
        public string MethodName => InvokerMethod.Name;

        /// <summary>
        /// The log level of this item.
        /// </summary>
        public readonly LogLevel Level;

        /// <summary>
        /// The time (in seconds) this item was logged.
        /// </summary>
        public readonly DateTime Time;

        /// <summary>
        /// The color of the log text.
        /// </summary>
        public readonly Color? MessageColor;

        public readonly object RawObject;
        public readonly string FileName;
        public readonly int LineNumber;
        public readonly int ColNumber;
        public readonly UnityEngine.Object Context;
    }

}
