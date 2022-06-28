namespace Breach.WildWaters.Apps
{
    public interface IWildWatersSubscriber : IQuittableApp
    {
        void CreateLobby();
        void CreateSimulationGame(string level);
    }

    public interface IQuittableApp
    {
        void QuitApp();
    }
}
