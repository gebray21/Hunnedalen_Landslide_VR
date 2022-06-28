using UnityEngine;

namespace Breach.WildWaters.Apps
{
    /// <summary>
    /// Monobehaviour wrapper for the application
    /// </summary>
    public class AppBehaviour : MonoBehaviour
    {
        [SerializeField] protected AppSettings settings;
        private App app;
        private static AppBehaviour instance;
        public static AppBehaviour Instance
        {
            get
            {
                if (instance == null) instance = FindObjectOfType<AppBehaviour>();
                return instance;
            }
        }
        private void Awake()
        {
            if (Instance != this) Destroy(gameObject);
            else
            {
                DontDestroyOnLoad(this.gameObject);
                app = CreateApplication();
            }
        }

        protected virtual App CreateApplication()
        {
            Log.I("Creating application");
            return new WildWatersApp(settings);
        }
    }
}
