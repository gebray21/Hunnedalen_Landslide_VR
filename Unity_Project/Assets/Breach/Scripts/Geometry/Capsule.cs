using UnityEngine;

namespace Breach.WildWaters.Geometry
{
    /// <summary>
    /// A Math primitive for Capsule
    /// </summary>
    public class Capsule : IVolume, IArea
    {
        /// <summary>
        /// Radius of the cylinder
        /// </summary>
        public float Radius { get; protected set; }

        /// <summary>
        /// Total height of the cylindrical section of of the capsule
        /// </summary>
        public float Height { get; protected set; }
        public float HalfHeight => Height * 0.5f;
        public float FullHeight => Height + 2f * Radius;
        public float Volume => Mathf.PI * Mathf.Pow(Radius, 2f) * (4f / 3f * Radius + Height);
        public float Area => 2f * Mathf.PI * Radius * (2f * Radius + Height);

        public Capsule(float radius, float height)
        {
            Radius = radius;
            Height = height;
        }
        public Capsule(CapsuleCollider collider)
        {
            Radius = collider.radius;
            Height = collider.height - 2f * collider.radius;
        }

        protected Capsule() { }
    }
}
