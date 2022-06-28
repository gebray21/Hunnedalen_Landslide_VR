
IMPORTANT:

<Assign layer(water or ground) to each objects>
If you want to use colliding effect, you need to set layer name of each your game objects to be collided by particles to "water"(not "Water") or "ground".

<Layer setting for your project setting>
New layers( water, ground, wind) should exist in your project setting for this asset.
So we made script for this, and when you import this asset, popup window will automatically appear. If you click "Yes" new layers( water, ground, wind) will be added to your project automatically.
If you want to use this feature manually, you can click fulldown menu "RealSnowAndRainEffect" and click "Sync Layers" menu.
This automatic script exists in AssetFolder/Editor/RequiredLayers.cs. If you already added new layers, it is ok if you delete this script file.


<If you want to add new layers by editor manually (not by script) >
Following steps, you can set Layer properly.
1. Edit -> Project Settings -> Tags and Layers
2. Find Layer setting part from inspector and Add layer "water", "ground", "wind" from inspector.
3. GROUND LAYER SETTING : Select ground objects from Hierachy in the scene, and set their Layer( most top area of inspector) to "ground" from inspector.
4. WATER LAYER SETTING : Select water objects from Hierachy in the scene, set their Layer to "water" from inspector.
5. WindZone : Select WindZone in the scene, set its Layer to "wind" from inspector.
6. All done.

---------------------------------------------------------------------

<Steps to apply snow( or rain ) prefab to your scene>

1. Locate the prefab
Drag and drop snow prefab to proper place in your scene.

2. Modify shape and area of the prefab
Click the snow prefab instance and expand the game object.   
Find "<Particle>" component and expand "Shape" element.
You can change the shape or size of the "Shape" component from inspector to fit your scene.

3. Modify lifetime of the particle
Click the snow prefab instance and expand the game object.   
Find "<Particle>" component and check "StartLifeTime" menu in main particle element.
You can change the lifetime to fit your scene.
If you change the lifetime too long, sometimes you need to increase "Max Particles" value in main particle element.

4. Optimize the values by considering performance
Setp 2 and Step 3 influence to performance, so you must optimize the values for your scene and test them.

5. Modify "StartSize" of Particle
Click the snow prefab instance and expand the game object.  
Find "<Particle>" component and change "StartSize" to fit on your scene.
This value will influence to "CollisionGap" variable. So, if you change this value, you would change CollisionGap variable.

6. Check CollisionGap variable
Click the snow prefab instance and expand the game object. 
Find "RainParticleCollisionProcess" script in components from inspector.  
There is "CollisionGap" variable. Collision Gap is for relative distance from the point a particle colliding with surface of the object (through normal direction). 
It is 0.3 for RainController and for SnowController, and -0.5 for SnowController3D now. More large number will move the position to more far from the collided object. On the contrary, if it is minus value, modified position will be close to the collided object.
So, If you change the material in "renderer" element or "StartSize" in main element in "SnowColliderParticle" object, you may change CollisionGap value. And you need to check the collision position from runtime for test.

7. Set particle intensity
Click the snow prefab instance and you can choose "Intensity" property from "SnowParticleCollisionProcess.cs" component in inspector.
There are 7 types of intensity. Very Light, Light, Moderate, Heavy, Very Heavy, Stormy, Very Stormy.
If you choose one of them, "CustomRateOverTime" property will be ignored. And selected type's value will be applied.
But if you choose "Custom", 7 types of intensity will be ignored. And "CustomRateOverTime" property will be applied and you can set "CustomRateOverTime" value manually from inspector.

8. Check 2 types of splash particles that after collision
After colliding to ground or water, old particle(falling snow) will be destroyed and new splash particles(SnowGroundSplash, SnowWaterSplash) created.

----------------------
---  Prefab Detail ---
----------------------

<SnowControllerSingle>
Expand SnowControllerSingle prefab instance in Hierarchy :

+-- SnowControllerSingle
   +-- SnowGroundSplash
   +-- SnowWaterSplash

