using System;
using UnityEngine;
using UnityEngine.Serialization;

namespace Breach.WildWaters.Scenarios
{
    [CreateAssetMenu(fileName = "Scenario Configuration", menuName = "Breach/Scenario/Config", order = 1)]
    public class ScenarioConfig : ScriptableObject
    {
        [Header("Scenarios")]
        public SimulationVariants[] SimulationVariants;

        [Header("Material")]
        public Material SimulationMaterial;
    }

    [Serializable]
    public class SimulationVariants {
        public string Name;
        public string Path;
    }
}