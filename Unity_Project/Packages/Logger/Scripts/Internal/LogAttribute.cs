// Copyright (c) Breach AS. All rights reserved.

using System;

namespace Breach
{
    /// <summary>
    /// Log attribute that can be attached to classes or methods
    /// </summary>
    [AttributeUsage(AttributeTargets.All)]
    public class LogAttribute : Attribute
    {
        public LogLevel Level { get; private set; }

        public LogAttribute(LogLevel level)
        {
            Level = level;
        }
    }
}