* SnowControllerSingle : Falling Snow Particle. It has single texture for material. "StartSize" is 2.
* SnowGroundSplash  : New splash on ground created on surface of the collided object when falling rain collided with "ground" object. It has single texture for material.
* SnowWaterSplash : New splash on ground created on surface of the collided object when falling rain collided with "water" object.

----------------------

<SnowControllerMultiple>
Expand SnowController3D prefab instance in Hierarchy :

+-- SnowControllerMultiple
   +-- SnowGroundSplash
   +-- SnowWaterSplash

* SnowControllerMultiple : Falling Snow Particle.  it has 3 types of texture with Texture Sheet Animation.
* SnowGroundSplash  : New splash on ground created on surface of the collided object when falling rain collided with "ground" object. it has 3 types of texture with Texture Sheet Animation.
* SnowWaterSplash : New splash on ground created on surface of the collided object when falling rain collided with "water" object.

----------------------

<SnowController3D>
Expand SnowController3D prefab instance in Hierarchy :

+-- SnowController3D
   +-- SnowGroundSplash
   +-- SnowWaterSplash

Basically this prefab is same as "SnowControllerMultiple", but this prefab's snowflakes rotate 3D direction. And this prefab's "RenderMode" value in "renderer" setting is Mesh. 
* SnowController3D : Falling Snow Particle.  it has 3 types of texture with Texture Sheet Animation.
* SnowGroundSplash  : New splash on ground created on surface of the collided object when falling rain collided with "ground" object. it has 3 types of texture with Texture Sheet Animation.
* SnowWaterSplash : New splash on ground created on surface of the collided object when falling rain collided with "water" object.

----------------------

<SnowControllerBlizzard>
Expand SnowController3D prefab instance in Hierarchy :

+-- SnowControllerBlizzard
   +-- SnowGroundSplash
   +-- SnowWaterSplash

Basically this prefab is same as "SnowControllerMultiple", but following setting is different:
  1) Noise setting : "Strength" value is more large (it is 9) because in blizzard, snowflakes will move strong intensity. And "Frequency" value is small (it is 0.02) because in blizzard, snowflakes will move along with large wavelength. You can change this value with your own intention. 
  2) Renderer setting : "RenderMode" is "Stretched Billboard" and "Speed Scale" is "0.03". Because in blizzard, snowflakes shape will strethced toward it's moving direction. More large "Speed Scale" value will show more long stretch.

* SnowControllerBlizzard : Falling Snow Particle.  it has 3 types of texture with Texture Sheet Animation.
* SnowGroundSplash  : New splash on ground created on surface of the collided object when falling rain collided with "ground" object. it has 3 types of texture with Texture Sheet Animation.
* SnowWaterSplash : New splash on ground created on surface of the collided object when falling rain collided with "water" object.

----------------------

<RainController>
Expand RainController prefab instance in Hierarchy :

+-- RainController
   +-- RainGroundSplash
   +-- RainWaterSplash

* RainController : Falling Rain Particle. It has single texture for material.
* RainGroundSplash  : New splash on ground created on surface of the collided object when falling rain collided with "ground" object.
* RainWaterSplash : New splash on ground created on surface of the collided object when falling rain collided with "water" object.


----------------------

9. WindZone Setting
There is "WindZone" object in the scene and its Layer is "wind". And SnowParticle( or RainParticle)'s "External Forces"'s Layer is also "wind".
Youcan change "WindZone" component from inspector in "WindZone" object. WindZone wil influence the motion of Snow Particles and Rain Particles.

---------------------------------------------------------------------

<How to manage 3D mesh object to be collided with snow flake>

1. Click the 3D mesh object
And click "add component" button from inspector.
And Choose "mesh collider".

2. set your object's layer name to "water"(not "Water") or "ground".

---------------------------------------------------------------------

<Instruction for prefab detail>

There are following 3 prefabs in Prefab folder.

