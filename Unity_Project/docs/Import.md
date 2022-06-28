# Data Import

This outlines the procedures to import new datasets into the project. There's two main parts, terrain import and flow data import.

## Creating the Scene

Refer to [New Scene Tutorial](NewScene.md) on how to create a new scene. The name of the scene will be important later on, so choose one carefully.


## Terrain Import

![Terrain Import tool](media/import-terrain-tool.png)

 - To start, create an empty game object. Add the `Terrain Import Tool` component.
 - Next, click on `Browse`, and navigate to the terrain file. Note that currently only `.asc` files are supported.
 - Click on `Load` to load the terrain data. This can take some time.
 - The fields below, such as `Width`, `Length`, and `Maximum Height` will get populated automatically depending on the terrain data. Only change these if you know what you are doing.
 - You may decrease the `Resolution` if you wish to decrease the accuracy while improving performance.
 - Select the `Target Terrain` to import data into.
 - If necessary, enable mirroring along diagonal (`Transpose`) or either of the axes (`Mirror X`, `Mirror Y`)
 - Click `Import`. If the result is incorrect (e.g. flipped along the diagonal) modify the import setting above and try again.


## Flow Data Import

To start with, we need to organize the data into a format that the flow import tool can work with. There are 4 required components that need to be in the same parent folder:

 - `Elevation` Directory
   - Elevation `.asc` files of the surface, as it changes in time
 - `Velocity_X` Directory
   - Velocity along X axis `.asc` files of the surface, as it changes in time
 - `Veloity_Y` Directory
   - Velocity along Y axis `.asc` files of the surface, as it changes in time
 - `Terrain.asc` File
   - The underlying terrain. This is required due to some preprocessing of the flow surface that happens
   - This is a file that is found by having `.asc` extention and the keyword `terrain` in it's name. Make sure there is *exactly one* such file in the folder.

Below is an example of a directory setup for being preprocessed. The required items are marked with a red mark:

![Import Flow Directory Structure](media/import-flow-dir-structure.png)

Once you have the required structure, you can now navigate in the Unity project to `Window -> Breach -> Pre-processing`.

 - `Select folder to process`
   - Select the parent folder of the 4 components, as explained above.
 - `Select destination folder`
   - Select the folder where pre-processed data should be stored. Use `<Project>/Assets/StreamingAssets/SceneData/<Scene>/Frames`.
   - The `<Scene>` has to be the name of the scene you plan to use this data in, as created in the first step of this document.

![Import tool UI](media/import-flow-ui.png)

- Click `Process`, and wait. Note that this operation can take some time depending on the size and amount of data, and will use all your available CPU resources.
  - A dataset as large as `Utvik` can take between 10 and 25 minutes on a decent system.

![Grassy](media/terrain-grass.png)

## Next Steps

Follow the steps outlined in [Scenario](Scenario.md) to setup the scenario and make it ready to play in Unity.