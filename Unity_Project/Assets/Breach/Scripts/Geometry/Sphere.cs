using System;
using UnityEngine;

namespace Breach.WildWaters.Geometry
{
    public class Sphere : IVolume, IArea
    {
        public Sphere(float radius)
        {
            Radius = radius;
        }

        public float Radius { get; protected set; }
        public float Area => 4f * Mathf.PI * Mathf.Pow(Radius, 2f);
        public float Volume => (4f / 3f) * Mathf.PI * Mathf.Pow(Radius, 3f);

        /// <summary>
        /// Returns the volume of a spherical cap: i.e a section of the sphere sliced by a plane
        /// </summary>
        /// <param name="height">The height of the plane slicing the sphere</param>
        /// <remarks>https://en.wikipedia.org/wiki/Spherical_cap</remarks>
        public float SphericalCapVolume(float height) 
        {
            // Log.E($"Height: {height} | 2R: {2f * Radius}");
            if (height < 0f || height > 2f * Radius)
            {
                throw new ArgumentOutOfRangeException("Height should be in range {0 -> 2 * Radius}");
            }

            return ((Mathf.PI * Mathf.Pow(height, 2f)) / 3f) * (3f * Radius - height);
        }

        /// <summary>
        /// Returns the radius of the circle where a plane at height h intersects the sphere
        /// </summary>
        /// <param name="height">Height of the intersecting plane. Range { 0 => 2R }</param>
        public float SphericalCapRadius(float height)
        {
            if (height < 0f || height > 2f * Radius) throw new ArgumentOutOfRangeException("Height should be in range { 0 -> 2 * Radius }");
            return Mathf.Sqrt(-height * (height - 2f * Radius));
        }

    }
}