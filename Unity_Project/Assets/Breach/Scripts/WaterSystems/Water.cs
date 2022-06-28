using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Breach.WildWaters.Geometry;
using UnityEngine;

namespace Breach.WildWaters.WaterSystems
{
    public class Water : MonoBehaviour
    {
        public const float DENSITY = 1000f; // 1000 kg / m3
        public const float GRAVITY_CONST = 9.81f; // Newtowns / kg

        private SimulationManager waterSimulation;

        private void Awake()
        {
            waterSimulation = GetComponent<SimulationManager>();
        }

        /// <summary>
        /// Returns the plane of the water surface at location
        /// </summary>
        public Plane3d GetWaterPlane(Vector3 position)
        {
            if (waterSimulation == null) return new Plane3d(transform.up, transform.position);

            // waterSimulation
            var surfaceHeight = waterSimulation.GetWaterHeightAt(position);
            var waterNormal = waterSimulation.GetWaterNormal(position);

            if (surfaceHeight.HasValue && waterNormal.HasValue)
            {
                return new Plane3d(waterNormal.Value, new Vector3(position.x, surfaceHeight.Value, Mathf.Sign(transform.position.z) * position.z));
            }
            else if (surfaceHeight.HasValue)
            {
                return new Plane3d(Vector3.up, new Vector3(position.x, surfaceHeight.Value, Mathf.Sign(transform.position.z) * position.z));
            }
            else return null;
        }

        public Vector3 GetWaterVelocity(Vector3 position)
        {
            if (waterSimulation == null) return Vector3.zero;

            var velocity = waterSimulation.GetWaterVelocity(position);
            return velocity.HasValue ? new Vector3(velocity.Value.x, 0f, velocity.Value.y) : Vector3.zero;
        }
    }
}