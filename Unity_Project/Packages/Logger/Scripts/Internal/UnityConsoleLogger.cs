// Copyright (c) Breach AS. All rights reserved.

using System.Text;
using UnityEngine;

namespace Breach.Packages.Logger
{

    /// <summary>
    /// This is the Default logger <see cref="Log"/> will create when it is not instantiated.
    /// This logger logs to the Unity console using Debug.Log.
    /// </summary>
    public class UnityConsoleLogger : LoggerBase
    {
        public UnityConsoleLogger(ColorScheme scheme, LogLevel level = LogLevel.Error) : base(scheme, level) { }

        /// <summary>
        /// Create a default instance of <see cref="UnityConsoleLogger"/>.
        /// This instance is constructed with a predefined, hardcoded <see cref="ColorSchemeTemplate"/>
        /// it passes on to its base constructor.
        /// </summary>
        public UnityConsoleLogger(LogLevel level = LogLevel.Error) : base(new ColorScheme(HardCodedColorSchemeTemplate), level) { }

        protected override void LogInfo(ref LogEntry entry)
        {
            Debug.Log(FormatEntry(ref entry), entry.Context);
        }

        protected override void LogWarning(ref LogEntry entry)
        {
            Debug.LogWarning(FormatEntry(ref entry), entry.Context);
        }

        protected override void LogError(ref LogEntry entry)
        {
            Debug.LogError(FormatEntry(ref entry), entry.Context);
        }

        private string FormatEntry(ref LogEntry entry)
        {
            var messageBuilder = new StringBuilder();
            messageBuilder.Append($"[<color={Scheme.ClassColorAsHtml}>{entry.ClassName}</color>:"); // <-- Class name and color.                :   [Class:                 (colored)
            messageBuilder.Append($"<i><color={Scheme.MethodColorAsHtml}>{entry.MethodName}()</color></i>]:"); // <-- Method name and color in italic.     :   [Class:Method]:         (colored)
            messageBuilder.Insert(0, "<b>").Append("</b>"); // <-- Wrap everything in bold.             :   [Class:Method]:         (bold and colored)

            // Message color is already set by base.LogX(entry).
            messageBuilder.Append($" <color={MessageColorAsHtml}>{entry.Msg}</color>"); // <-- Add Message with color               :   [Class:Method]: Message (fancy colored)

            return messageBuilder.ToString();
        }

        /// <summary>
        /// Default <see cref="ColorSchemeTemplate"/>.
        /// Only used to create the Default instance of the <see cref="UnityConsoleLogger"/>.
        /// </summary>
        private static ColorSchemeTemplate HardCodedColorSchemeTemplate =>
            new ColorSchemeTemplate
            {
                classColor = new Color32(200, 220, 120, 0),
                methodColor = new Color32(120, 220, 220, 0),
                infoColor = new Color32(195, 195, 195, 0),
                warningColor = new Color32(200, 195, 50, 0),
                errorColor = new Color32(220, 75, 75, 0)
            };
    }

}
