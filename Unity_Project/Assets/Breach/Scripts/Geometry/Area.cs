using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UnityEngine;

namespace Breach.WildWaters.Geometry
{
    public static class Area
    {
        public static float GetAreaOfCircle(float radius)
        {
            return Mathf.PI * Mathf.Pow(radius, 2f);
        }
        public static float GetSphereVolume(float radius)
        {
            return (4f / 3f) * Mathf.PI * Mathf.Pow(radius, 3f);
        }
        public static float GetSphericalCapVolume(float radius, float capHeight)
        {
            return ((Mathf.PI * Mathf.Pow(capHeight, 2f)) / 3f) * (3f * radius - capHeight);
        }
    }
}