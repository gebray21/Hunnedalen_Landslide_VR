using UnityEngine;

namespace Breach.WildWaters.WaterSystems
{
    [RequireComponent(typeof(Rigidbody))]
    public class WaterInteractionBody : MonoBehaviour, IVelocity
    {
        private Water water;
        private new Rigidbody rigidbody;
        private WaterSphere[] spheres;

        [Header("Settings")]
        [SerializeField] private float dragCoefficient = 0.47f;

        [Tooltip("Optional multiplier to boost the drag-forces experienced")]
        [SerializeField] private float dragMultiplier = 1;

        [Tooltip("Optional multiplier to boost the bouyancy-forces experienced")]
        [SerializeField] private float bouyancyMultiplier = 1;

        [Header("Debugging")]
        [Tooltip("Logs to animation curves")]
        [SerializeField] private bool loggingEnabled = false;

        [Tooltip("Red: Bouyancy Force, Blue: Drag Force")]
        [SerializeField] private bool viewDebugForces = false;

        [Header("Logs")]
        [SerializeField] private AnimationCurve bouyancyLog;
        [SerializeField] private AnimationCurve dragLog;
        [SerializeField] private AnimationCurve waterVelocityLog;

        public Vector3 Velocity => rigidbody.velocity;

        // Forces
        private Vector3 bouyancyForce = Vector3.zero;
        private Vector3 dragForce = Vector3.zero;
        private Vector3 totalVelocity;

        private void Awake()
        {
            rigidbody = GetComponent<Rigidbody>();
            
            water = FindObjectOfType<Water>();
            if (water == null) Log.E("No Water in scene. Please add it to enable water interactions");

            // Collect all spheres contributing to this body
            spheres = GetComponentsInChildren<WaterSphere>();
            foreach (var sphere in spheres) sphere.SetVelocityProvider(this);
        }

        private void OnDrawGizmosSelected()
        {
            if (!viewDebugForces) return;
            Gizmos.color = Color.red;
            Gizmos.DrawLine(transform.position, transform.position + bouyancyForce);
            Gizmos.color = Color.blue;
            Gizmos.DrawLine(transform.position, transform.position + dragForce);
        }

        private void FixedUpdate()
        {
            // Reset values from last frame
            dragForce = Vector3.zero;
            bouyancyForce = Vector3.zero;
            totalVelocity = Vector3.zero;

            // Fetch values from interactables
            foreach (var sphere in spheres)
            {
                // Get forces for this interactable
                var bouyancy = BouyancyForce(sphere.SubmergedVolume, sphere.WaterSurfaceNormal) * bouyancyMultiplier;
                var drag = DragForce(sphere.SubmergedArea, sphere.WaterVelocity - rigidbody.velocity) * dragMultiplier;

                // Tally totals and cache for later
                bouyancyForce += bouyancy;
                dragForce += drag;
                totalVelocity += sphere.WaterVelocity;

                // Apply forces to rigidbody
                rigidbody.AddForceAtPosition((drag + bouyancy) * Time.deltaTime, sphere.transform.position, ForceMode.Force);
            }

            // Log results if enabled
            if (loggingEnabled)
            {
                bouyancyLog.AddKey(new Keyframe(Time.time, bouyancyForce.magnitude, 0f, 0f));
                dragLog.AddKey(new Keyframe(Time.time, dragForce.magnitude, 0f, 0f));
                waterVelocityLog.AddKey(new Keyframe(Time.time, totalVelocity.magnitude, 0f, 0f));
            }
        }

        private Vector3 BouyancyForce(float volume, Vector3 normal)
        {
            return volume * Water.DENSITY * Water.GRAVITY_CONST * normal;
        }

        /// <summary>
        /// Calulates the drag-force of the object submerged in water
        /// </summary>
        /// <param name="area">Area of object in water, perpendicular to its velocity</param>
        /// <param name="velocity">Velocity of the object</param>
        private Vector3 DragForce(float area, Vector3 velocity)
        {
            // Drag forces:
            // F = 0.5f * DragCoefficient * Area of the object perpendicular to the motion * p (density of fluid) * velocity squared
            //                             This should be area submerged perpendicular to the objects velocity
            return 0.5f * dragCoefficient * area * Water.DENSITY * Mathf.Pow(velocity.magnitude, 2f) * velocity.normalized;
        }
    }
}
