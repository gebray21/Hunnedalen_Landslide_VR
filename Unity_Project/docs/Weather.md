# Weather Simulation

We have included a package to enable weather simulation in the application. This increases the believability of the environment and makes the user more immersed in the experience.

## Setup

To add weather simulation to a new scene, add the `UniStorm VR System` prefab to the scene.

We have configured this prefab to use custom sounds and configured it to work with URP, so if you are upgrading the weather package or replacing it with a different one, you might want to make sure that you pull in the new sounds.

### Weather types

The weather simulation system comes with many preconfigured weather types for you to choose from.

![All the weathers](media/weather-all-types.png)

If you only desire one specific weather type for the entire experience, you may navigate to the `Weather` tab in the inspector, and set the `Starting Weather Type` to the desired weather type and make sure that `Weather Generation` is set to `Disabled`.

![Static Weather](media/weather-starting-type.png

## Documentation

For more information, please refer to the UniStorm documentation:

https://github.com/Black-Horizon-Studios/UniStorm-Weather-System/wiki

## Issues

The current version of the `UniStorm` weather package seems to lack complete support for URP and certain features, such as auroras, might fail to work properly.