#SingleInstance force
;Mad Wizard Gem Farming Script
;by Bootch
;version: 191020 (10/20/19)
;original script by Hikibla 

;LEVEL DETECTOR GEM FARM
;Resolution Setting 1366x768 or 1280x720
;This script is designed to farm gems and automatically progress through low level areas, then resetting and starting over the same mission
;It achieves this by leveling click damage and champs but mostly allows for familiars to instant kill the mobs (note works best with at least 3 familiars for the autoloot)
;It utilizes a pixel-color detector to determine when the game is changing levels
;Overall my average run time from point to point is just under 6 min with 6 familiars and Torm Fav > 1e20 (with Deeking/Shandie/Minsc) 
;there are points where this can be speed up (like a few seconds lost here and there while leveling up the champs and the Level is already complete)

;Settings: Several Pixel Colors and Positions may need to be tweaked to run correctly for your system (but this should be a 1 time process) 
;NOTE Updates from CNE occassionally break the script

;Additional Notes:
;	on levels : 			1,6,11,... Click Damage is Maxed
;	boss levels	: 			no special functions added at this time
;	remaining even levels :	will attempt to level up even numbered champs 5 levels at time and assign Specializations as needed
;	remaining odd levels :	will attempt to level up odd numbered champs 5 levels at time and assign Specializations as needed
;	special levels : 
;							1...waits for  initial Gold Collection and then Levels Deekin up to L100 to ensure Confidence in the Boss is unlocked and Maxs Click DMG
;								may add additional for other benefits like Shandie for Dash and Minsc for Boastful(??)				
;							14,64,..(orb levels) all the Ults will be triggered 

;WARNINGS/Potential Issues/Recommendations
;Potential Issue: 	Having Title Bar turned off will create a shift in the Y values and Script wont be able find several Locations (Jadisero)
;Warning:			Pausing Script while on Boss Level will throw off the Level Counter 
;					(while script should still work may run an extra level and Leveling Champs/ClickDmg will be out of sync for that run)
;Recommended:		Pause Script prior to opening in game windows (store/high rollers/etc)

;Specialization Section in the MW_Settings_1366x768.ahk or MW_Settings_1280x720.ahk file
;Champ1_SpecialOptionQ := [NUMBER]
;number is the 1-N for which Specialization the script is to select for the ChampNumber
;Q is the assoicated formation Q/W/E
;use -1 as the SpecialOption to prevent this Champ from Leveling Up/being added

;HOTKEYS
;	`		: Pauses the Script
;	F1		: (Help) -- Shows ToolTip with HotKey Info 
;	F2		: starts the script to farm MadWizard to L30
;	F3		: enables High Roller functionality -- (by default) iterates through Levels 50-90 (10 at time) then resets back to L30
;	F8		: shows stats for the current script run
;	F9		: Reloads the script
;	Up		: used to increase the Target Level by 10
;	DOWN	: used to decrease the Target Level by 10
;	Q/W/E	: will Temporarily Save the Formation Selected (w/ keyboard) till next Script Reset/Reload

;#include MW_Settings_1366x768.ahk
#include MW_Settings_1280x720.ahk
#include MW_Configuration.ahk

;pixels will now be relative to the Screen vs Window <- should resolve issues with different Border Sizes
CoordMode, Pixel, Client
CoordMode, Mouse, Client
CoordMode, ToolTip, Client

;internal globals
global gFound_Error 	:= 0
global gDebug			:= 0

global gFormation		:= "-1"
global gLevel_Number 	:= 0
global gTotal_RunCount	:= 0
global gTotal_Bosses 	:= 0
global dtPrevRunTime 	:= "00:00:00"
global dtLoopStartTime 	:= "00:00:00"
global gTotal_RunTime 	:= "00:00:00"

;get and store the settings for the GameWindow
GetWindowSettings()
Init()
ShowHelpTip()

return

;HotKeys
{
	;Show Help
	#IfWinActive Idle Champions
	F1:: 
	{	
		ShowHelpTip()
		return
	}

	;strart runs
	#IfWinActive Idle Champions
	F2:: 
	{	
		Loop_GemRuns()
		return
	}

	;NOT USED
	#IfWinActive Idle Champions
	F3:: 
	{		
		return
	}

	;NOT USED
	#IfWinActive Idle Champions
	F4::
	{
		return
	}

	;testing hotkey
	#IfWinActive Idle Champions
	F5::
	{
		gDebug := 1
		
		;TestWindowSettings()
		;WorldMapWindow_Check()		
		;FindPatron()		
		;FindTown(x, y)
		;StartAdventure(x,y)
		;TestAdventureSelect()
		;AdventureWindow_Check(100)
		;FindMob()		
		;DisableAutoProgress()
		;ScrollRosterLeft()
		
		;CheckRosterButton1()
		;TestRosterButtons()
		;TestUpgradeButtons()
		;TestSpecializationWinClose()
		;TestSpecializationSelectButtons()
		
			;DoEarlyLeveling()
			;DoLevel(0)		
			;TestReadSpec(1)
			;TestReadPriorityLeveling(1)
			;AutoLevelChamps(2)
			;LevelUp(0)
			;LevelUp(4)
			;LevelUp(3,15)	
			;TestGetChampSpecValue(7) ;testing with slot1		
			;DoSpecial(3)		
		
		;TestTransition()
		;TestResetComplete()
		;TestResetSkip()
		;TestResetContinue()
		;ResetAdventure()
		
		;CheckPixelInfo(REPLACE_WITH_PIXEL_OBJECT)
		;MoveToPixel(gRosterButton)
		;TestFindPixel()
		;IsNewDay()
		;TestSend()
		;TestTraceBox()
		;MouseSweep()
		;MouseAutoClick()
		
		gDebug := 0
		return
	}

	;Get Pixel Info
	global gLastX := ""
	global gLastY := ""
	#IfWinActive Idle Champions
	F6::
	{
		;get current pixel info 
		MouseGetPos, outx, outy		
		
		PixelGetColor, oColor, outx, outy, RGB
		sText :=  "Current Pixel`nColor: " oColor "`n" "X,Y: " outx ", " outy		
		ToolTip, %sText%, 25, 200, 15
		
		gLastX := outx
		gLastY := outy
		
		return
	}

	;Get Pixel info for previous F6
	#IfWinActive Idle Champions
	F7::
	{
		;get last pixel info
		nX:= gLastX
		nY:= gLastY	
				
		PixelGetColor, oColor, nX, nY, RGB
		Sleep, 500
		MouseMove, nX, nY, 5	
		
		sText :=  "Prev Pixel`nColor: " oColor "`n" "X,Y: " nX ", " nY		
		ToolTip, %sText%, 25, 260, 16
		
		return
	}

	;Show Total Farm Stats
	#IfWinActive Idle Champions
	F8:: 
	{	
		ShowStatsTip()
		return
	}

	;Reset/Reload Script
	#IfWinActive Idle Champions
	F9:: 
	{
		Reload
		return
	}

	#IfWinActive Idle Champions
	~Q::
	{
		gFormation := "Q"
		return
	}
	#IfWinActive Idle Champions
	~W::
	{
		gFormation := "W"
		return
	}
	#IfWinActive Idle Champions
	~E::
	{
		gFormation := "E"	
		return
	}

	;+10 levels to Target Level
	#IfWinActive Idle Champions
	~Up::
	{
		nMax_Level := nMax_Level + 10
		ToolTip, % "Max Level: " nMax_Level, 25, 475, 2
		SetTimer, ClearToolTip, -1000 
		
		UpdateToolTip()
		
		return
	}

	;-10 levels to Target Level
	#IfWinActive Idle Champions
	~Down::
	{
		nMax_Level := nMax_Level - 10
		ToolTip, % "Max Level: " nMax_Level, 25, 475, 2
		SetTimer, ClearToolTip, -1000 
		
		UpdateToolTip()
		
		return
	}

	;toggle Pause on/off
	#IfWinActive Idle Champions
	~`::
	{
		Pause, , 1	
		return
	}
}

