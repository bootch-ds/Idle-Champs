
;----------------------------
;	User Settings
;	various settings to allow the user to Customize how the Script behaves
;----------------------------			
	global nMax_Level 				:= 30	;sets the level that the script will run to for each iteration
	
	;Familiars
	global gFamiliarCount 			:= 6	;number of familiars to use is REQUIRED if have < 3  familiars
											;NOTE: script handles a MAX of 6 familiars
	;mouse behavior
	global gEnableAutoClick 		:= 0	;script will auto-click 10x for 100ms (upto 60 clicks/second)
	global gEnableMouseSweep 		:= 0	;script will sweep to collect gold/items (also requires gFamiliarCount < 3)

	;Formation to use during GemFarm
	;	can set to whichever formation you have set up for this script 
	;	if dont want to change it here the script will also Temporarily Save a Formation on Q/W/E KeyPress 
	;	NOTE: will revert back to default Formation on Scipt Reset/Reload
	global gFormation_NP 			:= "Q"	;Values: Q/W/E sets which formation to use when No Patron is Active 	(if changing use capital letters)
	global gFormation_M 			:= "Q"	;Values: Q/W/E sets which formation to use when Mirt is Active Patron 	(if changing use capital letters)
	global gFormation_V 			:= "Q"	;Values: Q/W/E sets which formation to use when Vajra is Active Active 	(if changing use capital letters)

	;Champ Leveling
	;	Set how Script Level Ups the Champs
	;		with either automated MouseClicks or use of the F-Keys
	;		MouseClick Leveling -- Limits Formation to Champs 1-8 
	;		F-Key Leveling -- can use Champs 1-11 to include Champ 12 see below		
	global gLevelingMethod 			:= "M" 	;Values: M or F (set to M to use mouse while leveling or F to use Function keys)
	global gStopChampLeveling		:= 13	;script will stop leveling Champs after this Zone
	global gAllowF12_Leveling 		:= 0	;Values: 1 or 0 <-- default 1	
		;----------------------
		;CRITICAL WARNING: if using F-keys and leveling Slot 12 unless addressed this will SPAM Screenshots
		;	To Enable F12 Leveling:
		;		need to set --> gLevelingMethod := "F" and gAllowF12_Leveling := 1
		;----------------------									
								
	;----------------------------
	;Champ Priority Leveling/Specialization 
	;	Setting Values
	;		NOTE: Script will determine the Current Patron or No Patron
	;		NOTE: if MouseClicking -- Script will look at Champs 1-8
	;		NOTE: if F(unction) Keys Enabled -- Script will look at Champs 1-11 and 12 if Enabled
	;	SPECIAL NOTE: 
	;		Script doesn't actually know which Champ is being used for example Champ1 could be any of Deekin/Bruenor/Kthriss/Turiel/Sisaspi
	;		this is determined by the Formation that is Saved for the gFormation_NP/M/V settings (above)
	;		any notes/comments with Champ Names below are just for reference
	;----------------------------
	;Champ Priority Leveling
	;	Set which SLOTS are leveled up with the inital gold drops
	;	prior to running the Automated Champ Leveling
	;
	;		Set Value to -1 if that SLOT is not to be Leveled Early
	;		Set Value Number to indicate the number upgrades (clicks) for the champ in that slot
	;	Additional Functionality
	;		If wish to use different options for Patrons
	;		NOTE: the DOUBLE QUOTES are required or only the 1st value will be read
	;		Set Value NoPatron_Option, Mirt_Option, Vajra_Option 
	;			Examples: 
	;				global Champ1 	:= "9|-1|9"	;deekin
	;					should level up SLOT 1 (Deekin) when running NoPatron or Vajra but skip SLOT 1 on Mirt
	;				global Champ6 	:= 18		;shandie
	;					should level up SLOT 6 (Shandie) for all Gem Runs
	;				global Champ3 	:= -1		;cele
	;					the Champ in SLOT 3 should not be added/leveled up early
	;----------------------------
	global Champ1	:= "9|-1|9"		;level up slot 1 (deekin) 9 times for No Patron and Vajra (wont do early leveling of Bruenor when on Mirt)
	global Champ2	:= -1
	global Champ3	:= -1
	global Champ4	:= -1
	global Champ5	:= -1
	;global Champ6	:= 8			;level up slot 6 (shandie) 8 times for All Runs (for lower favor amounts)
	global Champ6	:= 18			;level up slot 6 (shandie) 18 times for All Runs (for higher favor amounts)	
	global Champ7	:= "4|4|-1"		;level up slot 7 (minsc) 4 times for No Patron and Mirt (wont do early leveling of Black Viper on Vajra)
	global Champ8	:= -1
	global Champ9	:= -1
	global Champ10	:= -1
	global Champ11	:= -1
	global Champ12	:= -1
	
	;----------------------------
	;Champ Specialization Selection
	;		NOTE: if Value is not Valid; script will default to 1 
	;		NOTE: if Value is Out of Range (ie had Minsc and was set to 5 and switched to Black Viper) script will default to Option 1
	;
	;		Set Value to -1 if that SLOT is not to be Used (wont be leveled and should never get added to formation)
	;		Set Value 1-7 (depends on Champ's Options) to the Specialization Option you'd like for the Champ in that SLOT
	;
	;	Additional Functionality
	;		If wish to use different options for Patrons
	;		NOTE: the DOUBLE QUOTES are required or only the 1st value will be read
	;		Set Value NoPatron_Option, Mirt_Option, Vajra_Option 
	;			Examples: 
	;				global Champ1_SpecialOptionQ 	:= "2|1|2"	
	;					the Champ in SLOT 1 should use Spec. Option 2 when running NoPatron, Option 1 when running Mirt, Option 2 when running Vajra
	;				global Champ2_SpecialOptionQ 	:= 1		
	;					the Champ in SLOT 2 should use Spec. Option 1 for NoPatron, Mirt, and Vajra runs
	;				global Champ3_SpecialOptionQ 	:= -1		
	;					the Champ in SLOT 3 should not be added to formation and skip leveling regardless of the save formation being used
	;----------------------------
	;----------------------------
	;Champ Specialization selections will need to be set based on your formation	
	;----------------------------
	global Champ1_SpecialOptionQ 	:= "2|1|2"	;deekin,bruenor,deekin
	global Champ2_SpecialOptionQ 	:= 1		;cele
	global Champ3_SpecialOptionQ 	:= 1		;nay
	global Champ4_SpecialOptionQ 	:= 2		;jar,jar,paul
	global Champ5_SpecialOptionQ 	:= 1		;cali
	global Champ6_SpecialOptionQ 	:= 1		;shandie
	global Champ7_SpecialOptionQ 	:= "4|4|2"	;minsc,minsc,bv
	global Champ8_SpecialOptionQ 	:= 1		;hitch,hitch,walnut
	global Champ9_SpecialOptionQ 	:= -1		;makos
	global Champ10_SpecialOptionQ	:= -1		;tyril
	global Champ11_SpecialOptionQ 	:= -1		;strix
	global Champ12_SpecialOptionQ 	:= -1		;zorbu

	;----------------------------
	;Champ Specialization selections will need to be set based on your formation	
	;----------------------------
	global Champ1_SpecialOptionW 	:= 2		;deekin
	global Champ2_SpecialOptionW 	:= 1		;cele
	global Champ3_SpecialOptionW 	:= 1		;nay
	global Champ4_SpecialOptionW	:= 2		;jar,jar,paul
	global Champ5_SpecialOptionW 	:= 1		;cali
	global Champ6_SpecialOptionW 	:= 1		;shandie
	global Champ7_SpecialOptionW 	:= 2		;minsc
	global Champ8_SpecialOptionW 	:= 1		;hitch,hitch,walnut
	global Champ9_SpecialOptionW 	:= -1		;makos
	global Champ10_SpecialOptionW	:= -1		;tyril
	global Champ11_SpecialOptionW 	:= -1		;strix
	global Champ12_SpecialOptionW 	:= -1		;zorbu

	;----------------------------
	;Champ Specialization selections will need to be set based on your formation	
	;----------------------------
	global Champ1_SpecialOptionE 	:= "2|1|2"	;deekin,bruenor,deekin
	global Champ2_SpecialOptionE 	:= 1		;cele
	global Champ3_SpecialOptionE 	:= 1		;nay
	global Champ4_SpecialOptionE 	:= 2		;jar,jar,paul
	global Champ5_SpecialOptionE 	:= 1		;cali
	global Champ6_SpecialOptionE 	:= 1		;shandie
	global Champ7_SpecialOptionE 	:= "4|4|2"	;minsc,minsc,bv
	global Champ8_SpecialOptionE 	:= 1		;hitch,hitch,walnut
	global Champ9_SpecialOptionE 	:= -1		;makos
	global Champ10_SpecialOptionE	:= -1		;tyril
	global Champ11_SpecialOptionE 	:= -1		;strix
	global Champ12_SpecialOptionE 	:= -1		;zorbu

