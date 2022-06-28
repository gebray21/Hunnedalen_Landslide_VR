using System.Collections;
using System.Collections.Generic;
using Breach.WildWaters.Apps;
using UnityEngine;
using UnityEngine.InputSystem;
using static Breach.WildWaters.Player.PlayerActions;

namespace Breach.WildWaters.Player
{
    /// <summary>
    /// Editor player with WASD movement
    /// Responsible for everything that has to do with how the EditorPlayer interacts with the world
    /// </summary>
    [RequireComponent(typeof(Rigidbody))]
    public class EditorPlayer : BasePlayerController, ISimulationControlsActions
    {
        [SerializeField] private float horizontalMultiplier = 1500f;
        [SerializeField] private float speedBoost = 3f;
        [SerializeField] private float rotMultiplier = 1f;
        private new Rigidbody rigidbody;
        protected IPlaybackControls controller;
        public void SetSimulationController(IPlaybackControls controller) => this.controller = controller;

        protected override void Awake()
        {
            base.Awake();
            rigidbody = GetComponent<Rigidbody>();
        }

        protected override void Start()
        {
            base.Start();

            if (controller != null) playerActions.SimulationControls.SetCallbacks(this); // If gamemode is observer, controller will be null
        }
        public void OnPlaySimulation(InputAction.CallbackContext context)
        {
            if (context.started) controller.Play();
        }

        public void OnPauseSimulation(InputAction.CallbackContext context)
        {
            if (context.started) controller.Pause();
        }

        public void OnStopSimulation(InputAction.CallbackContext context)
        {
            if (context.started) controller.Stop();
        }

        private void FixedUpdate()
        {
            var forward = playerActions.EditorMovement.MoveForward.ReadValue<float>();
            var right = playerActions.EditorMovement.MoveRight.ReadValue<float>();
            var up = playerActions.EditorMovement.MoveUp.ReadValue<float>();
            var boost = playerActions.EditorMovement.SpeedBoost.ReadValue<float>();
            var enableRot = playerActions.EditorMovement.EnableRotation.ReadValue<float>();

            rigidbody.AddForce(
                (transform.forward * forward + transform.right * right + transform.up * up)
                * Time.fixedDeltaTime
                * horizontalMultiplier
                * Mathf.Lerp(1, speedBoost, boost),
                ForceMode.Force
            );

            if (enableRot < .5f) return;

            var rotation = playerActions.EditorMovement.Rotation.ReadValue<Vector2>();
            var projectedPosition = playerCamera.ScreenToWorldPoint(new Vector3(rotation.x, rotation.y, 1));
            var lookAtProjected = Quaternion.LookRotation((projectedPosition - playerCamera.transform.position).normalized, Vector3.up);
            this.transform.rotation = Quaternion.Slerp(this.transform.rotation, lookAtProjected, rotMultiplier * Time.fixedDeltaTime);
        }
    }
}