"RainController" prefab: 
This prefab can collide another objects that having layer that named "water" or "ground". Then they will make spots on surface of the objects when they hit the objects.
You can drag the "RainController" prefab into your scene. 
For example, in "GardenRainController" scene in project, you can find "RainController" object in Hierarchy.
Then you can select Intensity property from inspector.
There are 7 type of intensity. Very Light, Light, Moderate, Heavy, Very Heavy, Stormy, Very Stormy.
If you choose "Custom", you can set  "RainController" property in the inspector by yourself manually. To do so, You can click "RainController" in Hierarchy. 
If you click "RainController", you can find "RainGroundSplash" and "RainWaterSplash" in child. And if you click "RainGroundSplash" you can find "renderer" tab in the "ParticleSystem" component in inspector. 
You can change rain splash ripple texture from this. You can choose various material in "Material" folder.
WaterSplashGround_64x64 ~ 512x512 images added in latest version. If you need more detailed image you can use 512x512 texture. if you need more simple image for mobile devices use 64x64 image. default is 128x128 image.
If you don't need to colliding effect, uncheck RainParticleCollisionProcess script in "RainController" object from inspector. Then particle will not collide with another objects. and They will not make spots on surface of the objects.

"SnowControllerSingle" prefab: 
This prefab is similar to "RainController" prefab. content is snow.

"SnowController3D" prefab: 
This prefab is similar to "SnowController" prefab. 
But SnowController3D has 3 types of SnowFlake. -> You can check it from "SnowController3D" object's ParticleSystem component's TextSheetAnimation element and Renderer element. 
And it rotates in 3D axis -> You can check it from "SnowController3D" object's ParticleSystem component's RotationOverLifetime element. 
And in child of child object, there is "SnowGroundSplash", it supports 3 types of snow spot.
So "SnowController3D" prefab is very beautiful and looks natural.
You can check it from "Garden_SnowController3D" example scene.

---------------------------------------------------------------------

<More detail explanation about "RainController" prefab>

Generating Area Shape:
Choose a rain prefab.
Rain Prefab->ParticleSystem->Shape 
In Shape tab, you can change Generating Area Shape.  By default it is "Box and Volume".
You can change Scale by "Scale" element(X, Y, Z axis).

Number of Particle:
RainPrefab->ParticleSystem->Emission
You can change number of particle in "Rate over Time".
if you increase this value, you must increase also "Max Particles" value in "Rain Prefab->ParticleSystem->RainParticles".

Direction of Rain
RainPrefab->ParticleSystem->Velocity over Lifetime
Y axis is now -80. because -80 is following y axis and this made rain fall into bottom direction. if you change this value you can change falling velocity of rain.

Lifetime of Rain
Rain Prefab->ParticleSystem->RainParticles->StartLifeTime
You can change this value for life time of rain.

Texture of Rain
Rain Prefab->ParticleSystem->Renderer->Material
You can find "Rain" material and you click it, you can find "Rain" material.
you can change your own Rain material.

More detail explanation about "SnowParticleSingle" prefab:
Snow Particle setting is similar to Rain Particle. But it has one more element.
Snow Prefab->ParticleSystem->Noise
You can change Strength and Frequency value to change damping intension.

---------------------------------------------------------------------

< How to particle effect will follows camera >
If you simply drag and drop camera object ( or player object ) in the scene to "Following Camera" property in inspector about RainParticleCollisionProcess.cs script or SnowParticleCollisionProcess.cs, particle effect will follows the camera. 
For example, if you wish the rain( or snow) follow the moving airplane or vehicle, you can use this function. 
Be careful. If you assign "Following Camera" property, you can't move particle's position manually in runtime because particle's position automatically follows the camera.

---------------------------------------------------------------------


<How to change Snow ( or rain ) Intensity by script>

1. How to change intensity option ( you can choose 7 type of intensity) :
7 types of intensity is VeryLight, Light, Moderate, Heavy, VeryHeavy, Stormy, VeryStormy. 
You can change this code by modifying code RainParticleCollisionProcess.cs or SnowParticleCollisionProcess.cs. See following code.

        switch (Intensity)
        {
            case intensity.VeryLight:
                emissionModule.rateOverTime = 30;
                break;

            case intensity.Light:
                emissionModule.rateOverTime = 60;
                break;

            case intensity.Moderate:
                emissionModule.rateOverTime = 100;
                break;

            case intensity.Heavy:
                emissionModule.rateOverTime = 200;
                break;

            case intensity.VeryHeavy:
                emissionModule.rateOverTime = 400;
                break;

            case intensity.Stormy:
                emissionModule.rateOverTime = 600;
                //mainModule.startLifetime = 15;
                break;

            case intensity.VeryStormy:
                emissionModule.rateOverTime = 900;
                //mainModule.startLifetime = 15;
                break;
        }


