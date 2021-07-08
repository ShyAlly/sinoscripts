# sinoscripts
Some useful scripts for sino

AutoIt v3.3.14.5
https://www.autoitscript.com/site/autoit/downloads/

BlueStacks v5
https://www.bluestacks.com/

# FAQ/TLDR/README

For the sake of this guide and for your sanity please make sure you downloaded all the scripts together into one folder.

Please make sure you have installed AutoIt3 and are running the game on BlueStacks 5 emulator.

#Instructions

Instead of actually clicking the script files you want to open up the script editor that came with AutoIt3. Run the program "SciTE Script Editor".

Open the script you want to run; currently there is:
	bluestacks5-colo.au3 - script for colloseum
	bluestacks5.au3 - all purpose sinoscript

To execute the script press F5, to abort the script press end (as in the actual end key).

If the script is properly executed a log screen will pop up indicating the time the script was executed and request you to target a bluestacks screen. Click anywhere on the BlueStacks window and the script shall then actually run.

#FAQ

1. I'm clicking the bluestacks windows and nothing is happening.
	
You can tell if the script is not running if it times out, is still 	stuck on the line to target a bluestacks windows, and/or if the mini AutoIt3 icon that pops up in your taskbar (bar at the bottom) is blinking with a red X across it. 

As of right now the problem is probably a window name class issue. Please rename your bluestacks window to at least for simplicity's sake contain "BlueStacks" and then add whatever you want afterwards. Case sensitivity is unknown but is probably just name/letter case defined.

2. I want to run the script on multiple bluestacks instances.

Current found solution - open another "SciTE Script Editor" and you'll then have an extra script editor window to do the same thing to your next bluestacks instance.