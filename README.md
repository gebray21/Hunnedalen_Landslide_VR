# Hunnedalen_Landslide_VR

Realistic Visualization of Debris flow type landslides through Virtual Reality

This project originally included 2 folders:
The first folder, Demo, is an already built unity project and the second folder, Unity_Project, contains all source codes.  


Description of the project:
* This project provides a VR (Virtual Reality)-compatible interactive 3D experience
of a debris flow in Hunnedalen, Norway. These 2 scenes are available in two different menues. 
The VR version is expreinced via VR headset while the desktop version through desktop window. 

* The simulated data for both Scenes was derived from Rapid Mass movement Simulation(RAMMS), a depth-averaged debris flow simulation. 
* The project is funded by NTNU's Digital Transformation initiative as part of World of Wild waters(WOWW). The objective is to integrate
 the results of the numerical simulation into VR platforms so that lay audiences (indivisuals wth no technical background to understand the results of the simulation)
can understand better the impact of debris flow disaster by visualizing
it from a first-person perspective in a VR simulated environment. The Unity3D 
project files (used to render the Desktop and VR modes of the 
experience) are provided to allow users to try the project on their own machine, and to see how the file structure to understand how we rendered 
these complex and high-polygon scenes in real-time, from scientific software that normally has no pipeline for game or film software.

How it was done:

* First, we need a computer with Unity installed to develop the framework. We used Windows, but Universal Windows platform, macOS and Linux can also be used, according to Unity manual. 
* Second, any Unity project can be built to be played in Windows, macOS, Linux, WebGL, Android, iOS and many XR (VR) platforms such as Oculus Quest 2. We tested our framework in Windows 10 and Oculus quest 2 and it worked well. The only challenge we expect in the mobile platforms is the size of our project. We will share our project as an open source and readers can test it for whatever platform they have.” 



How to use:
* File 1) VR_Demos
	* This is the Windows 10 executable of the interactive game. To use, download 
		and unzip all contents (including subfolders) to a folder, and click 
		on "Hunnedalen_VR.exe" to open for the VR version and "Hunnedalen_DSK.exe" for the desktop version. In menu that appears, use mouse and VR controllers(desktop and VR versions respectively) 
		to choose which graphics quality to apply. Use mouse and keyboard with on-screen 
		instructions to control "Desktop" version of scene, and use Oculus Queest 2 
		controllers with on-controller prompts to control "VR" version of scene. 
	* Minimum system requirements for VR mode include: 
		CPU: Intel i5 8th gen or better, 
		GPU: Nvidia GTX 1060 GPU or better, 
		RAM: 8 GB RAM or more (12 GB preferred), 
		Hard Drive: 6 GB of available space,
		VR Equipment: Oculus Quest 2 was used to develop VR scenes, 
			VR compatibility with other devices may vary.
	* Minimum system requirements for Desktop mode include:
		Same as above, but GPU can be as low as Intel UHD 620, if rendering at
		low resolution and "low quality" settings (specified in main menu of game).
	* Windows 10 is required to run this experience (due to compatibility with 
		high-end games and VR equipment). 
* File 2) Unity_project
	* This is the source code / directory for the original project. It was made 
		using Unity3D LTS v2021.3.2. Download Unity3D with this version or 
		later to open and modify the project. At the time of this writing,
		Unity3D offers legacy versions of its software, allowing users to 
		install the version originally used for this project.
	* Unzip all files and subfolders to a local directory before opening this
		project.







