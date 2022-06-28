// Copyright (c) Breach AS. All rights reserved.

using System.Text;
using UnityEngine;

namespace Breach.Packages.Logger
{

    public readonly struct ColorScheme
    {
        public readonly Color ClassColor;
        public readonly Color MethodColor;
        public readonly Color InfoColor;
        public readonly Color WarningColor;
        public readonly Color ErrorColor;

        public ColorScheme(Color classColor, Color methodColor, Color infoColor, Color warningColor, Color errorColor)
        {
            ClassColor = classColor;
            MethodColor = methodColor;
            InfoColor = infoColor;
            WarningColor = warningColor;
            ErrorColor = errorColor;
        }

        public ColorScheme(ColorSchemeTemplate template)
        {
            ClassColor = template.classColor;
            MethodColor = template.methodColor;
            InfoColor = template.infoColor;
            WarningColor = template.warningColor;
            ErrorColor = template.errorColor;
        }

        public string ClassColorAsHtml => $"#{ColorUtility.ToHtmlStringRGB(ClassColor)}";
        public string MethodColorAsHtml => $"#{ColorUtility.ToHtmlStringRGB(MethodColor)}";
        public string InfoColorAsHtml => $"#{ColorUtility.ToHtmlStringRGB(InfoColor)}";
        public string WarningColorAsHtml => $"#{ColorUtility.ToHtmlStringRGB(WarningColor)}";
        public string ErrorColorAsHtml => $"#{ColorUtility.ToHtmlStringRGB(ErrorColor)}";

        public override string ToString()
        {
            var sb = new StringBuilder("Color Scheme\n");
            sb.AppendLine($"<color={ClassColorAsHtml}>CLASS</color>| {ClassColor}");
            sb.AppendLine($"<color={MethodColorAsHtml}>METHOD</color>| {MethodColor}");
            sb.AppendLine($"<color={InfoColorAsHtml}>INFO</color>| {InfoColor}");
            sb.AppendLine($"<color={WarningColorAsHtml}>WARNING</color>| {WarningColor}");
            sb.AppendLine($"<color={ErrorColorAsHtml}>ERROR</color>| {ErrorColor}");
            return sb.ToString();
        }
    }

    /// <summary>
    /// ColorScheme should have readOnly values. But if we want to SerializeField it, we can do it from the template.
    /// Suggestion... idk if it feels good or not.
    /// </summary>
    [System.Serializable]
    public struct ColorSchemeTemplate
    {
        [Header("Class and Method")] public Color classColor;
        public Color methodColor;

        [Header("Log Level")] public Color infoColor;
        public Color warningColor;
        public Color errorColor;
    }

}
