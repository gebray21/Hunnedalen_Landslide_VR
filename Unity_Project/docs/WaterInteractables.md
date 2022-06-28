# Water Intractables

#### Remarks

Please note that the Water-Interactable feature is a work-in-progress and has not been through much performance optimisations. Adding too many water-interactables to the scene can cause low frame-rates. We do have multiple ideas on how we can improve the system, but it would require additional work.  

## Instructions

To create something that can be subject to water interaction, please follow the steps:

## Scene Setup

First you need to make sure the scene is configured to be used with the system. 

1. Make sure the `WaterSimulation`-prefab is present in the scene
2. It should contain both the `SimulationManager` and `Water` components (it does by default)
3. The Water intractables will now be able to be influenced by the water, wherever the simulation dictates the water should be each frame.

![prefab](media/water-interaction-01.png)
![WaterSimulationPrefab](media/water-interaction-02.png)


## Use existing Water-Intractable

![WaterPrefabs](media/water-interaction-03.png)

1. Within `Assets/Breach/Prefabs/WaterInteractables` you will find two prefabs already configured
   1. `WaterSphere` is an example of the simplest possible setup. It is a sphere that will interact with the water.
   2. `FloatingBranch` is an example of a more complex water-interactable comprising multiple spheres, to emulate the more complex behaviour of a non-spherical object.

![WaterSphere](media/water-interaction-04.png)
![FloatingBranch](media/water-interaction-05.png)

For quick prototyping we recommend taking the `WaterSphere` and replacing the mesh to quickly create other floating objects in the scene. Of course they will all behave as _spheres_ in the water which could be undesirable due to realism.


## Creating new water-interactables

### Simple

1. Create a new `GameObject` and give it a name
2. Add a `WaterInteractionBody`-component
3. Add a `WaterSphere`-component
4. Your new water-interactable should now be good to go
5. (Optionally) Add a `MeshFilter` and `MeshRenderer` to be able to see it in the game

By tweaking the various Settings you should be able to tweak how it floats and behaves:

| Component              | Setting              | Description                                                                                                        |
|------------------------|----------------------|--------------------------------------------------------------------------------------------------------------------|
| `RigidBody`            | `Mass`               | The mass of the object. Higher number will make the object sink much easier and not be as effected by water-forces |
| `WaterInteractionBody` | `DragCoefficient`    | Coefficient of this body in water (affects both drag and buoyancy)                                                 |
| `WaterInteractionBody` | `DragMultiplier`     | Multiplier to increase the effects of water-drag-forces                                                            |                                                           
| `WaterInteractionBody` | `BuoyancyMultiplier` | Multiplier to increase the effects of buoyancy-forces                                                              |                                                           
| `WaterSphere`          | `Radius`             | Radius of the water-sphere. Should be approximately the size of the mesh                                           |

Note that these settings are far from scientific or accurate and are more values to help you approach realism.

### Complex

To setup a more complex water-interactable object, please follow the step below:

## Creating a new Water-interactable object

1. Create a new `GameObject` and give it a name. This will be our root.
2. To the root, add `WaterInteractionBody`-component
3. A child to the root, add whatever complex mesh you would like to have floating in the water.
   1. To be able to correctly interact with other objects or ground, the mesh needs one or multiple colliders to accurately represent it
   2. If the mesh does not already have a collider, please add colliders and tweak them until they are _somewhat_ of an accurate representation of the object
   3. Below is an example of using 3 capsule colliders to represent the shape of a branch
   4. ![BranchColliders](media/water-interaction-06.png)
4. As children (or grandchildren) to the root, add one or multiple empty `GameObjects` with a `WaterSphere`-component
   1. Adjust their placement and `Radius` until they somewhat match with the mesh 
   2. ![BranchColliders](media/water-interaction-07.png)
5. The final result should have a hierarchy looking like the one below
   1. ![BranchColliders](media/water-interaction-08.png)


## System Description

### `WaterInteractableBody`

This component represents a `GameObject` that can be subject to water interactable. It needs one or multiple `WaterSphere`s in order to work. By tweaking the settings as outlined above, you can emulate various water-behaviours, though the system is not exactly feature-rich at this point.

This is the component that calculates then applies the sum of all water-forces enacted on it.

### `WaterSphere`

This component represents a point on its 'body' that can be affected by water-interaction. When multiple of these are used, the forces are summed together to attempt emulate the complex interaction of non-spherical bodies.