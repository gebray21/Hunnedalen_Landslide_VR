using UnityEngine;

namespace Breach.WildWaters.Apps
{
    public class LobbyMode : WildWatersMode
    {
        private GameObject lobbyMenuPrefab;
        private LobbyMenu lobbyMenu;

        public LobbyMode(IWildWatersSubscriber subscriber, string scene, GameObject playerPrefab, GameObject lobbyMenu) : base(subscriber, scene, playerPrefab)
        {
            Log.I("Lobby mode create");
            lobbyMenuPrefab = lobbyMenu;
        }
        protected override void SetupMode()
        {
            base.SetupMode();
            Log.I("Lobby mode setup");

            // Create lobby menu if not exists
            lobbyMenu = GameObject.FindObjectOfType<LobbyMenu>()
                ?? GameObject.Instantiate(lobbyMenuPrefab, new Vector3(0f, 1.2f, 1.2f), Quaternion.identity)
                    .GetComponent<LobbyMenu>();

            lobbyMenu.NewGame += NewSandboxGame;
        }

        public override void Dispose()
        {
            Log.I("Lobby mode dispose");
            lobbyMenu.NewGame -= NewSandboxGame;
        }

        private void NewSandboxGame(string level) => subscriber.CreateSimulationGame(level);
    }
}
