# Scenario

This describes how to setup the scenario once all the data has been prepared and imported.

Make sure you have followed the directions outlined in [New Scene](NewScene.md) and [Import](Import.md) before continuing here.

## Create the scenario config

1. Right click in the Asset folder -> Create -> Breach -> Scenario -> Config
![Create New](media/scenario-config.png)
2. Name the scenario something descriptive and save the file
3. Add the imported data to the simulation variants
    - Add multiple variations if relevant
    - The path should be a relative path from within `Assets/StreamingAssets/SceneData`
4. Add the flow-material for this simulation

![Configure](media/scenario-config-name.png)


## Add the config to the scene

1. In your scene, you should have the `WaterSimulation`-prefab with the `SimulationManager`.
2. Find it and add the ScenarioConfig you just created to the `Config`

![Add config](media/add-config.png)

You should now be fully setup and ready!

## Scenario-dependent visibility

In order to have an object visible / active only on certain scenarios, simply add the `ScenarioVisibility`-component to the gameObject. In the settings, you can configure which scenarios this object should be active / visible in.

The scenarios correspond to the index in the `ScenarioConfig` previously setup.

The component can be active / visible on one or multiple scenarios.

![Scenario Visibility](media/scenario-vis.png)