If you want to change the intensity option by script, see following example code:

----------
Gameobject RainObj = new GameObject;
RainObj.GetComponent<RainContoller>().Intensity = intensity.VeryLight;
----------

2. How to change custom intensity by script:
You can change intensity by following example code. ( At first, change intensity option to "Custom" and change CustomRateOverTime variable. )

----------
Gameobject RainObj = new GameObject;
RainObj.GetComponent<RainContoller>().Intensity = intensity.Custom;
RainObj.GetComponent<RainContoller>().CustomRateOverTime = 350;
----------


---------------------------------------------------------------------

Thank you for using our assets.

technical support:
oharinth@gmail.com

---------------------------------------------------------------------

<Release Note>
Ver 1.1.4.4
 * Manual Updated. some script file name and prefab name in manual were wrong and now updated well.

Ver 1.1.4.3
 * Now particle effect can follows camera.  If you drag and drop camera ( or player object ) to "Following Camera" property in inspector, particle effect will follow the camera.  
 * Support only english manual.

Ver 1.1.4.2
 * Some JPG images converted to PNG.
 * Some unnecessary image files are deleted.

Ver 1.1.4.1
 * Layer Manager enhanced.
 * LayerManager.cs changed to RequiredLayers.cs

Ver 1.1.4
 * Bug Fix: LayerManager.cs script added to fix layer problem by setting layers properly in Garden scenes.
 * Manual updated.

Ver 1.1.3.6 Updated
* Background enhanced.
* Scripts integrated.
* Manual Updated.

Ver 1.1.3.5 Updated
* Blizzard snowflake added.
* 2D multiple snowflake added.
* Supports WindZone.
* Background and Skybox enhanced.

Ver 1.1.3.4 Updated:
* Background objects updated.
* Manual updated.

Ver 1.1.3.3 Updated:
* Some background object's textures updated to reduce resolution and size.
* Manual Updated.

Ver 1.1.3.2 Updated:
* Intensity option in script modified.
* Tree mesh modified.
* Minor bug fixed.

Ver 1.1.3.1 Updated:
* Bug Fixed : Bug on CollisionGap variable was fixed.
* Intensity function enhanced.

Ver 1.1.3 Updated:
* Each rain flake and snow flake will create spots on surface precisely normal direction about colliding object's surface.
* Each snow flake will fall with various shape of snow flake(3 types) and they will fall with rotating. And they will create spot with various shape of snow spot. So they are very beautiful and real! 
* GardenRain, GardenSnow scene added.

Ver 1.1.2 Updated:
* More realistic rain ripple texture (Splash with ground) added. 
You can check it in "RainColliderScene". You can change rain ripple in inspector. And check RainWaterSplash object in RainColliderParticle in RainColliderController prefab.  And check material in the Renderer component. You can find more various rain ripple textures in "Texture" folder.  WaterSplashGround_64x64 ~ 512x512 images added. If you need more detailed image you can use 512x512 texture. if you need more simple image for mobile devices use 64x64 image. default is 128x128 image.

Ver 1.1.1 Updated:
* Rain intensity can be changed by inspector or script in runtime
If you change RainColliderController.cs Rain Intensity in runtime, it will be applied immediately to the particles. You can change the intensity with inspector or with script. By script, you can change the variable "RainIntensity".
* More realistic rain ripple texture (Splash with water) added. 
You can check it in "RainColliderScene". You can change rain ripple in inspector. And check RainWaterSplash object in RainColliderParticle in RainColliderController prefab.  And check material in the Renderer component. You can find more various rain ripple textures in "Texture" folder.  WaterRipple1~3 images added.

Version 1.1
* Rain effect and snow effect can collide to objects that having layer that named "water" and "ground".
RainColliderScene and SnowColliderScene were added.


---------------------------------------------------------------------