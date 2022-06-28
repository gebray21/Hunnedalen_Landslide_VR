# Hunnedalen_Landslide_VR

Realistic Visualization of Debris flow type landslides through Virtual Reality

This project originally included 2 folders:
Folder 1: Unity projects ready to be used as source code 
Folder 2 Already built Unity 

Description of the project:
* This project provides a VR (Virtual Reality)-compatible interactive 3D experience
	of 2 natural disaster scenarios. These 2 scenes are available in the same
	application, and can be switched via a main menu. They can be experienced
	with either a VR headset or through a Desktop window.
* The two scenes include: Scene 1) An earthquake that causes large buildings to 
	collapse in a city, and Scene 2) A hurricane that causes homes to break apart, 
	with debris flying in the air, in a suburban neighborhood. 
* The simulated data for Scene 1) was prepared in the software "Extreme Loading for 
	Structures," to prepare a series of 3D .stl models representing a building 
	for each time frame of collapse. The simulated data for Scene 2) includes 
	location data for airborne debris, calculated in Mathworks Matlab. The output 
	from these are used in the game engine Unity3D to render the interactive 
	environment. This project includes the compiled version and source files of 
	the Unity3D portion of the project.
* The intent of this NSF grant-funded project was to help better convey the impact of 
	natural disasters to a lay audience (to individuals that don't have a 
	technical background to understand raw data or spreadsheets), by visualizing
	it from a first-person perspective in a city-based environment. The Unity3D 
	project files (used to render the Desktop and VR modes of the 2 example
	experiences) are provided to allow users to try the project on their own 
	machine, and to see how the file structure to understand how we rendered 
	these complex and high-polygon scenes in real-time, from scientific software
	that normally has no pipeline for game or film software.

How to use:
* File 1) VR_Demos
	* This is the Windows 10 executable of the interactive game. To use, download 
		and unzip all contents (including subfolders) to a folder, and click 
		on "XR_ICoR_2021_v1-XX.exe" to open. In menu that appears, use mouse 
		to choose which scene to open. Use mouse and keyboard with on-screen 
		instructions to control "Desktop" version of scene, and use Oculus Rift 
		controllers with on-controller prompts to control "VR" version of scene. 
	* Minimum system requirements for VR mode include: 
		CPU: Intel i5 8th gen or better, 
		GPU: Nvidia GTX 1060 GPU or better, 
		RAM: 8 GB RAM or more (12 GB preferred), 
		Hard Drive: 6 GB of available space,
		VR Equipment: Oculus Rift S was used to develop VR scenes, 
			VR compatibility with other devices may vary.
	* Minimum system requirements for Desktop mode include:
		Same as above, but GPU can be as low as Intel UHD 620, if rendering at
		low resolution and "low quality" settings (specified in main menu of game).
	* Windows 10 is required to run this experience (due to compatibility with 
		high-end games and VR equipment). 
* File 2) Unity_3D_Models
	* This is the source code / directory for the original project. It was made 
		using Unity3D LTS v2019.4.2. Download Unity3D with this version or 
		later to open and modify the project. At the time of this writing,
		Unity3D offers legacy versions of its software, allowing users to 
		install the version originally used for this project.
	* Unzip all files and subfolders to a local directory before opening this
		project.