;ToolTips
{
	UpdateToolTip()
	{
		dtNow := A_Now
		dtCurrentRunTime := DateTimeDiff(dtLoopStartTime, dtNow)		
			
		sToolTip := "Prev Run: " dtPrevRunTime 	
		sToolTip := sToolTip "`nCurrent Run: " dtCurrentRunTime		
		sToolTip := sToolTip "`nTarget Level: " nMax_Level		
		sToolTip := sToolTip "`nCurrent Level: " gLevel_Number
		sToolTip := sToolTip "`nPatron: " (gCurrentPatron = "NP" ? "None" : (gCurrentPatron = "M" ? "Mirt" : (gCurrentPatron = "V" ? "Vajra" : "None")))
		
		ToolTip, % sToolTip, 25, 475, 1
	}

	global gShowHelpTip := ""
	ShowHelpTip()
	{
		gShowHelpTip := !gShowHelpTip
		
		if (gShowHelpTip)
		{
			ToolTip, % "F1: Show Help`nF2: Start Gem Farm`nF8: Show Stats`nF9: Reload Script`nUP: +10 to Target Levels`nDOWN: -10 to Target Levels`n``: Pause Script", 25, 325, 3
			SetTimer, ClearToolTip, -5000 
		}
		else
		{
			ToolTip, , , ,3
		}
	}

	global gShowStatTip := ""
	ShowStatsTip()
	{
		gShowStatTip := !gShowStatTip
		
		if (gShowStatTip)
		{
			nAvgRuntime := 0
			nEstGems := Format("{:i}" , (gTotal_Bosses * 7.5)) ;convert to int
			nAvgRuntime := TimeSpanAverage(gTotal_RunTime, gTotal_RunCount)
			
			ToolTip, % "Total Time: " gTotal_RunTime "`nAvg Run: " nAvgRuntime "`nRun Count: " gTotal_RunCount "`nBoss Count: " gTotal_Bosses "`nEst. Gems: " nEstGems "*`n* 7.5 per boss", 25, 350, 3
			SetTimer, ClearToolTip, -10000 
		}
		else
		{
			ToolTip, , , ,3
		}
	}
	
	;a common tooltip with up to 5 lines
	;limits the tooltip to last 5 messages in event script is spamming messages
	global gToolTip := ""
	ShowToolTip(sText := "")
	{	
		if (!sText)
		{
			gToolTip := ""
		}
		
		dataitems := StrSplit(gToolTip, "`n")
		nCount := dataitems.Count()
		gToolTip := ""
		
		nMaxLineCount := 5
		nStartIndex := 0
		if (nCount >= nMaxLineCount)
		{
			nStartIndex := nCount - nMaxLineCount + 1
		}
		
		for k,v in dataitems
		{
			if (A_Index > nStartIndex)
			{
				if (gToolTip)
				{
					gToolTip := gToolTip "`n"
				}
				gToolTip := gToolTip v
			}
		}
		
		if (gToolTip)
		{
			gToolTip := gToolTip "`n" sText
		}
		else
		{
			gToolTip := sText
		}
		
		ToolTip, % gToolTip, 50, 150, 5
		return
	}

	ClearToolTip:
	{
		ToolTip, , , ,2
		ToolTip, , , ,3
		;ToolTip, , , ,5
		gToolTip		:= ""
		gShowHelpTip 	:= 0
		gShowStatTip 	:= 0
		return
	}
}

global gWindowSettings := ""
GetWindowSettings()
{
	if (!gWindowSettings)
	{
		if WinExist("Idle Champions")
		{
			WinActivate		
			WinGetPos, outWinX, outWinY, outWidth, outHeight, Idle Champions 
					
			gWindowSettings := []		
			gWindowSettings.X := 0
			gWindowSettings.Y := 0
			gWindowSettings.Width :=  outWidth - 20
			gWindowSettings.Height := outHeight - 40
			;MsgBox, % "error init window (this) -- `nScreen Size:" A_ScreenWidth ", " A_ScreenHeight "`nWindow Size: " outWidth ", "  outHeight
		}
		else
		{
			MsgBox Idle Champions not running
			return
		}
	}
	
	return gWindowSettings
}

;Init Globals/Settings
{
		global gRosterButton := ""			;pixel object to find the click damage button also used often to find champ level up buttons
		global gLeftRosterPixel := ""		;pixel object to help in scrolling champ roster left
		global gSpecialWindowClose := ""	;pixel search box to help determine if Specialization Window is showing
		global gSpecialWindowSearch := ""	;pixel search box to find green select buttons in the Specialization Windows
		global oPixReset_Complete := ""		;pixel search box to find green Complete Button (1st window on reset)
		global oPixReset_Skip := ""			;pixel object to find green Skip Button (2nd window on reset)
		global oPixReset_Continue := ""		;pixel object to find green Continue Button (2nd window on reset)
	Init()
	{
		gFound_Error := 0
		
		;init click damage button -- rest of the buttons will be based of this positioning
		gRosterButton := {}
		gRosterButton.X 		:= roster_x
		gRosterButton.Y 		:= roster_y
		gRosterButton.Color_1 	:= roster_c1
		gRosterButton.Color_2 	:= roster_c2
		gRosterButton.Color_B1 	:= roster_b1
		gRosterButton.Color_B2 	:= roster_b2
		gRosterButton.Color_G1 	:= roster_g1
		gRosterButton.Color_G2 	:= roster_g2
		gRosterButton.Color_BG1 := roster_bg1
		gRosterButton.Color_BG2 := roster_bg2	
		gRosterButton.Spacing 	:= roster_spacing
		
		gLeftRosterPixel := {}
		gLeftRosterPixel.X 			:= roster_lcheck_x
		gLeftRosterPixel.Y 			:= roster_lcheck_y
		gLeftRosterPixel.Color_1	:= roster_lcheck_c1
		gLeftRosterPixel.Color_2	:= roster_lcheck_c2
		
		gSpecialWindowClose := {}
		gSpecialWindowClose.StartX	:= special_window_close_L
		gSpecialWindowClose.StartY 	:= special_window_close_T
		gSpecialWindowClose.EndX 	:= gWindowSettings.Width
		gSpecialWindowClose.EndY 	:= special_window_close_B
		gSpecialWindowClose.Color_1 := special_window_close_C	
		
		gSpecialWindowSearch := {}
		gSpecialWindowSearch.StartX		:= special_window_L
		gSpecialWindowSearch.StartY 	:= special_window_T
		gSpecialWindowSearch.EndX 		:= gWindowSettings.Width
		gSpecialWindowSearch.EndY 		:= special_window_B
		gSpecialWindowSearch.Color_1 	:= special_window_C
		gSpecialWindowSearch.Spacing 	:= special_window_spacing
		
		oPixReset_Complete := {}
		oPixReset_Complete.StartX 	:= reset_complete_L
		oPixReset_Complete.EndX 	:= reset_complete_R
		oPixReset_Complete.StartY 	:= reset_complete_T
		oPixReset_Complete.EndY 	:= reset_complete_B
		oPixReset_Complete.Color_1 	:= reset_complete_C
		oPixReset_Complete.Color_2 	:= reset_complete_C2
		
		oPixReset_Skip := {}
		oPixReset_Skip.X 		:= reset_skip_x
		oPixReset_Skip.Y 		:= reset_skip_y
		oPixReset_Skip.Color_1 	:= reset_skip_c1	
		
		oPixReset_Continue := {}
		oPixReset_Continue.X 		:= reset_continue_x
		oPixReset_Continue.Y 		:= reset_continue_y
		oPixReset_Continue.Color_1 	:= reset_continue_c1		
	}
}

;Main Loop
Loop_GemRuns()
{
	;fast check for Adventure Running --> will force a reset
	bAdventureWindowFound := AdventureWindow_Check(1)
	if (bAdventureWindowFound)
	{
		ResetAdventure()
	}
	
	while (!gFound_Error)
	{
		dtStart := A_Now
		dtLoopStartTime := A_Now
		
		dtPrevRunTime := DateTimeDiff(dtPrev, dtStart)		
		
		UpdateToolTip()		
		
		dtPrev := dtStart			
		
		gTotal_RunTime := TimeSpanAdd(gTotal_RunTime, dtPrevRunTime)
		
		;Set Campaign and Select Adventure if on World Map
		bAdventureSelected := SelectAdventure()
		
		if (bAdventureSelected)
		{
			;Loop Levels till Target Level Reached
			RunAdventure()
		}
		
		bAdventureWindowFound := AdventureWindow_Check(1)
		if (bAdventureWindowFound)
		{
			;Complete the Adventure
			ResetAdventure()
		}		
		
		gTotal_RunCount := gTotal_RunCount + 1
	}
	
	ShowToolTip("No Longer Looping Runs")
}

