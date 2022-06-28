using System;
using Breach.WildWaters.Geometry;
using UnityEngine;

namespace Breach.WildWaters.WaterSystems
{
    /// <summary>
    /// Calculates how much this is under or over water, but does not 
    /// </summary>
    public class WaterSphere : MonoBehaviour
    {
        /// <summary>
        /// How much of the sphere's volume is submerged
        /// </summary>
        public float SubmergedVolume { get; private set; }

        /// <summary>
        /// Cross-section of the submerged area
        /// </summary>
        public float SubmergedArea { get; private set; }

        /// <summary>
        /// Normal direction of the water-surface at this sphere's position
        /// </summary>
        public Vector3 WaterSurfaceNormal {get; private set; }

        /// <summary>
        /// Water velocity at the sphere's position
        /// </summary>
        public Vector3 WaterVelocity {get; private set; }

        /// <summary>
        /// Defines the current interaction state with the water
        /// </summary>
        public WaterInteractionState State { get; private set; }

        private Water water;

        [Header("Settings")]
        [SerializeField] private float radius = 0.47f;


        [Header("Debugging")]
        [Tooltip("Logs to animation curves")]
        [SerializeField] private bool loggingEnabled = false;

        [Space]
        [SerializeField] private AnimationCurve heightAtPosition;
        [SerializeField] private AnimationCurve submergedVolumeLog;
        [SerializeField] private AnimationCurve submergedAreaLog;
        [SerializeField] private AnimationCurve waterVelocityLog;


        private IVelocity velocityProvider;
        public void SetVelocityProvider(IVelocity provider) => velocityProvider = provider;

        private void Awake()
        {
            water = FindObjectOfType<Water>();

            if (water == null) Log.E("No Water in scene. Please add it to enable water interactions");
        }

        private void Start()
        {
            if (velocityProvider is null) 
                Debug.LogError("No VelocityProvider! Make sure this water-sphere has a WaterInteractionBody on its gameObject or in its parent hierarchy", this);
        }

        private void OnDrawGizmosSelected()
        {
            Gizmos.color = State switch
            {
                WaterInteractionState.Submerged => Color.blue,
                WaterInteractionState.PartiallySubmerged => Color.cyan,
                _ => Color.gray
            };
            Gizmos.DrawWireSphere(transform.position, radius * transform.lossyScale.magnitude);
        }

        private void FixedUpdate()
        {
            var sphere = new Sphere3d(radius * transform.lossyScale.magnitude, transform.position);
            // Get the water plane
            var waterPlane = water.GetWaterPlane(transform.position);
            if (waterPlane == null)
            {
                WaterSurfaceNormal = Vector3.up;
                WaterVelocity = Vector3.zero;
                SubmergedArea = 0f;
                SubmergedVolume = 0f;
                State = WaterInteractionState.OverWater;

                if (loggingEnabled)
                {
                    LogData(ref heightAtPosition, -9999f);
                    LogData(ref submergedVolumeLog, 0f);
                    LogData(ref submergedAreaLog, 0f);
                    LogData(ref waterVelocityLog, 0f);
                }
                return; // We have no water-plane information so we cannot do any valid calculations
            }

            WaterSurfaceNormal = waterPlane.Normal;
            WaterVelocity = water.GetWaterVelocity(transform.position);
            
            // Calculates if the object is fully submerged, partially submerged or not submerged at all
            // if partially submerged, also returns the distance from the centre of the object to the water surface
            // so that we can calculate the volume and are of the partially submerged object
            var waterIntersection = GetWaterIntersection(waterPlane, sphere);
            State = waterIntersection.Item1;
            float submergedDistance = waterIntersection.Item2.HasValue ? waterIntersection.Item2.Value : 0f;

            // Get volume and area of the submerged primitive
            SubmergedVolume = GetSubmergedVolume(sphere, State, submergedDistance);
            SubmergedArea = GetSubmergedArea(sphere, State, submergedDistance, waterPlane, velocityProvider.Velocity);

            if (loggingEnabled)
            {
                LogData(ref heightAtPosition, waterPlane.Position.y);
                LogData(ref submergedVolumeLog, SubmergedVolume);
                LogData(ref submergedAreaLog, SubmergedArea);
                LogData(ref waterVelocityLog, WaterVelocity.magnitude);
            }
        }

        
        /// <summary>
        /// Calculates if the object is fully submerged, partially submerged or not submerged at all
        /// if partially submerged, also returns the distance from the centre of the object to the water surface
        /// so that we can calculate the volume and are of the partially submerged object
        /// </summary>
        /// <param name="plane">Plane defining the water suface</param>
        /// <param name="collider">Collider defining the shape of the object</param>
        protected virtual (WaterInteractionState, float?) GetWaterIntersection(Plane3d plane, Sphere3d sphere)
        {
            return SphereIntersection(plane, sphere);
        }

        private float GetSubmergedVolume(Sphere3d sphere, WaterInteractionState state, float submergedDistance)
        {
            return state switch
            {
                WaterInteractionState.Submerged => sphere.Volume,
                WaterInteractionState.PartiallySubmerged => sphere.SphericalCapVolume(sphere.Radius - submergedDistance),
                _ => 0f,
            };
        }

        private float GetSubmergedArea(Sphere3d sphere, WaterInteractionState state, float submergedDistance, Plane3d waterPlane, Vector3 objectVelocity)
        {
            float area;
            switch (state)
            {
                case WaterInteractionState.Submerged:
                    area = new Circle(sphere.Radius).Area;
                    break;
                case WaterInteractionState.PartiallySubmerged:
                    var over = Vector3.Dot(waterPlane.Normal * submergedDistance, objectVelocity);
                    area = over switch
                    {
                        > 0f => new Circle(sphere.Radius).Area,
                        _ => new Circle(sphere.SphericalCapRadius(sphere.Radius - submergedDistance)).Area, // TODO: This is not the correct calculation
                    };
                    break;
                default:
                    area = 0f;
                    break;
            }
            return area;
        }

        /// <summary>
        /// Calculates if the sphere is intersecting with a plane, which side it is on and the distance between them
        /// </summary>
        /// <param name="plane">Plane to intersect with</param>
        /// <param name="sphere">Sphere to be intersected</param>
        protected (WaterInteractionState, float?) SphereIntersection(Plane3d plane, Sphere3d sphere)
        {
            if (plane == null) return (WaterInteractionState.OverWater, null);

            var distance = plane.GetDistanceToPoint(sphere.Position);
            return distance switch
            {
                var x when x >= 0f && Mathf.Abs(x) > sphere.Radius => (WaterInteractionState.OverWater, null),
                var x when x < 0f && Mathf.Abs(x) > sphere.Radius => (WaterInteractionState.Submerged, null),
                var x when Mathf.Abs(x) <= sphere.Radius => (WaterInteractionState.PartiallySubmerged, distance),
                _ => throw new ArgumentOutOfRangeException("Not supported"),
            };
        }

        // TODO: Replace with extension from extensions package
        private void LogData(ref AnimationCurve curve, float data)
        {
            curve.AddKey(new Keyframe(Time.time, data, 0f, 0f));
        }
    }
}
