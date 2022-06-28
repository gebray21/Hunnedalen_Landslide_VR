using System;
using UnityEngine;

namespace Breach.WildWaters.Geometry
{
    /// <summary>
    /// A capsule primitive that can be positioned in 3d space
    /// </summary>
    public class Capsule3D : Capsule
    {
        public LineSegment3d InteriourLine { get; private set; }
        public new float Height => InteriourLine.Length;
        public new float HalfHeight => Height * 0.5f;
        public Vector3 Center => InteriourLine.Center;
        public Vector3 Direction => InteriourLine.Direction;

        public Capsule3D(float radius, float height, Vector3 center, Vector3 direction)
        {
            Radius = radius;
            InteriourLine = new LineSegment3d(center - direction * height, center + direction * height);
        }

        public Capsule3D(float radius, LineSegment3d lineSegment)
        {
            Radius = radius;
            InteriourLine = lineSegment;
        }

        public Capsule3D(CapsuleCollider collider)
        {
            Radius = collider.radius;

            var dir = collider.direction switch {
                0 => collider.transform.right,
                1 => collider.transform.up,
                2 => collider.transform.forward,
                _ => throw new NotSupportedException("Unsupported capsule direction")
            };

            var height = collider.height - 2f * collider.radius;
            var center = collider.transform.position + collider.center;

            InteriourLine = new LineSegment3d(
                center - dir * height * 0.5f,
                center + dir * height * 0.5f
            );
        }
    }
}
