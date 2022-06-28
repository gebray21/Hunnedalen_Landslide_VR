using UnityEngine;

namespace Breach.WildWaters.Geometry
{
    /// <summary>
    /// A line with a position and direction, with infinite length
    /// </summary>
    public class Line3d
    {
        public Vector3 Direction { get; private set; }
        public Vector3 Position { get; private set; }

        public Line3d(Vector3 position, Vector3 direction)
        {
            Position = position;
            Direction = direction.normalized;
        }
    }
}