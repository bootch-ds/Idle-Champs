;NOTES / Potential Issues
;these values are based on the gaming running at 1280x720 (windowed)
;values may not match if running game full screen

;----------------------------
;	Script Settings
;	Ideally these should not need to be modified by the user
;	Unless CNE tweaks the UI
;----------------------------	
;campaign buttons/locations
	global worldmap_favor_x := 1250			; pixel in favor box (top right of world map screen)
	global worldmap_favor_y := 85 ;115					 
	global worldmap_favor_c1 := 0x282827	;dark brown/gray
	global worldmap_favor_c2 := 0x282827	;second color added to correct for possible error when last campaign was an Event 

	global swordcoast_x	:= 75				; horizontal location of sword coast button	
	global swordcoast_y	:= 100				; vertical location of sword coast button	
	global toa_x 		:= 75				; horizontal location of ToA Button
	global toa_y		:= 170				; vertical location of ToA Button	

;Sword Coast Town with Mad Wizard Adventure
;	there are different positions for the town with the MadWizard adventures based on user progression
;	code will search top to bottom to find all the towns and based on findings determine the correct town for MadWizard runs
	global townsearch_L		:= 400 	
	global townsearch_R		:= 1000
	global townsearch_T		:= 100
	global townsearch_B		:= 700
	global townsearch_C		:= 0xB5AFA9 		;grey/brown-ish

;Patron Detect - unique pixels roughly in the foreheads of the Patrons
	global patron_X 		:= 1095
	global patron_Y			:= 210 
	global patron_NP_C		:= 0x303030
	global patron_M_C		:= 0xD5B6AC
	global patron_V_C		:= 0xA37051
	
; red pixel for the Close Button on the Adventure Select window
	global select_win_x 	:= 1040			
	global select_win_y 	:= 30
	global select_win_c1	:= 0xAF0202 	;red-ish

; pixel to check if list is scrolled to the top (if valid then list needs to scroll up)
	global list_top_x		:= 545			
	global list_top_y		:= 50
	global list_top_c1		:= 0x0A0A0A		;almost solid back (slider background color)				

;searchbox for a pixel in the MadWizard FP Picture displayed in the Adventure Select List
	global MW_Find_L 	:= 255				
	global MW_Find_R 	:= 475
	global MW_Find_T 	:= 65
	global MW_Find_B 	:= 670
	global MW_Find_C 	:= 0x728E57			;pixel in Mad Wizard's Eye
	global MW_Find_C2	:= 0x7C9861			;pixel in Mad Wizard's Eye (when hovered)

;searchbox to find Blue-ish pixel in the Mad Wizard Start Button
	global MW_Start_L	:= 575				
	global MW_Start_R	:= 1025
	global MW_Start_T	:= 500
	global MW_Start_B	:= 675
	global MW_Start_C	:= 0x4175B4			;Blue-ish (in middle of the 'O' in Objective)	
		
;adventure window pixel (redish pixel in the Redish Flag behind the gold coin in the DPS/Gold InfoBox)
	global adventure_dps_x	:= 70
	global adventure_dps_y	:= 10
	global adventure_dps_c1	:= 0x90181C
	global adventure_dps_c2 := 0x731316

;search box for 1st mob
	global mob_area_L	:= 750
	global mob_area_R	:= 1225
	global mob_area_T	:= 200
	global mob_area_B	:= 510
	global mob_area_C 	:= 0xFEFEFE			;almost solid white
	
;autoprogress check
	global autoprogress_x		:= 1244				; horizontal location of a green/white pixel in the autoprogress arrow
	global autoprogress_y		:= 105 				; vertical location of a green/white pixel in the autoprogress arrow
	global autoprogress_c1		:= 0x00FF00			; green color	
	
;variables for checking if a transition is occurring (center of screen and towards top)
	global transition_y 	:= 35 				;toward top of screen
	global transition_c1	:= 0x000000 		;black

