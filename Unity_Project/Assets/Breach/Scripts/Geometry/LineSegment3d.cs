using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace Breach.WildWaters.Geometry
{
    /// <summary>
    /// A line bounded by two points in 3d space
    /// </summary>
    public class LineSegment3d
    {
        /// <summary>
        /// Start point of the line segment
        /// </summary>
        public Vector3 Start { get; private set; }

        /// <summary>
        /// End point of the line segment
        /// </summary>
        public Vector3 End { get; private set; }

        /// <summary>
        /// Returns the center of the line segment
        /// </summary>
        /// <returns></returns>
        public Vector3 Center => (Start + End) * 0.5f;

        /// <summary>
        /// Normalized direction of the line segment
        /// </summary>
        public Vector3 Direction => (End - Start).normalized;

        /// <summary>
        /// Lenght of the line segment
        /// </summary>
        public float Length => (End - Start).magnitude;

        #region Conversions
        
        public Line3d Line => new Line3d(Start, Direction);

        #endregion

        public LineSegment3d(Vector3 start, Vector3 end)
        {
            Start = start;
            End = end;
        }
    }
}
