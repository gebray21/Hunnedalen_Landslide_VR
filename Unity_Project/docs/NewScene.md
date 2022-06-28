# Creating a new scene

The easiest approach is to use the provided scene template, that will create a new scene for you with all the basic components to get you started quickly.

Navigate to `File -> New Scene` and select Woww New Scene from the list. Have the scene created inside `Assets/Breach/Scenes/DynamicScenes` if you would like it to be automatically selectable from the Lobby.

![New Scene From Template](media/new-scene-template.png)


In general, these are the components that should be present in the scene:
 - `Application` prefab
 - `PlayerSpawn` prefab where you want your player to start
 - `WaterSimulation` prefab for running the flow surface animation
 - `UniStorm VR System` for weather simulation
 - Add `Teleportation Area` on your terrain if you want the player to be able to move around using teleportation on the terrain

 ## Next steps

Follow the steps described in [Import](Import.md) to import your terrain and to preprocess your flow data.