;variables pertaining to manipulating the champion roster (and click damage upgrade)
	global roster_x			:= 239			; horizontal location of the a point in the upper left corner of the champ1 button
	global roster_y			:= 687			; vertical location of the a point in the upper left corner of the champ1 button
	global roster_c1		:= 0x58B831		; Green this used to check if Level Ups are ready
	global roster_c2		:= 0x5CCB2F		; Green Hover color
	global roster_b1		:= 0x589CDE		; Blue Bench Color (benched or not unlocked)
	global roster_b2		:= 0x5CABF7		; Blue Bench Hover Color (benched or not unlocked)
	global roster_g1		:= 0x8F8F8F		; Grey this used to check if Level Ups are ready (via a not check)	
	global roster_g2		:= 0x6B6B6B		; Grey this used to check if Level Ups are ready (if special window is open)		
	global roster_bg1		:= 0x8C8C8C		; Grey this used to check if Level Ups are ready (via a not check - bench champ)		
	global roster_bg2		:= 0x696969		; Grey this used to check if Level Ups are ready (if special window is open - bench champ)		
	global roster_spacing	:= 113			; distance between the roster buttons
	
;whitish pixel on Left Border of Champ1 - used to ensure Roster is Left Justified
	global roster_lcheck_x	:= 122						
	global roster_lcheck_y	:= 600
	global roster_lcheck_c1	:= 0x161616
	global roster_lcheck_c2	:= 0xB3B3B3

;checks the pixel in bottom left of the Upgrade Button (Square)
;	location is relative to the Found Pixel of the Champ Level Up Button
	global roster_upoff_x 	:= 80
	global roster_upoff_y	:= 16
	global roster_up_c1		:= 0xC94292			;purple without open window		
	global roster_up_c2		:= 0x97316D			;purple with open window		
	global roster_up_g1		:= 0x5B5B5B			;grey without open window 		
	
;red pixel for the close button of the Specialization Window
	global special_window_close_L	:= 0			;this will be screen left
	global special_window_close_R	:= 0			;this will be screen width
	global special_window_close_T	:= 75
	global special_window_close_B	:= 130
	global special_window_close_C	:= 0xCF0000
	
;find left most Green Specialization Select Button
	global special_window_L 		:= 0
	global special_window_R 		:= 0
	global special_window_T 		:= 550
	global special_window_B 		:= 625
	global special_window_C			:= 0x54B42D 	;color of green button
	global special_window_spacing 	:= 248

;Searchbox to find the Complete Button (Start Reset)
	global reset_complete_T		:= 450
	global reset_complete_B		:= 600
	global reset_complete_L		:= 500
	global reset_complete_R		:= 625
	global reset_complete_C		:= 0x54B42D		;green-ish
	global reset_complete_C2	:= 0x5AC030		;hover green
	
	
;Pixel location for the Skip Button (During Reset)
	global reset_skip_x		:= 1130
	global reset_skip_y		:= 640
	global reset_skip_c1	:= 0x449123		;green-ish

;Pixel location for the Continue Button (During Reset)
	global reset_continue_x		:= 565
	global reset_continue_y		:= 600	
	global reset_continue_c1	:= 0x4A9E2A		;green-ish

;familiar positions
	global fam_roster_top		:= 540
	global fam_roster_bottom	:= 600
	global fam_roster_c1		:= 0x5486C6

	global fam_1_x 	:= 950
	global fam_1_y 	:= 290
	global fam_2_x 	:= 880
	global fam_2_y 	:= 350
	global fam_3_x 	:= 1015
	global fam_3_y 	:= 350
	global fam_4_x 	:= 880
	global fam_4_y 	:= 420
	global fam_5_x 	:= 1015
	global fam_5_y 	:= 420
	global fam_6_x 	:= 950
	global fam_6_y 	:= 485
	global fam_CD_x := 160
	global fam_CD_y := 725
	global fam_U_x 	:= 420		;need work to find this location (changes with number of Ults unlocked)
	global fam_U_y 	:= 600		;need work to find this location (changes with number of Ults unlocked)
	
	
													