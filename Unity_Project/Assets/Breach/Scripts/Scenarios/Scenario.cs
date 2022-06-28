using System;

namespace Breach.WildWaters.Scenarios
{
    /// <summary>
    /// Defines the various supported scenarios available
    /// </summary>
    public enum Scenario
    {
        One = 0,
        Two,
        Three, 
        Four,
        Five
    }

    /// <summary>
    /// Flag-representation of the various supported scenarios
    /// </summary>
    [Flags]
    public enum ScenarioFlags
    {
        One = 1 << 0,
        Two = 1 << 1,
        Three = 1 << 2, 
        Four = 1 << 3,
        Five = 1 << 4,
    }

    public static class ScenarioConversions
    {
        public static ScenarioFlags GetFlag(Scenario scenario)
        {
            return scenario switch
            {
                Scenario.One => ScenarioFlags.One,
                Scenario.Two => ScenarioFlags.Two,
                Scenario.Three => ScenarioFlags.Three,
                Scenario.Four => ScenarioFlags.Four,
                Scenario.Five => ScenarioFlags.Five,
                _ => throw new ArgumentOutOfRangeException("Not supported")
            };
        }
    }
}
