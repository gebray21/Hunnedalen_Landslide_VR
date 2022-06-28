using UnityEngine.XR.Interaction.Toolkit;

namespace Breach.WildWaters.Player
{
    /// <summary>
    /// Responsible for everything that has to do with how the XRPlayer interacts with the world
    /// </summary>
    public class XRPlayerController : BasePlayerController
    {
        private TeleportationProvider teleportProvider;
        private XRInteractionManager interactionManager;

        protected override void Awake()
        {
            base.Awake();

            teleportProvider = GetComponent<TeleportationProvider>();
            interactionManager = GetComponent<XRInteractionManager>();

            SetupTeleportation();
        }

        /// <summary>
        /// Ensures all teleportaion interactables have references to the player's teleportation provider and interaction manager
        /// </summary>
        private void SetupTeleportation()
        {
            var teleportAreas = FindObjectsOfType<BaseTeleportationInteractable>();
            foreach (var area in teleportAreas)
            {
                area.interactionManager = this.interactionManager;
                area.teleportationProvider = this.teleportProvider;
            }
        }
    }
}