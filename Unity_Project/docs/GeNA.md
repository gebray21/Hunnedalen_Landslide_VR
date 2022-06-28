# Quickly populating scenes with details using GeNa

We have included a tool in the project, called GeNa, that lets you quickly populate scenes with important details, such as vegetation or rocks. We have also preconfigured several spawners with prefab assets from nature packages. This lets you very quickly add details to your terrains.

## Tutorial

To start with, open a scene with a terrain that you wish to add more details to. Then, additively load the `GeNa Spawners` scene, either by dragging it into the `Hierarchy` windows or by right-clicking and selecting `Open Scene Additive`

![Open GeNa](media/gena-load-scene.png)

In the `Hierarchy` window, you will now see all the preconfigured spawners.

![GeNa Spawners](media/gena-spawners.png)

Selecting one will reveal it's setting in the `Inspector` and allow you to interact with it.

![GeNa Spawner](media/gena-spawner.png)

You will now be able to spawn new objects of this type in the Editor window, using the keybindings visible at the top of the Inspector window. Especially the `Global Spawn` functionality is very useful to quickly populate the terrain with details.

![GeNa Editor](media/gena-editor-preview.png)

![Gena Spawning](media/gena-spawned.png)

Once you are finished with spawning objects into the scene, remove the `Gena Spawners` scene from the `Hierarchy`.

![GeNa Remove](media/gena-remove.png)

## Documentation

For more information, refer to the official GeNa 2 documentation. It is included in the project, under `Assets\Procedural Worlds\GeNa\Documentation` you will find `GeNa Documentation v2_0_0.pdf`.

## Troubleshooting

It sometimes happens that the spawners stop responding to input. In such a case, resetting the editor layout usually resolves the issue: `Window -> Layouts -> Reset All Layouts`.