# Changelog

## [Unreleased]

## [0.3.1] - 2022-04-28

### Changed

- Improved `WaterInteractable` documentation
- Updated UnityEditor to `2021.3.0f1`

## [0.3.0] - 2022-03-23

### Known Issues

-   Expanding and contracting the `Dependencies`-panel in the `Assets/Breach/Scenes/Templates/SceneTemplate` will cause the settings to change.
    -   For the template to work only `Terrain` should be checked and nothing else
    -   This is a bug with Unity itself

### Added

-   `WaterInteractionBody` that can interact with the water-simulation and be affected by it.
    -   To use: Follow the description in the [`README`](./README.md)
    -   Can support bodies of arbitrary size and shape
-   The Utvik scene now has buildings
-   Both Utvik and Hunndalen scenes now has more weather effects and sounds
-   The simulation now can support up to 5 different scenarios / variations
-   Added a `ScenarioVisibility` that enables or disables objects based on what scenario they are configured to be active in

### Changed

-   Project now uses Unity Editor `2021.2.15f1`
-   Frame-preprocessor has now been moved to `Window -> Breach -> Pre Processor` instead of being a component on a game-object
-   Improved the wind-visuals on the trees
-   Improved visuals of the simulated water
-   Improved performance of data preprocessing pipeline by >50%

### Fixed

-   Water animation performance has been improved

## [0.2.0] - 2022-01-28

### Added

-   Changelog, Readme & Licence files
-   Can now query water for surface normals

### Fixed

-   Fixed issue with Logger-package not being able to be pulled by user
-   Improved visual representation of water

## [0.1.0] - 2022-01-27

-   Initial release