;Start a Run
{	
	SelectAdventure()
	{
		;fast check for Adventure Running --> will force a reset
		bAdventureWindowFound := AdventureWindow_Check(1)
		if (bAdventureWindowFound)
			return 0
		
		;ensure on the World Map before trying find/click buttons(pixels)
		if (!WorldMapWindow_Check())
			return 0
		
		; Zooms out campaign map
		CenterMouse()
		Loop 15											
		{
			MouseClick, WheelDown
			Sleep 5
		}	
		Sleep 100		
		
		;get Current Patron
		FindPatron()
		Sleep, 100
		
		;campaign switching to force world map resets/positions		
		; Select Tomb of Annihilation
		Click %toa_x%, %toa_y%      			
		Sleep 100
		
		; Select A Grand Tour
		Click %swordcoast_x%, %swordcoast_y%	
		Sleep 500
		
		if (!FindTown(town_x, town_y))
		{
			MsgBox, ERROR: Failed to find the Town
			return 0
		}
		MouseClick, L, town_x, town_y
		Sleep 250
		
		if (!StartAdventure(townX, townY))
			return 0

		return 1		
	}

		global oCornerPixel := ""
	WorldMapWindow_Check()
	{
		if (!oCornerPixel)
		{
			oCornerPixel := {}
			oCornerPixel.X := worldmap_favor_x
			oCornerPixel.Y := worldmap_favor_y		
		
			oCornerPixel.Color_1 := worldmap_favor_c1
			oCornerPixel.Color_2 := worldmap_favor_c2
		}
		
		bFound := 0		
		if (gDebug = 1)
		{
			bFound := WaitForPixel(oCornerPixel, 100)
		}
		else
		{
			;wait for up to 5 second with 4 checks per second for the Target Pixel to show
			bFound := WaitForPixel(oCornerPixel, 5000)
		}
		
		sText := ""
		if (bFound)
		{
			sText := "Success: You are currently on the World Map"
		}
		else
		{
			sText := "Error: Could not determine if you are on the World Map"
		
			PixelGetColor, oColor, worldmap_favor_x, worldmap_favor_y, RGB
			
			sText := sText "`nSearching For: " Format("0x{:X}", oCornerPixel.Color_1) " or " Format("0x{:X}", oCornerPixel.Color_2)
			sText := sText "`nColor Found: " oColor
			
			MouseMove, worldmap_favor_x, worldmap_favor_y
			sleep, 500			
		}
		
		if (gDebug or !bFound)
		{
			MsgBox, % sText		
		}		
				
		return bFound
	}
	
		global gCurrentPatron := ""
		global oPatron_NP := ""
		global oPatron_M := ""
		global oPatron_V := ""
	FindPatron()
	{
		if (!oCornerPixel)
		{
			oPatron_NP := {}
			oPatron_NP.X 		:= patron_X
			oPatron_NP.Y 		:= patron_Y
			oPatron_NP.Color_1 	:= patron_NP_C
		}
		if (!oCornerPixel)
		{
			oPatron_M := {}
			oPatron_M.X 		:= patron_X
			oPatron_M.Y 		:= patron_Y
			oPatron_M.Color_1 	:= patron_M_C
		}
		if (!oCornerPixel)
		{
			oPatron_V := {}
			oPatron_V.X 		:= patron_X
			oPatron_V.Y 		:= patron_Y
			oPatron_V.Color_1 	:= patron_V_C
		}
		
		gCurrentPatron := "NP"
		bFound := 0
		if (CheckPixel(oPatron_NP))
		{	
			gCurrentPatron := "NP"
			gFormation := gFormation_NP
			bFound := 1
		}
		if (CheckPixel(oPatron_M))
		{	
			gCurrentPatron := "M"
			gFormation := gFormation_M			
			bFound := 1
		}
		if (CheckPixel(oPatron_V))
		{
			gCurrentPatron := "V"
			gFormation := gFormation_V			
			bFound := 1
		}
		
		if (gFormation = -1)
		{
			gFormation := gFormation_%gCurrentPatron%
		}		
		
		if (gDebug)
		{
			if (bFound)
			{
				sText := "Success: Found a Patron `n" "Patron : " gCurrentPatron
			}
			else
			{
				sText := "Error: Failed to determine Current Patron"					
			}
			MsgBox, % sText
		}		
		return		
	}
	
		global oTown := ""
	FindTown(ByRef townX, ByRef townY)
	{
		if(!oTown)
		{
			oTown := {}
			oTown.StartX 	:= townsearch_L 
			oTown.EndX 		:= townsearch_R
			oTown.StartY 	:= townsearch_T
			oTown.EndY 		:= townsearch_B
			oTown.Color_1 	:= townsearch_C
			oTown.HasFound 	:= -1
			oTown.FoundX 	:= ""
			oTown.FoundY	:= ""
		}
		
		;once found for this Script Run saves the position till reset/restart
		;skips searches for future loop iterations
		if (oTown.HasFound = 1 && !gDebug)
		{
			townX := oTown.FoundX
			townY := oTown.FoundY
			return 1
		}
		
		;needs to reset Top (Y) position each time this is called
		oTown.StartY 	:= townsearch_T
				
		nTownCount 	:= 0
		bSearching	:= 1
		bFoundTown 	:= 0
		while (bSearching = 1)
		{		
			bSearching := FindPixel(oTown, found%A_Index%_X, found%A_Index%_Y)
			if (bSearching = 1)
			{
				nTownCount := nTownCount + 1
				oTown.StartY := found%A_Index%_Y + 25	
				
				bFoundTown := 1				
			}
			else
			{
				;MsgBox, Didnt Find Town
			}
			sleep, 50
		}
		
		if (nTownCount = 5)
		{
			townX := found4_X
			townY := found4_Y			
		}
		if (nTownCount = 4)
		{
			townX := found3_X
			townY := found3_Y			
		}
		;NOTE: for current map this should not occur and handled by (nTownCount = 2)
		if (nTownCount = 3)	
		{
			townX := found3_X
			townY := found3_Y
		}
		if (nTownCount = 2)	 
		{
			;an arbitrary position between the location of Town2 for Newer Players
			;for brand new players 	-> Town1 is Tutorial and Town2 is MadWizard
			;when WaterDeep unlocks -> Town1 is MadWizard and Town2 is WaterDeep (tutorial is off top of map)
			nX := 600
			
			;2 Towns Total - Tutorial + MadWizard
			if (found2_X < nX)	
			{
				townX := found2_X
				townY := found2_Y
			}
			;3 Towns Total - Tutorial + MadWizard + WaterDeep
			;Tutorial Town off/at edge top of screen
			else				
			{
				townX := found1_X
				townY := found1_Y
			}			
		}
		if (nTownCount = 1)	;MadWizard not available yet
		{
			bFoundTown := 0
			MsgBox, Error: It appears that you haven't completed the tutorial yet.
		}
		
		if (bFoundTown = 1)
		{
			oTown.HasFound := 1
			townY := townY + 10 ;move the Y locations slightly lower
			oTown.FoundX := townX
			oTown.FoundY := townY
		}
		
		if (gDebug)
		{
			sText := "Debugging`nFound " nTownCount " towns`nMouse should have move to the Town for Mad Wizard"
			MouseMove, oTown.FoundX, oTown.FoundY, 5
			MsgBox, % sText					
		}
		
		return bFoundTown
	}

		global oSelect_WinChecker := ""
		global oListScroll_Checker := ""
		global oAdventureSelect := ""
		global oAdventureStart := ""
	StartAdventure(townX, townY)
	{
		if (gDebug)
		{
			gDebug := 0 			;Turn off Debugging Messages for FindTown()
			FindTown(townX, townY)
			gDebug := 1				;Turn Debugging Messages back on
			
			MouseClick, L, townX, townY
			Sleep 250
		}

		;ensure adventure select window is open
		if (!oSelect_WinChecker)
		{
			oSelect_WinChecker := {}
			oSelect_WinChecker.X 		:= select_win_x
			oSelect_WinChecker.Y 		:= select_win_y
			oSelect_WinChecker.Color_1 	:= select_win_c1
		}
	
		ctr := 0
		ctr_limit := 10
		if (gDebug)
		{
			ctr_limit := 1
		}
		;check 10 times in 5sec intervals for the Adventure Select Window show
		;server lag can cause issues between clicking the town and selector window displaying
		while (!bFound and ctr < ctr_limit)
		{
			;open adventure select window
			Click %town_x%, %town_y%				; Click the town button for mad wizard adventure
			Sleep 100
			
			;wait for 5 seconds for Selector window to show
			bFound := WaitForPixel(oSelect_WinChecker, 5000)
			ctr := ctr + 1
		}
			
		;failed to open the selector window in a timely manner
		if (!bFound)
		{
			if (gDebug)
			{
				MsgBox, ERROR: Failed to find the Adventure Select Window 
				sText := "Error: Could not Find the Adventure Select Window"
		
				PixelGetColor, oColor, oSelect_WinChecker.X, oSelect_WinChecker.Y, RGB
			
				sText := sText "`nSearching For: " Format("0x{:X}", oSelect_WinChecker.Color_1)
				sText := sText "`nColor Found: " oColor
			
				MoveToPixel(oSelect_WinChecker)				
				sleep, 500			
			}
			return 0
		}
		
		;ensure adventure select window is scrolled to top
		if (!oListScroll_Checker)
		{
			oListScroll_Checker := {}
			oListScroll_Checker.X 		:= list_top_x
			oListScroll_Checker.Y 		:= list_top_y
			oListScroll_Checker.Color_1 := list_top_c1
		}	
		
		;move mouse to a location inside the Adventure Select Window
		nX := ((MW_Find_L + MW_Find_R) / 2)
		nY := ((MW_Find_T + MW_Find_B) / 2)
		MouseMove, %nX%, %nY%
		
		ctr := 0
		bIsNotAtTop := CheckPixel(oListScroll_Checker)
		while (bIsNotAtTop and ctr < 50)
		{
			MouseClick, WheelUp
			
			bIsNotAtTop := CheckPixel(oListScroll_Checker)
			
			if (bIsNotAtTop)
				sleep, 50
				
			ctr := ctr + 1
		}
		;failed to verify list is scrolled to top
		if (bIsNotAtTop)
		{
			if (gDebug)
			{
				sText := "Failed to ensure list is scrolled to top"
		
				PixelGetColor, oColor, oListScroll_Checker.X, oListScroll_Checker.Y, RGB
			
				sText := sText "`nSearching For: " Format("0x{:X}", oListScroll_Checker.Color_1)
				sText := sText "`nColor Found: " oColor
				MoveToPixel(oListScroll_Checker)
				
				MsgBox, % sText				
				sleep, 500		
			}
			;not exitting out at this time as its still possible to find the MadWizard adventure
			;return 0
		}
		
		;mw adventure select
		if (!oAdventureSelect)
		{
			oAdventureSelect := {}
			oAdventureSelect.StartX 	:= MW_Find_L 
			oAdventureSelect.EndX 		:= MW_Find_R 
			oAdventureSelect.StartY 	:= MW_Find_T 
			oAdventureSelect.EndY 		:= MW_Find_B 
			oAdventureSelect.Color_1	:= MW_Find_C
			oAdventureSelect.HasFound 	:= -1
			oAdventureSelect.FoundX 	:= ""
			oAdventureSelect.FoundY		:= ""
		}
		
		if (oAdventureSelect.HasFound = 1)
		{
			foundX := oAdventureSelect.FoundX
			foundY := oAdventureSelect.FoundY
			
			MouseClick, Left, %foundX%,%foundY%
			sleep, 500
		}
		else
		{
			CenterMouse()
			sleep, 250				
			
			if (FindPixel(oAdventureSelect, foundX, foundY))
			{
				oAdventureSelect.HasFound 	:= 1
				oAdventureSelect.FoundX 	:= foundX
				oAdventureSelect.FoundY		:= foundY
				
				MouseClick, Left, %foundX%,%foundY%
				sleep, 500
			}
			else
			{
				sText := "Error Failed to find Mad Wizard in the Select List`n"
				sText := sText "On Close will trace the area its searching for the Mad Wizard's Eye"
				MsgBox, % sText
		
				TestTraceBox(oAdventureSelect)
				
				sleep, 500		
				return 0
			}
		}
		;Mad Wizard should now be selected and displayed in the Right Side of window
		
		;mw adventure start
		if (!oAdventureStart)
		{
			oAdventureStart := {}
			oAdventureStart.StartX 		:= MW_Start_L 
			oAdventureStart.EndX 		:= MW_Start_R
			oAdventureStart.StartY 		:= MW_Start_T
			oAdventureStart.EndY 		:= MW_Start_B
			oAdventureStart.Color_1		:= MW_Start_C
			oAdventureStart.HasFound	:= -1
			oAdventureStart.FoundX 		:= ""
			oAdventureStart.FoundY		:= ""
		}	
		
		if (oAdventureStart.HasFound != 1)
		{
			if (FindPixel(oAdventureStart, foundX, foundY))
			{
				oAdventureStart.HasFound := 1
				oAdventureStart.FoundX := foundX
				oAdventureStart.FoundY := foundY	
			}		
		}
		
		if (oAdventureStart.HasFound = 1)
		{
			foundX := oAdventureStart.FoundX
			foundY := oAdventureStart.FoundY
			
			if (gDebug)
			{
				MouseMove, foundX, foundY, 5
			}
			else
			{
				MouseClick, L, foundX, foundY
			}
			return 1
		}
		else
		{
			sText := "Error failed to find Adventure Start Button`n"
			sText := sText "On Close will trace the area its searching for the Blue Start Button"
			MsgBox, % sText
		
			TestTraceBox(oAdventureStart)
			return 0
		}		
	}
}	

