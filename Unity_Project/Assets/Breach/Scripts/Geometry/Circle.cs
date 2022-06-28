using UnityEngine;

namespace Breach.WildWaters.Geometry
{
    /// <summary>
    /// Circle primitive
    /// </summary>
    public class Circle : IArea
    {
        public Circle(float radius)
        {
            Radius = radius;
        }

        /// <summary>
        /// Radius of the circle
        /// </summary>
        public float Radius { get; private set; }

        /// <summary>
        /// Area of the circle
        /// </summary>
        public float Area => Mathf.PI * Mathf.Pow(Radius, 2f);
    }
}