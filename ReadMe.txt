original script was written by Hikibla but  numerous functions and code have evolved since then

Re-written/Modified by: Bootch
Current Version Date: 	191020 (10/20/19)
Resolution Setting:		1366x768 or 1280x720 (NOTE: 1366x768 long out of date)

******************************************************
*	LEVEL DETECTOR GEM FARM
******************************************************
This script is designed to farm gems and automatically progress through low level areas, then resetting and starting over the same mission
It achieves this by leveling click damage and champs but mostly allows for familiars to instant kill the mobs (note works best with at least 3 familiars for the autoloot)
It utilizes a pixel-color detector to determine when the game is changing levels and various events

/*NOTE: times are out of date*/
Overall my average run time from point to point is 8 min with 6 familiars and Torm Fav > 1e10 (fastest ive noted is 7:40) 
there are points where this can be speed up

******************************************************
*	Recent Changes:
****************************************************** 
	Version - 200301 (03/01/20)
		update: settings to account for latest UI changes from CNE
		update: changed how pixels are determined - now uses screen size vs window size (ie borders should now be ignored)
		update: split Settings into a 2 files this will allow the Settings File to be updated and shared without impacting users custom run settings
			MW_Settings_1280x720.ahk
			MW_Configuration.ahk
		update: removed code for High Rollers if needed again in future see version 191020 or earlier
		update: added debugging code to several functions
		update: remove code to place familiars (these should now be attached to the Formation being used)
		modified: roster functions to start looking at Champ1 slot vs ClickDamage button (to prevent issues with Familiars assigned to ClickDamage)
		
			
******************************************************		
*	WARNINGS/Potential Issues/Recommendations
******************************************************	
	Potential Issue:	If bottom IC Window is off screen script may not work properly (thx Cyber Nemesis)
	Required:			Ensure Level Up Button (bottom left corner) is set to UPG vs x1/10/100 (thx Cyber Nemesis)
	
	Warning:			Pausing Script while on Boss Level will throw off the Level Counter 
						(while script should still work may run an extra level and Leveling Champs/ClickDmg will be out of sync for that run)
	Wanring:			Typing Chest Codes with Script running may trigger the Formation Override instead of using the Setting assignment
	Recommended:		Pause Script prior to opening in game windows (store/inventory/etc)
	Disclaimer: 		Pixel Colors and Positions may need to be tweaked to run correctly for your system (but this should be a 1 time process)
	
******************************************************	
*	Script Customizing: (MW_Settings_1280x720.ahk)
******************************************************	
		global nMax_Level 				:= 30	;sets the level that the script will run to for each iteration	
	
	******************************************************
	*	Familiars
	******************************************************
		global gFamiliarCount 			:= 6	;number of familiars to use is REQUIRED if have < 3  familiars
												;NOTE: script handles a MAX of 6 familiars
		
	******************************************************
	*	Mouse Behavior
	******************************************************
		global gEnableAutoClick 		:= 0	;script will auto-click 10x for 100ms (upto 60 clicks/second)
		global gEnableMouseSweep 		:= 0	;script will sweep to collect gold/items (also requires gFamiliarCount < 3)
	
	******************************************************
	*	Formation to use during GemFarm
	******************************************************
			can set to whichever formation you have set up for Gem Farming
			if dont want to change it here the script will also Temporarily Save a Formation on Q/W/E KeyPress 
			NOTE: will revert back to default Formation on Scipt Reset/Reload
		global gFormation_NP 			:= "Q"	;Values: Q/W/E sets which formation to use when No Patron is Active 	(if changing use capital letters)
		global gFormation_M 			:= "Q"	;Values: Q/W/E sets which formation to use when Mirt is Active Patron 	(if changing use capital letters)
		global gFormation_V 			:= "Q"	;Values: Q/W/E sets which formation to use when Vajra is Active Active 	(if changing use capital letters)

	******************************************************
	*	Champ Leveling
	*		Set how Script Level Ups the Champs
	*			with either automated MouseClicks or use of the F-Keys
	*			MouseClick Leveling -- Limits Formation to Champs 1-8
	*			F-Key Leveling -- can use Champs 1-11 to include Champ 12 see belew		
	******************************************************
		global gLevelingMethod 			:= "M" 	;Values: M or F (set to M to use mouse while leveling or F to use Function keys)
		global gStopChampLeveling		:= 13	;script will stop leveling Champs after this Zone
		global gAllowF12_Leveling 		:= 0	;Values: 1 or 0 <-- default 1	
			CRITICAL WARNING: if using F-keys and leveling Slot 12 unless addressed this will SPAM Screenshots
			To Enable F12 Leveling:	need to set --> gLevelingMethod := "F" and gAllowF12_Leveling := 1		

	******************************************************	
	*	Early Priority Champ Leveling
	******************************************************
		SEARCH FOR [ SPECIAL LEVELING ON z1 ] in MadWizard.ahk (approx line 1018)
			Additional Champs can be added by adding --> LevelUp(RosterSlot, NumTimesToLevel)
			Common Champs:
				LevelUp(1, 9)	;deekin speed buff
				LevelUp(6, 8) 	;shandie dash1
				LevelUp(6, 18)	;shandie dash2
				LevelUp(7, 4)	;minc extra mob
			
	******************************************************
	*	Champ Specialization Options
	******************************************************
		these values will determine which specialization to select for each champ based on default (or temp formation selected via keyboard)
			if dont want to include a specific champ set their SpecialOption to -1
			see more info on this in the MW_Settings.ahk file
			global Champ1_SpecialOptionQ/W/E := 2	;deekin - epic tale
			global Champ2_SpecialOptionQ/W/E := 1	;cele - war domain
			global Champ3_SpecialOptionQ/W/E := 1	;nay
			global Champ4_SpecialOptionQ/W/E := 2	;ishi - clear them out
			global Champ5_SpecialOptionQ/W/E := 1	;cali
			global Champ6_SpecialOptionQ/W/E := 1	;ash - humans
			global Champ7_SpecialOptionQ/W/E := 2	;minsc - beasts
			global Champ8_SpecialOptionQ/W/E := 2	;hitch - cha
			global Champ9_SpecialOptionQ/W/E := 1	;tyril - moonbeam (even though code is currently limited to 1st 8 champs)	
		
******************************************************			
*	Additional Notes:
******************************************************
	on levels : 			1,6,11,... Click Damage is Maxed
	boss levels	: 			no special functions added at this time
	remaining even levels :	will attempt to level up even numbered champs 5 levels at time and assign Specializations as needed
	remaining odd levels :	will attempt to level up odd numbered champs 5 levels at time and assign Specializations as needed
	special levels : 
							1...waits for Mobs to Show -> places familiars -> waits for  initial Gold Collection -> does Early Priority Champ Leveling -> Maxs Click DMG
							14,64,..(orb levels) all available Ults will be triggered						

******************************************************
*	HOTKEYS
******************************************************
	`		: Pauses the Script
	F1		: (Help) -- Shows ToolTip with HotKey Info 
	F2		: starts the script to farm MadWizard to L30	
	F8		: shows stats for the current script run
	F9		: Reloads the script
	Up		: used to increase the Target Level by 10 till next Script Reset/Reload
	DOWN	: used to decrease the Target Level by 10 till next Script Reset/Reload
	Q/W/E	: will Temporarily Save the Formation Selected (w/ keyboard) till next Script Reset/Reload