;Handle Run Events.. Start/Transition/Reset
{
	RunAdventure()
	{
		;allowing for up to 30 seconds (vs the 5 sec default) to find the Adventure Window as server/game lag can cause varying time delays
		bAdventureWindowFound := AdventureWindow_Check(30000)
		if (!bAdventureWindowFound)
			return 0
		
		;wait for 1st mob to enter screen - wait upto 1min before Fails
		if (FindMob())
		{
			;continue script
			sleep, 100
		}
		else
		{
			return 0
		}
			
		;Ensure AutoProgress off to minimize issues with Specialization Windows getting stuck open
		;NOTE: spamming Send, {Right} to manage level progression
		DisableAutoProgress()		
			
		bContinueRun := 1
		gLevel_Number := 1
		UpdateToolTip()
		
		while (bContinueRun)
		{
			;ShowToolTip("Current Level: " gLevel_Number)		
			bRunComplete := DoLevel(gLevel_Number)		
			if (bRunComplete)
			{
				gLevel_Number := gLevel_Number + 1
							
				UpdateToolTip()
				
				if (gLevel_Number > nMax_Level)
				{
					bContinueRun := 0
				}			
			}
			else
			{
				bContinueRun := 0
			}
		}
	}

		global oAdventureWindowCheck := 0
	;allowing for up to 5 seconds (as default) to find the Adventure Window		
	AdventureWindow_Check(wait_time := 5000)
	{
		;redish pixel in the Gold/Dps InfoBox while an adventure is running
		if (!oAdventureWindowCheck)
		{
			oAdventureWindowCheck := {}
			oAdventureWindowCheck.X := adventure_dps_x
			oAdventureWindowCheck.Y := adventure_dps_y
			oAdventureWindowCheck.Color_1 := adventure_dps_c1
			oAdventureWindowCheck.Color_2 := adventure_dps_c2
		}
		
		;wait for up to 5 second with 4 checks per second for the Target Pixel to show
		bFound := WaitForPixel(oAdventureWindowCheck, wait_time)
		
		if (gDebug)
		{
			if (bFound)
			{
				sText := "Success: Found Pixel for the Adventure Window."
			}
			else
			{
				sText := "ERROR: Failed to find Adventure Window in a Timely Manner."			
			}
		
			PixelGetColor, oColor, adventure_dps_x, adventure_dps_y, RGB
			
			sText := sText "`nSearching For: " Format("0x{:X}", oAdventureWindowCheck.Color_1) " or " Format("0x{:X}", oAdventureWindowCheck.Color_2)
			sText := sText "`nColor Found: " oColor
			
			MouseMove, adventure_dps_x, adventure_dps_y
			
			MsgBox, % sText
		}		
		return bFound
	}
	
		global oMobName := ""
	FindMob()
	{
		if (!gMobName)
		{
			oMobName := {}
			oMobName.StartX := mob_area_L
			oMobName.EndX 	:= mob_area_R
			oMobName.StartY := mob_area_T
			oMobName.EndY 	:= mob_area_B	
			oMobName.Color_1 := mob_area_C
		}
		
		bFound := 0
		if (gDebug)
		{
			;while debugging only wait 10 seconds
			bFound := WaitForFindPixel(oMobName, outX, outY, 10000)
		}
		else
		{
			;NOTE: WaitForPixel() -- default performs search 4 times a second for 1 minute (240 times over 1 minute)
			bFound := WaitForFindPixel(oMobName, outX, outY)
		}
		
		if (gDebug)
		{
			if (bFound)
			{
				sText := "Success: Found some mobs`n"
			}
			else
			{
				sText := "Error: Failed to find mobs in time`n"				
			}
			
			sText := sText "On Close will trace the Search Area "
			MsgBox, % sText
			TestTraceBox(oMobName)
		}
		
		return bFound	
	}
	
		global oAutoProgress := ""
	DisableAutoProgress()
	{
		if (!oAutoProgress)
		{
			oAutoProgress := {}
			oAutoProgress.X 		:= autoprogress_x
			oAutoProgress.Y 		:= autoprogress_y
			oAutoProgress.Color_1 	:= autoprogress_c1
		}
		
		;checks against Green Color
		if (CheckPixel(oAutoProgress))
		{
			;disable AutoProgress if on
			Send, g
		}
		else
		{
			;Auto Progress is off .. transitions handled by Right Arrow Spamming			
		}	
		
		if (gDebug)
		{
			sText := "Returning Auto-Progess Pixel Info"
		
			PixelGetColor, oColor, autoprogress_x, autoprogress_y, RGB
			
			sText := sText "`nSearching For: " Format("0x{:X}", oAutoProgress.Color_1)
			sText := sText "`nColor Found: " oColor
			
			MouseMove, autoprogress_x, autoprogress_y						
			MsgBox, % sText
			sleep, 500			
		}		
	}	

	DoLevel(nLevel_Number)
	{	
		;new run Level 1
		if (nLevel_Number = 1)
		{
			sleep, 1000
			
			Send, %gFormation%
			sleep, 100
						
			;ensure roster is scrolled to left (should be for new run)			
			ScrollRosterLeft()
			
			;sweep till Gold is picked up
			if(gFamiliarCount < 3)
			{
				;sweep mob area till Champ1's level up button is green
				while (!CheckPixel(gRosterButton))
				{
					MouseSweep("UD")
				}
			}		
			
			;Wait for up to 10 seconds for the 1st Gold Gains
			if (!WaitForPixel(gRosterButton, 10000))
			{
				;took too long to find the Green ClickDamageButton - reset and try again
				;ToolTip, % "Failed to find the Click Damage Button", 50, 300, 10
				return 0			
			}			
			
			;SPECIAL LEVELING ON z1
			DoEarlyLeveling()			
		}
		
		;get wave number 1-5
		nWaveNumber := Mod(nLevel_Number, 5) 
		
		;Max Click Damage on 1st Level of each wave up till L100
		if (nWaveNumber = 1 and nLevel_Number < 101) 
		{
			LevelUp(0)
		}
		
		;note boss levels will be nWaveNumber = 0
		if (nWaveNumber and nLevel_Number <= gStopChampLeveling)
		{
			AutoLevelChamps(nLevel_Number)
			Send, %gFormation%
		}	
		
		DoLevel_MW(nLevel_Number)
		
		bContinueWave := 1
		while (bContinueWave)
		{
			IfWinActive, Idle Champions
			{
				Send, {Right}
			}
			else
			{	
				return
			}		
			
			bFoundTransition := CheckTransition()
			if (bFoundTransition)
			{
				;wait for black pixel to pass this point (right side of screen)
				while(CheckTransition())
				{
					sleep, 100
				}
				bContinueWave := 0
			}
			else
			{
				if (gFamiliarCount < 3 and gEnableMouseSweep = 1 and nWaveNumber)
				{
					MouseSweep()
				}
				if (gEnableAutoClick = 1)
				{
					;note: could add slight delay in transitions < 1s per zone
					MouseAutoClick()
				}
				else
				{
					sleep, 100
				}
			}
		}
		
		if (bFoundTransition)
		{
			;completed a boss level
			if (nWaveNumber = 0)
			{
				gTotal_Bosses := gTotal_Bosses + 1
			}
			
			return 1
		}
		else
		{
			return 0
		}
	}

	DoLevel_MW(nLevel_Number)
	{
		;spam ults for Levels 14/64/...
		nSpecial_Level := Mod(nLevel_Number, 50) 
		if (nSpecial_Level = 14)
		{
			sleep, 500
			Loop, 9
			{
				Send, %A_Index%
				Sleep, 100
			}
		}		
	}
	
	MouseSweep(sDirection := "UD")
	{
		;sDirection := "UD" ;LR or UD
		startx 	:= mob_area_L
		endx 	:= mob_area_R
		starty 	:= mob_area_T			
		endy	:= mob_area_B		
		vertical_step := ((endy - starty) / 4)    	;used for left->right up->down sweeping
		horizontal_step := ((endx - startx) / 4)	;used for up->down left->right sweeping
			
		if (sDirection = "UD")
		{
			Loop, 4
			{
				if (CheckTransition())
				{
					return
				}
				MouseMove, (startx + (horizontal_step * A_Index)), starty, 5
				MouseMove, (startx + (horizontal_step * A_Index)), endy, 5
			}			
		}
		else
		{
			Loop, 4
			{
				if (CheckTransition())
				{
					return
				}
				MouseMove, startx, (starty + (vertical_step * A_Index)), 5
				MouseMove, endx, (starty + (vertical_step * A_Index)), 5
			}
		}		
	}
	
	MouseAutoClick()
	{
		CenterMouse()
		Loop, 10
		{
			if (CheckTransition())
			{
				return
			}
			Click
			sleep, 10
		}
	}

		
	ResetAdventure()
	{
		IfWinActive, Idle Champions
		{
			Send, R
		}
		else
		{	
			return
		}
		
		bFound := 0		
		if (oPixReset_Complete.HasFound = 1)
		{
			if (WaitForPixel(oPixReset_Complete))
			{
				bFound := 1
				ClickPixel(oPixReset_Complete)
			}
		}
		else
		{
			;NOTE: WaitForFindPixel_Moving() -- default 4 times a second for 1 minute (240 times over 1 minute)
			if (WaitForFindPixel_Moving(oPixReset_Complete, outX, outY))
			{
				;NOTE: this will be tend to be in the upper left corner (just move down and right a bit)
				oPixReset_Complete.X := outX + 15
				oPixReset_Complete.Y := outY + 15
				
				PixelGetColor, oColor, oPixReset_Complete.X, oPixReset_Complete.Y, RGB
				oPixReset_Complete.Color_1 := oColor
				oPixReset_Complete.HasFound := 1
				
				bFound := 1
				ClickPixel(oPixReset_Complete)		
			}
		}
		;wait up to 30sec to click skip any longer it'll naturally go away
		if (bFound and WaitForPixel(oPixReset_Skip, 30000))
		{
			ClickPixel(oPixReset_Skip)
		}	
		
		if (bFound and WaitForPixel(oPixReset_Continue))
		{
			ClickPixel(oPixReset_Continue)	
		}
		return
	}

		gTransitionPixel_Left := ""
		gTransitionPixel_Right := ""
	;Level Transition Check
	CheckTransition()
	{
		if (!gTransitionPixel_Left)
		{
			gTransitionPixel_Left := {}
			gTransitionPixel_Left.X 		:= 10
			gTransitionPixel_Left.Y 		:= transition_y
			gTransitionPixel_Left.Color_1 	:= transition_c1
		}
		
		if (!gTransitionPixel_Right)
		{
			gTransitionPixel_Right := {}
			gTransitionPixel_Right.X 		:= gWindowSettings.Width - 10
			gTransitionPixel_Right.Y 		:= transition_y
			gTransitionPixel_Right.Color_1 	:= transition_c1
		}
		
		return (CheckPixel(gTransitionPixel_Left) or CheckPixel(gTransitionPixel_Right))
	}

}

