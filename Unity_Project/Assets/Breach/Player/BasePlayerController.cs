using Breach.WildWaters.Apps;
using Breach.WildWaters.UI;
using UnityEngine;
using UnityEngine.InputSystem;
using static Breach.WildWaters.Player.PlayerActions;

namespace Breach.WildWaters.Player
{
    /// <summary>
    /// Base player-controller for WildWaters Application
    /// </summary>
    public class BasePlayerController : MonoBehaviour, IPlayerUIControlsActions
    {
        protected PlayerActions playerActions;
        protected SimulationControlsUI ui;
        protected Camera playerCamera;
        public void SetUIControl(SimulationControlsUI ui) => this.ui = ui;

        #region MonoBehaviour        

        protected virtual void Awake()
        {
            playerActions = new PlayerActions();
            playerCamera = GetComponentInChildren<Camera>();
        }

        protected virtual void Start()
        {
            if (ui != null) playerActions.PlayerUIControls.SetCallbacks(this);
        }
        protected void OnEnable() => playerActions.Enable();
        protected void OnDisable() => playerActions.Disable();
        protected void OnDestroy() => playerActions.Dispose();

        #endregion

        public void OnToggleSimulationUI(InputAction.CallbackContext context)
        {
            // if (ui == null) return; // This will be null if gamemode is set to observer

            if (context.started)
            {
                var visible = !ui.gameObject.activeSelf;
                if (visible) ui.SetLocalHeight(playerCamera.transform.localPosition.y - 0.3f);
                ui.SetVisible(visible);
            }
        }
    }
}
