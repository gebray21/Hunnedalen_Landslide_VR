using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UnityEngine;

namespace Breach.WildWaters.Geometry
{
    /// <summary>
    /// Unbounded plane positioned in 3d space
    /// </summary>
    public class Plane3d
    {
        public Vector3 Position { get; private set; }
        public Vector3 Normal { get; private set; }
        public float Distance => Position.magnitude;
        public Plane3d(Vector3 normal, Vector3 position)
        {
            Position = position;
            Normal = normal;
        }

        public float GetDistanceToPoint(Vector3 point) => new Plane(Normal, Position).GetDistanceToPoint(point);
    }
}