;Roster/Champ Functions (Leveling + Specialization)
{
	GetChampEarlyLeveling(nChampNumber)
	{
		sVal := Champ%nChampNumber%
		if (sVal)
		{			
			if (InStr(sVal, "|"))
			{
				split_vals := StrSplit(sVal, "|")
				for k, v in split_vals
				{
					v := Trim(v)
				}
				
				nCount := SizeOf(split_vals)
				if (gCurrentPatron = "NP" and nCount > 0)
				{
					sVal := split_vals[1]
				}					
				else if (gCurrentPatron = "M" and nCount > 1)
				{
					sVal := split_vals[2]
				}
				else if (gCurrentPatron = "V" and nCount > 2)
				{
					sVal := split_vals[3]
				}	
				else if (nCount > 0)
				{
					sVal := split_vals[1]
				}				
			}
			
			if (sVal is integer)
			{
				return sVal
			}
		}
		return -1
	}
	
	GetChampSpecValue(nChampNumber)
	{
		if(gFormation != -1)
		{
			sVal := Champ%nChampNumber%_SpecialOption%gFormation%	
		}
		else
		{	
			sVal := Champ%nChampNumber%_SpecialOptionQ
		}
		
		;MsgBox, % "Champ_Number: " nChampNumber " Formation:" gFormation "`nSetting Text: " value 
		if (sVal)
		{			
			if (InStr(sVal, "|"))
			{
				split_vals := StrSplit(sVal, "|")
				for k, v in split_vals
				{
					v := Trim(v)
				}
				
				nCount := SizeOf(split_vals)
				if (gCurrentPatron = "NP" and nCount > 0)
				{
					sVal := split_vals[1]
				}					
				else if (gCurrentPatron = "M" and nCount > 1)
				{
					sVal := split_vals[2]
				}
				else if (gCurrentPatron = "V" and nCount > 2)
				{
					sVal := split_vals[3]
				}	
				else if (nCount > 0)
				{
					sVal := split_vals[1]
				}				
			}
			
			if (sVal is integer)
			{
				return sVal
			}			
		}
		return -1
	}
	
	DoEarlyLeveling()
	{
		MaxChampNumber := 9
		if (gLevelingMethod = "F")
		{
			MaxChampNumber := 12
			if (gAllowF12_Leveling = 1)
			{
				MaxChampNumber := 13
			}			
		}
		
		loop, %MaxChampNumber%
		{	
			nEarlyLevelVal := GetChampEarlyLeveling(A_Index)
			if (nEarlyLevelVal > 0)
			{
				LevelUp(A_Index, nEarlyLevelVal)
			}
		}
		return
	}
	
	AutoLevelChamps(level_number := 0)
	{	
		MaxChampNumber := 9
		if (gLevelingMethod = "F")
		{
			MaxChampNumber := 12
			if (gAllowF12_Leveling = 1)
			{
				MaxChampNumber := 13
			}			
		}
		
		if (level_number)
		{
			ctr := 1	
			is_even_level := (Mod(level_number, 2) = 0)
			if (is_even_level)
			{
				ctr := ctr + 1
			}
			
			while ctr < MaxChampNumber
			{	
				LevelUp(ctr, 5)
				ctr := ctr + 2
			}
		}
		else
		{
			loop, MaxChampNumber
			{		
				LevelUp(A_Index, 5)
			}
		}
		
		CenterMouse()
		
		return
	}
	
	LevelUp(champ_number, num_clicks := 1)
	{
		;max level up - click damage 
		if (champ_number = 0)
		{
			ScrollRosterLeft()
			
			ClickPixel := {}
			ClickPixel.X := 220
			ClickPixel.Y := 690
			ClickPixel(ClickPixel, "MAX")
			return
		}
		
		if (gLevelingMethod = "F")
		{
			LevelUp_FKey(champ_number, num_clicks)
		}
		else 
		{
			LevelUp_Mouse(champ_number, num_clicks)
		}
	}

	LevelUp_FKey(champ_number, num_clicks := 1)
	{
		;override for F12 not enabled
		if (champ_number = 12 and gAllowF12_Leveling = 0)
		{
			return
		}
		
		nSpecialOption := GetChampSpecValue(champ_number)

		;Specialization option is 0 or -1 (ie dont use this champ)
		if (nSpecialOption < 1)
		{
			return
		}		
		
		CenterMouse()
		
		Loop, %num_clicks%
		{
			Send {F%champ_number%}
			sleep, 25
		}
		
		;check if special window open
		sleep, 1000
		if (FindPixel(gSpecialWindowClose, foundX, foundY))
		{
			DoSpecial(nSpecialOption)
			sleep, 250
		}	
		if (FindPixel(gSpecialWindowClose, foundX, foundY))
		{
			DoSpecial(nSpecialOption)
		}
		return
	}

	;Levels/unlocks a champion or click damage
	LevelUp_Mouse(champ_number, num_clicks := 1)								
	{	
		;Click Leveling limited to 1st 8 champs
		if (champ_number > 8)
		{
			return
		}
		
		nSpecialOption := GetChampSpecValue(champ_number)
		
		;if Specialization option is 0 or -1 (ie dont use this champ)		
		if (nSpecialOption < 1)
		{
			return
		}
		
		;TODO: Add Scroll Right Functionality so get Champs on the Right
		if (champ_number < 9)
		{
			ScrollRosterLeft()
		}
		else
		{
			return
		}
			
		nX := gRosterButton.X + (gRosterButton.Spacing * (champ_number - 1))
		nY := gRosterButton.Y
		
		;get a fresh copy of ClickDamageButton (so dont alter values of the Original Object)
		;all properties of the champ buttons are same except for its X value (so only update this property)
		champ_button := gRosterButton.Clone()
		champ_button.X := nX
		
		;current champ button not green go to next champ
		if (!CheckPixel(champ_button))
		{		
			;ToolTip, % "champ not ready -- " champ_number , 50, (200 + (25 * champ_number)) , (10 + champ_number)
			Return
		}
		
		bGreyCheck := 0
		ctr := 0
		
		;spam clicks till Click Count reached or Button Greys out
		while (!bGreyCheck and ctr < num_clicks)
		{
			ClickPixel(champ_button)
			sleep, 100
			
			bGreyCheck := CheckGreyPixel(champ_button)			
			ctr := ctr + 1			
		}	
		
		;ensure the Game UI has completed the clicks
		;Game has a slight delay between Click and UI updating
		while (!bFound1)
		{		
			if (CheckGreyPixel(champ_button) or CheckPixel(champ_button))
			{
				bFound1 := 1
			}
			else
			{
				sleep, 100
			}
		}
		
		;upgrade button is relative to the champ_button
		up_button := {}
		up_button.X := nX + roster_upoff_x
		up_button.Y := nY + roster_upoff_y
		up_button.Color_1 := roster_up_c1
		up_button.Color_2 := roster_up_c2
		up_button.Color_G1 := roster_up_g1
		up_button.Color_G2 := roster_up_g2
			
		;check if Special Window is showing before continuing
		while (!bFound2 and bFound1)
		{		
			;upgrade button is Grey
			if (CheckGreyPixel(up_button))
			{
				bFound2 := 1
			}
			;upgrade button is purple
			if (CheckPixel(up_button))
			{
				DoSpecial(nSpecialOption)
			}		
			sleep, 100			
		}
		Return
	}

	ScrollRosterLeft()
	{
		;scroll roster left as required	
		nX := gWindowSettings.Width / 2
		nY := roster_y - 20
		
		bScrollRequired := !CheckPixel(gLeftRosterPixel)		
		if (bScrollRequired)
		{		
			MouseMove, nX, nY
			sleep, 100
		}
		
		ctr := 0
		while (bScrollRequired and ctr < 20)
		{
			MouseClick, WheelUp, nX, nY
			bScrollRequired := !CheckPixel(gLeftRosterPixel)
			ctr := ctr + 1
			sleep, 5
		}
		
		if (gDebug)
		{
			if (bScrollRequired)
			{
				sText := "Error: Failed to find Pixel to Stop the Scroll (should be Non-Critical)"
			}
			else
			{			
				sText := "Success: Found the Pixel to Stop the Scroll"
			}
			
			PixelGetColor, oColor, gLeftRosterPixel.X, gLeftRosterPixel.Y, RGB
			
			sText := sText "`n`nSearching For: " Format("0x{:X}", gLeftRosterPixel.Color_1)
			sText := sText "`nColor Found: " oColor
			sText := sText "`n`nScrolled Roster " ctr " Times"
			
			MoveToPixel(gLeftRosterPixel)		
			
			MsgBox, % sText
		}
	}

	DoSpecial(nSpecialOption)
	{
		bFound := 0

		;NOTE: WaitForFindPixel_Moving() -- default 4 times a second for 1 minute (240 times over 1 minute)
		if (WaitForFindPixel_Moving(gSpecialWindowClose, foundX, foundY))
		{
			window_closeX := foundX
			
			;find a Green Pixel for the First Select Button
			if (FindPixel(gSpecialWindowSearch, foundX, foundY))
			{
				bFound := 1
			}
			else
			{
				bFound := 0
			}
		}
		else
		{
			ToolTip, Failed to find Spec Window Close Box (Red Pixel), 50,200, 5
		}
		
		if (bFound)
		{
			nX := foundX + ((nSpecialOption - 1) * gSpecialWindowSearch.Spacing) + 5
			nY := foundY + 5
					
			;looks like Target Button not valid => click button 1 (not 100% accurate but should be 99%)
			if (nX > window_closeX)
			{
				;nSpacing := gSpecialWindowSearch.Spacing
				;rightX := gSpecialWindowClose.X
				;MsgBox, % "OUTSIDE SPECIAL WINDOW`n" "Special Opt:" nSpecialOption "`nSpacing: " nSpacing "`nStart:" foundX "`nCloseX:" rightX "`nClick_X:" nX
				nX := foundX + 5
			}
			
			;click special
			MouseClick, Left, nX, nY	
			
			;wait for Specialization Window to Slide off Screen
			;wait while still can still find the green pixels for the Spec Buttons
			while(FindPixel(gSpecialWindowSearch, foundX, foundY))
			{
				sleep, 100
			}		
			
			return 1
		}
		else
		{
			ToolTip, Failed to find Spec Option Boxes (1st Green Pixel), 50,225, 6
			;MsgBox,%  "Error failed to find Pixel for Special Window --" gSpecialWindowSearch.Color_1 " -- " gSpecialWindowSearch.StartX ", " gSpecialWindowSearch.StartY " -- " gSpecialWindowSearch.EndX ", " gSpecialWindowSearch.EndY
		}
		
		return 0	
	}
}

