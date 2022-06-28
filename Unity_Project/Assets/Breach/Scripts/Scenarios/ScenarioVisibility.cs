using UnityEngine;

namespace Breach.WildWaters.Scenarios
{
    /// <summary>
    /// Add to a game-object to make it visible or hidden depending on what is currently the active scenaro
    /// </summary>
    public class ScenarioVisibility : MonoBehaviour
    {
        [SerializeField]
        private ScenarioFlags visibility;

        public void SetVisibility(ScenarioFlags activeMode)
        {
            gameObject.SetActive(visibility.HasFlag(activeMode));
        }
    }
}
