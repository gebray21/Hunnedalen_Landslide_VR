// Copyright (c) Breach AS. All rights reserved.

using UnityEngine;

namespace Breach.Packages.Logger
{

    /// <summary>
    /// This is an abstract ScriptableObject that should create the Logger instance we want.
    /// </summary>
    public abstract class LoggerConfigurator : ScriptableObject
    {
        [SerializeField] protected LogLevel logLevel;

        // This instance should only be managed by this base class.
        private LoggerBase _loggerInstance;

        /// <summary>
        /// Creates and sets a logger instance. Returns it.
        /// </summary>
        public LoggerBase InitializeLogger()
        {
            _loggerInstance = CreateLogger();
            return _loggerInstance;
        }

        /// <summary>
        /// Should create a new LoggerBase instance and return it.
        /// Every custom logger has to implement this function.
        /// </summary>
        protected abstract LoggerBase CreateLogger();

        /// <summary>
        /// Enables the logger.
        /// </summary>
        private void EnableLogger()
        {
            if (_loggerInstance == null) return;
            _loggerInstance.Enabled = true;
        }

        /// <summary>
        /// Disables the logger.
        /// </summary>
        private void DisableLogger()
        {
            if (_loggerInstance == null) return;
            _loggerInstance.Enabled = false;
        }

        public override string ToString()
        {
            return nameof(LoggerConfigurator);
        }

    }

}