;Pixel Functions
{
	ClickPixel(oPixel, num_clicks := 1)
	{
		MoveToPixel(oPixel)
		sleep, 10
		
		if (num_clicks = "MAX")
		{
			Send, {LCtrl down}
			sleep, 50
			Click
			sleep, 50
			Send, {LCtrl up}
			sleep, 50
		}
		else
		{
			loop, %num_clicks%
			{
				Click
				sleep, 5
			}
		}	
	}

	MoveToPixel(oPixel)
	{
		nX := oPixel.X
		nY := oPixel.Y
		
		IfWinActive, Idle Champions
			MouseMove, nX, nY
	}

	CheckPixel(oPixel)
	{		
		nX := oPixel.X
		nY := oPixel.Y
		sColor_1 := oPixel.Color_1
		sColor_2 := oPixel.Color_2
		sColor_B1 := oPixel.Color_B1
		sColor_B2 := oPixel.Color_B2
		
		PixelGetColor, oColor, nX, nY, RGB	
		
		;NOTE: that pure black compares are tricky as same as null and can lead to false positives
		bFound := 0
		bFound := ((oColor = sColor_1) or bFound)
			
		if (sColor_2) 	
			bFound :=((oColor = sColor_2) or bFound)
		if (sColor_B1) 	
			bFound := ((oColor = sColor_B1) or bFound)
		if (sColor_B2) 	
			bFound := ((oColor = sColor_B2) or bFound)
		
		if(bFound)
		{
			return 1
		}
		else
		{
			;MsgBox, % sColor_1 " -- " sColor_2 " -- " sColor_B1 " -- " sColor_B2 " EOL"
			return 0
		}
	}

	CheckGreyPixel(oPixel)
	{		
		nX := oPixel.X
		nY := oPixel.Y
		sColor_1 := oPixel.Color_G1
		sColor_2 := oPixel.Color_G2
		sColor_B1 := oPixel.Color_BG1
		sColor_B2 := oPixel.Color_BG2
		
		PixelGetColor, oColor, nX, nY, RGB	
		
		bFound := 0
		bFound := ((oColor = sColor_1) or bFound)
			
		if (sColor_2) 	
			bFound :=((oColor = sColor_2) or bFound)		
		if (sColor_B1) 	
			bFound := ((oColor = sColor_B1) or bFound)
		if (sColor_B2) 	
			bFound := ((oColor = sColor_B2) or bFound)
		
		if(bFound)
		{
			return 1
		}
		else
		{
			;MsgBox, % sColor_1 " -- " sColor_2 " -- " sColor_B1 " -- " sColor_B2 " EOL"
			return 0
		}
	}

	;searchs for a Pixel within a Defined Rectangle
	FindPixel(oPixel, ByRef foundX, ByRef foundY)
	{
		nStartX := oPixel.StartX
		nStartY := oPixel.StartY
		nEndX := oPixel.EndX
		nEndY := oPixel.EndY
		
		if (!nStartX) 	
			nStartX := 0
		if (!nStartY) 	
			nStartY := 0
		if (!nEndX) 	
			nEndX := gWindowSettings.Width
		if (!nEndY) 	
			nEndY := gWindowSettings.Height
		
		bFound := 0
		
		PixelSearch, foundX, foundY,  nStartX, nStartY, nEndX, nEndY, oPixel.Color_1, , Fast|RGB
		if (ErrorLevel = 1)
		{
			;MsgBox, Error 1
		}
		else if (ErrorLevel = 2)
		{
			;MsgBox, Error 2
		} 
		else
		{
			;MsgBox, % "Found: " foundX ", " foundY "`nTop: " nStartX ", " nStartY "`nBottom: " nEndX ", " nEndY
			bFound := 1
		}
		return bFound
	}
		
	;default 4 times a second for 1 minute (240 times over 1 minute)
	WaitForPixel(oPixel, timer := 60000, interval := 250)
	{
		ctr := 0
		while (ctr < timer)
		{		
			ctr :=  ctr + interval			
			if (CheckPixel(oPixel))
				return 1

			sleep, %interval%	
		}
		return 0
	}	

	;default 4 times a second for 1 minute (240 times over 1 minute)
	WaitForFindPixel(oPixel, ByRef foundX, ByRef foundY, timer := 60000, interval := 250)
	{
		ctr := 0
		while (ctr < timer)
		{		
			ctr :=  ctr + interval			
			if (FindPixel(oPixel, foundX, foundY))
				return 1
			
			sleep, %interval%	
		}
		return 0
	}

	;default 4 times a second for 1 minute (240 times over 1 minute)
	WaitForFindPixel_Moving(oPixel, ByRef foundX, ByRef foundY, timer := 60000, interval := 250)
	{
		ctr := 0
		prevX := 0
		prevY := 0		
		
		;look for Pixel in Seach Box and Ensure it has stopped moving (ie found color in box with same X and Y values)
		while (ctr < timer)
		{		
			ctr :=  ctr + interval
			if (FindPixel(oPixel, foundX, foundY))
			{
				if (prevX = foundX and prevY = foundY)
				{
					return 1
				}
				else
				{
					;found pixel but still moving
					prevX := foundX
					prevY := foundY
				}
			}
			sleep, %interval%	
		}
		
		return 0		
	}
}

