using UnityEngine;

namespace Breach.WildWaters.Geometry
{
    /// <summary>
    /// A sphere positioned in 3D space
    /// </summary>
    public class Sphere3d : Sphere
    {
        /// <summary>
        /// Center-position of the sphere
        /// </summary>
        public Vector3 Position { get; private set; }

        public Sphere3d(float radius, Vector3 position) : base(radius)
        {
            Position = position;
        }
    }
}