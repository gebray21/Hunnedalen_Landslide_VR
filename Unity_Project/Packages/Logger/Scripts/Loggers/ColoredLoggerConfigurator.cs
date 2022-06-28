// Copyright (c) Breach AS. All rights reserved.

using UnityEngine;

namespace Breach.Packages.Logger
{

    /// <summary>
    /// Extends the already abstract BaseLogger by providing it with a Color Scheme.
    /// </summary>
    public abstract class ColoredLoggerConfigurator : LoggerConfigurator
    {
        // Editor exposed version of ColorScheme.
        [SerializeField] private ColorSchemeTemplate colorSchemeTemplate;
        protected ColorScheme ColorScheme => new ColorScheme(colorSchemeTemplate);
    }

}