;HELPERS
{
	SizeOf(oArray)
	{
		ctr := 0
		for k, v in oArray
		{
			ctr := ctr + 1
		}
		return ctr
	}
	
	CenterMouse()
	{
		nX := gWindowSettings.Width / 2
		nY := gWindowSettings.Height / 2
		MouseMove, nX, nY
		
		Return
	}
	
	IsNewDay()
	{
		nHour_Now := 	A_Hour ;midnight is 00
		nMin_Now := 	A_Min
		nSec_Now := 	A_Sec
		;ToolTip, % "H:" nHour_Now " M:" nMin_Now " S:" nSec_Now " IsTrue: " (nHour_Now = (10 + nTimeZoneOffset) and nMin_Now > 0 and nMin_Now < 30) , 50, 100, 5
		
		;by default a New Day is flagged in 2:01AM to 2:15 range (CST) 
		return (nHour_Now = nAutoHR_Time and nMin_Now > 0 and nMin_Now < 16)
	}
		
	;return String HH:mm:ss of the timespan
	DateTimeDiff(dtStart, dtEnd)
	{
		dtResult := dtEnd
		
		EnvSub, dtResult, dtStart, Seconds
		
		nSeconds := Mod(dtResult, 60)
		nMinutes := Floor(dtResult / 60)
		nHours := Floor(nMinutes / 60)
		nMinutes := Mod(nMinutes, 60)
		
		sResult := (StrLen(nHours) = 1 ? "0" : "") nHours ":" (StrLen(nMinutes) = 1 ? "0" : "") nMinutes ":" (StrLen(nSeconds) = 1 ? "0" : "") nSeconds
		
		return sResult
	}

	TimeSpanAdd(ts1, ts2)
	{
		time_parts1 := StrSplit(ts1, ":")
		time_parts2 := StrSplit(ts2, ":")
		
		t1_seconds := (((time_parts1[1] * 60) + time_parts1[2]) * 60) + time_parts1[3]
		t2_seconds := (((time_parts2[1] * 60) + time_parts2[2]) * 60) + time_parts2[3]
		
		dtResult := t1_seconds + t2_seconds
		
		nSeconds := Mod(dtResult, 60)
		nMinutes := Floor(dtResult / 60)
		nHours := Floor(nMinutes / 60)
		nMinutes := Mod(nMinutes, 60)
		
		sResult := (StrLen(nHours) = 1 ? "0" : "") nHours ":" (StrLen(nMinutes) = 1 ? "0" : "") nMinutes ":" (StrLen(nSeconds) = 1 ? "0" : "") nSeconds
		
		return sResult
	}

	TimeSpanAverage(ts1, nCount)
	{
		time_parts1 := StrSplit(ts1, ":")
			
		t1_seconds := (((time_parts1[1] * 60) + time_parts1[2]) * 60) + time_parts1[3]
			
		if (!nCount)
		{
			return "00:00:00"
		}
		
		dtResult := t1_seconds / nCount	
		
		nSeconds := Floor(Mod(dtResult, 60))
		nMinutes := Floor(dtResult / 60)
		nHours := Floor(nMinutes / 60)
		nMinutes := Mod(nMinutes, 60)
		
		sResult := (StrLen(nHours) = 1 ? "0" : "") nHours ":" (StrLen(nMinutes) = 1 ? "0" : "") nMinutes ":" (StrLen(nSeconds) = 1 ? "0" : "") nSeconds
		
		return sResult
	}
}

;TEST Functions
{	
	TestWindowSettings()
	{
		nX := gWindowSettings.X
		nY := gWindowSettings.Y
		nW := gWindowSettings.Width
		nH := gWindowSettings.Height
		
		sText :=  "Window Size`nTop-Left: " nX ", " nY "`nWindow W,H: " nW ", " nH "`nScreen W,H: "   A_ScreenWidth ", "   A_ScreenHeight
		MsgBox, % sText
		return
	}

	CheckRosterButton1()
	{
			if (CheckPixel(gRosterButton))
			{
				sText := "INFO: Champ1 is Green"
			}
			else
			{			
				sText := "INFO: Champ1 is not Green"
			}
			
			PixelGetColor, oColor, gRosterButton.X, gRosterButton.Y, RGB
			
			sText := sText "`n`nSearching For: " Format("0x{:X}", gRosterButton.Color_1) " or " Format("0x{:X}", gRosterButton.Color_2)
			sText := sText "`nColor Found: " oColor
			sText := sText "`n`nScrolled Roster " ctr " Times"
			
			MoveToPixel(gRosterButton)		
			
			MsgBox, % sText
	}
	
	TestRosterButtons()
	{
		nX := roster_x
		nY := roster_y
		spacing := roster_spacing
		
		PixelGetColor, oColor1, nX, nY, RGB
			
		MouseMove, nX, nY
		sleep, 1000	
		
		PixelGetColor, oColor, nX, nY, RGB
		ToolTip, % "Champ Num: 1 -- Color Before: " oColor1 " Color After: " oColor , 50, 100, 5
				
		loop, 8
		{
			nX := roster_x + (A_Index * spacing)
			
			PixelGetColor, oColor1, nX, nY, RGB
			
			MouseMove, nX, nY
			sleep, 1000	
		
			PixelGetColor, oColor, nX, nY, RGB
			ToolTip, % "Champ Num: " (A_Index + 1)  " -- Color Before: " oColor1 " Color After: " oColor , 50, 100 + (A_Index * 25), (5 + A_Index)
		}
		return	
	}
	
	TestUpgradeButtons()
	{
		
		nX := roster_x + roster_upoff_x
		nY := roster_y + roster_upoff_y
		spacing := roster_spacing
		
		PixelGetColor, oColor1, nX, nY, RGB
			
		MouseMove, nX, nY
		sleep, 1000	
		
		PixelGetColor, oColor, nX, nY, RGB
		ToolTip, % "Champ Num: 1 -- Color Before: " oColor1 " Color After: " oColor , 50, 100, 5
				
		
		loop, 8
		{
			nX := roster_x + (A_Index * spacing) + roster_upoff_x			
			
			PixelGetColor, oColor1, nX, nY, RGB
			
			MouseMove, nX, nY
			sleep, 1000	
		
			PixelGetColor, oColor, nX, nY, RGB
			ToolTip, % "Champ Num: " (A_Index + 1) " -- Color Before: " oColor1 " Color After: " oColor , 50, 100 + (A_Index * 25), (5 + A_Index)
		}
		return	
	}
	
	TestSpecializationWinClose()
	{
		if (FindPixel(gSpecialWindowClose, foundX, foundY))
		{
			sText := "Success found Close Button"			
		}
		else
		{
			sText := "ERROR: Failed to Find Close Button"
			sText := sText "`nTopLeft: " gSpecialWindowClose.StartX ", " gSpecialWindowClose.StartY
			sText := sText "`nBottomRight:" gSpecialWindowClose.EndX ", " gSpecialWindowClose.EndY			
		}
			
		TestTraceBox(gSpecialWindowClose)
		
		;MouseMove, gWindowSettings.Width, gWindowSettings.Height, 10
		;sleep, 5000
		MsgBox, % sText
		return
	}
	TestSpecializationSelectButtons()
	{
		if (FindPixel(gSpecialWindowSearch, foundX, foundY))
		{
			sText := "Success found 1st Green Button"
		}
		else
		{
			sText := "ERROR: Failed to find a Green Special Select Button"
			sText := sText "`nTopLeft: " gSpecialWindowSearch.StartX ", " gSpecialWindowSearch.StartY
			sText := sText "`nBottomRight:" gSpecialWindowSearch.EndX ", " gSpecialWindowSearch.EndY	
		}
		TestTraceBox(gSpecialWindowSearch)
		
		MsgBox, % sText
		return
	}
	
	TestResetComplete()
	{
		if (WaitForFindPixel_Moving(oPixReset_Complete, outX, outY))
		{
			sText := "Success found the Complete Button"
		}
		else
		{
			sText := "ERROR: Failed to find a Complete Button"
			sText := sText "`nTopLeft: " oPixReset_Complete.StartX ", " oPixReset_Complete.StartY
			sText := sText "`nBottomRight:" oPixReset_Complete.EndX ", " oPixReset_Complete.EndY	
		}
		TestTraceBox(oPixReset_Complete)
		
		MouseMove, (outX + 15), (outY + 15), 5
		
		MsgBox, % sText
		return
	}
	TestResetSkip()
	{
		if (WaitForPixel(oPixReset_Skip, 1000))
		{
			sText := "Success found the Skip Button"
		}
		else
		{
			sText := "ERROR: Failed to find a Skip Button"
			
			PixelGetColor, oColor, oPixReset_Skip.X, oPixReset_Skip.Y, RGB
			
			sText := sText "`nSearching For: " Format("0x{:X}", oPixReset_Skip.Color_1) " or " Format("0x{:X}", oPixReset_Skip.Color_2)
			sText := sText "`nColor Found: " oColor			
		}

		MoveToPixel(oPixReset_Skip)				
		
		MsgBox, % sText
		return	
	}
	TestResetContinue()
	{
		if (WaitForPixel(oPixReset_Continue, 1000))
		{
			sText := "Success found the Continue Button"
		}
		else
		{
			sText := "ERROR: Failed to find a Continue Button"
			
			PixelGetColor, oColor, oPixReset_Continue.X, oPixReset_Continue.Y, RGB
			
			sText := sText "`nSearching For: " Format("0x{:X}", oPixReset_Continue.Color_1) " or " Format("0x{:X}", oPixReset_Continue.Color_2)
			sText := sText "`nColor Found: " oColor			
		}

		MoveToPixel(oPixReset_Continue)				
		
		MsgBox, % sText
		return
	}
	
	
	TestReadSpec(nChampNumber)
	{
		if(gFormation != -1)
		{
			sVal := Champ%nChampNumber%_SpecialOption%gFormation%	
		}
		else
		{	
			sVal := Champ%nChampNumber%_SpecialOptionQ
		}
		MsgBox, % "Champ_Number: " nChampNumber " Formation:" gFormation "`nSetting Text: " sVal 
		
		if (sVal)
		{			
			if (InStr(sVal, "|"))
			{
				split_vals := StrSplit(sVal, "|")
				for k, v in split_vals
				{
					v := Trim(v)
				}
				
				nCount := SizeOf(split_vals)
				
				MsgBox, % "Count: " split_vals.Count() " MaxIndex: " split_vals.MaxIndex() "SizeOf: " nCount
				if (gCurrentPatron = "NP" and nCount > 0)
				{
					sVal := split_vals[1]
				}					
				else if (gCurrentPatron = "M" and nCount > 1)
				{
					sVal := split_vals[2]
				}
				else if (gCurrentPatron = "V" and nCount > 2)
				{
					sVal := split_vals[3]
				}	
				else if (nCount > 0)
				{
					sVal := split_vals[1]
				}				
			}
			
			if (sVal is integer)
			{
				;return sVal
			}			
		}
		
		sval := GetChampSpecValue(nChampNumber)
		MsgBox,% sval
	}
	
	TestReadPriorityLeveling(nChampNumber)
	{
		sval := GetChampEarlyLeveling(nChampNumber)
		MsgBox,% sval
	}
	
	TestTransition()
	{
		bResult := CheckTransition()
		if (bResult)
		{
			ToolTip, % "Success found black Transition", 50, 100, 5
		}
		else
		{
			nX := gTransitionPixel.X
			nY := gTransitionPixel.Y
			
			ToolTip, % "ERROR: failed to find black Transition ---" nX ", " nY, 50, 100, 5
			MouseMove, nX, nY
		}
		return
	}

	TestGetChampSpecValue(champ_num)
	{
		gFormation := "Q"
		FindPatron()
		zz := GetChampSpecValue(champ_num)
		MsgBox, % zz
		return
	}
	
	
	
	
	
	
	TestFindPixel()
	{
		oPix1 := {}		
		oPix1.StartX := 625 
		oPix1.EndX 	:= 855 ;765
		oPix1.StartY := 235 ;435
		oPix1.EndY 	:= 310
		oPix1.Color_1 := 0xB5AFA9 ;0x462A11 ; 0x4a2c12 ; 0x73665A
		
		if (FindPixel(oPix1, foundX, foundY))
		{
			ToolTip, % "Success Found It", 50, 100, 5
			MouseMove, foundX, foundY
			sleep, 1000
			;return		
		}
		else
		{
			ToolTip, % "Error Cant Find", 50, 100, 5
		}
		
		nLeft :=	oPix1.StartX
		nRight :=	oPix1.EndX
		nTop := 	oPix1.StartY
		nBottom :=	oPix3.EndY	
			
	
		MouseMove, nLeft, nTop, 15
		sleep, 500
		MouseMove, nRight, nTop, 15
		sleep, 500
		MouseMove, nRight, nBottom, 15
		sleep, 500
		MouseMove, nLeft, nBottom,15 
		sleep, 500
		MouseMove, nLeft, nTop, 15
		sleep, 500

		return
	}

	

	CheckPixelInfo(oPixel)
	{
		if WinExist("Idle Champions")
		{
			WinActivate
		}
		
		PixelGetColor, oColor, oPixel.X, oPixel.Y, RGB	
		oPixel.FoundColor := oColor + 0 ;force convert to int	
		
		ToolTip, % "Color Found: " oPixel.FoundColor "`nSearch: " oPixel.X ", " oPixel.Y "`nC1: " oPixel.Color_1 "`nC2: " oPixel.Color_2 "`nG1: " oPixel.Color_G1 "`nG2: " oPixel.Color_G2, 50, 200, 18
		
		sleep, 250
		MoveToPixel(oPixel)
	}
	TestTraceBox(oPix)
	{
		if (oPix)
		{
			nLeft :=	oPix.StartX
			nRight :=	oPix.EndX
			nTop := 	oPix.StartY
			nBottom :=	oPix.EndY
		}
		else
		{
			nLeft :=	mob_area_L
			nRight :=	mob_area_R
			nTop := 	mob_area_T 
			nBottom :=	mob_area_B
		}
		
		MouseMove, nLeft, nTop, 15
		sleep, 500
		MouseMove, nRight, nTop, 15
		sleep, 500
		MouseMove, nRight, nBottom, 15
		sleep, 500
		MouseMove, nLeft, nBottom,15 
		sleep, 500
		MouseMove, nLeft, nTop, 15
		sleep, 500
	}
	TestSend()
	{
		wintitle = Idle Champions
		SetTitleMatchMode, 2

		;ahk_class UnityWndClass
		;ahk_exe IdleDragons.exe
		
		Loop
		{
			ControlSend, , T, ahk_exe IdleDragons.exe
			sleep, 1000
		}
		
		;IfWinExist %wintitle% 
		;{
		;	ToolTip, here, 50, 50, 17
			;Controlsend,,T, ahk_id IdleDragons.exe  ; <-- this is the proper format
			;Controlsend,,T, ahk_class UnityWndClass  ; <-- this is the proper format
		;	Send T
		;    sleep 500   
		;}
		Return
	}

}



