#include "common.au3"

; Controls
HotKeySet("{end}", "end")
HotKeySet("{insert}", WriteColorCheck)
;HotKeySet("{home}", PuriCircle)

; This is for Bluestacks v5
; 540x960 portrait resolution
; 160 DPI
; 60 FPS
; DirectX Compatibility
; Sidebar closed
; Controls hidden

; In-game settings:
; High Quality
; Skip seen scenes

; 0 means "no" or "off"
; 1 means "on" or "yes"

$maxRetry = 20000                 ; Maximum number of times to repeat a map
$maxScriptTime = 3000 * 60 * 1000 ; Maximum time to macro, in milliseconds
$puriLockoutTimeHours = 8         ; The number of hours to lock puri. 4 for RUS, 8 otherwise

$farmMastery = 0                  ; This is for farming Mastery from Study Hall
$clearStoryMode = 0               ; For clearing new content with a Next button
$coopMode = 1					  ; For clearing things in coop. 1 = random, 2 = friends, 3 = guild members
$avoidCompletedStories = 1        ; For avoiding stories already marked as Complete

$crystalRefresh = 0               ; Use twilight crystals to refresh
$puriRefresh = 1                  ; Use purification to refresh
$puriTicketRefresh = 0            ; Use Puri Tickets to refresh

; More internalish things
$puriRefreshLockoutPeriod = ((0*60)+0)* 60 * 1000		; Milliseconds until purification is ready
$maxTimeout = 150
$maxBattleTimeout = 1500
$writeColorCheckDelay = 500
$returnToHome = 0

$globalOffsetX = 10
$globalOffsetY = 10

$timeout = 0
$battleTimeout = 0

; Functions that change frequently

Func AdjustSettings($outOfAp)
   If $outOfAp AND Not $farmMastery AND $puriRefreshLockoutPeriod > GetElapsedTime() Then
	  $farmMastery = 1
	  $returnToHome = 1
	  Return
   EndIf

   If $farmMastery AND $puriRefreshLockoutPeriod > 0 AND $puriRefreshLockoutPeriod < GetElapsedTime() Then
	  $farmMastery = 0
	  $returnToHome = 1
   EndIf
EndFunc

Func IsCoopBattleGood()
   Return True
EndFunc

; Super internaly things

Func Test()
   Write("Testing")
   Click(175, 699, 0)
EndFunc

Func WriteColorCheck()
   $x = MouseGetPos(0) - $globalOffsetX
   $y = MouseGetPos(1) - $globalOffsetY

   Local $i
   Local $c1
   Local $r
   Local $g
   Local $b

   Local $minr = 255
   Local $ming = 255
   Local $minb = 255

   Local $maxr = 0
   Local $maxg = 0
   Local $maxb = 0

   Local $lastStr = ""
   Local $lastStrTime = 0

   While True
	  $c1 = PixelGetColor($x + $globalOffsetX, $y + $globalOffsetY)
	  $r = BitShift(BitAND($c1, 0xFF0000), 16)
	  $g = BitShift(BitAND($c1, 0xFF00), 8)
	  $b = BitAND($c1, 0xFF)

	  $minr = _Min($minr, $r)
	  $ming = _Min($ming, $g)
	  $minb = _Min($minb, $b)

	  $maxr = _Max($maxr, $r)
	  $maxg = _Max($maxg, $g)
	  $maxb = _Max($maxb, $b)

	  $r = Int(($maxr + $minr) / 2)
	  $g = Int(($maxg + $ming) / 2)
	  $b = Int(($maxb + $minb) / 2)

	  Local $vr = $maxr - $r
	  Local $vg = $maxg - $g
	  Local $vb = $maxb - $b

	  Local $v = _Max(_Max($vr, $vg), $vb)

	  Local $str = "PixelCheck("&$x&", "&$y&", 0x"&Hex($r,2)&Hex($g,2)&Hex($b,2)&", "&($v+10)&")"

	  If $str = $lastStr Then
		 If GetElapsedTime() - $lastStrTime > $writeColorCheckDelay Then
			ExitLoop
		 EndIf
	  Else
		 $lastStrTime = GetElapsedTime()
		 $lastStr = $str
	  EndIf
   WEnd

   Write($str)
   ClipPut($str)
EndFunc

; -------------------------------------------------------------------------------
; -------------------------------------------------------------------------------
; -------------------------------------------------------------------------------

Func OnStoryStart()
   $battleTimeout = 0
EndFunc

Func OnBattleTick()
	$timeout = 0
EndFunc

; -------------------------------------------------------------------------------
; -------------------------------------------------------------------------------
; -------------------------------------------------------------------------------

$_IsPuriSkillActive_Response = 0
$_IsPuriSkillActive_Time = 0
Func IsPuriSkillActive()
   Local $nowTime = GetElapsedTime()
   If $nowTime - $_IsPuriSkillActive_Time < 1 Then
	  Return $_IsPuriSkillActive_Response
   EndIf

   $_IsPuriSkillActive_Response = 0

   If (PixelCheck(197, 528, 0xFF8E2A, 45) OR PixelCheck(193, 530, 0xF3934B, 37) OR PixelCheck(190, 529, 0xFF8C30, 30) OR PixelCheck(192, 529, 0xFF8834, 34)) AND (PixelCheck(298, 529, 0xFD7F2A, 25) OR PixelCheck(304, 529, 0xF98C41, 30) OR PixelCheck(301, 528, 0xFA933F, 21) OR PixelCheck(298, 528, 0xFE8D37, 24)) Then
	  $_IsPuriSkillActive_Response = 1
   EndIf

   $_IsPuriSkillActive_Time = $nowTime
   Return $_IsPuriSkillActive_Response
EndFunc

$_IsPuriExitButton_Response = 0
$_IsPuriExitButton_Time = 0
Func IsPuriExitButton()
   Local $nowTime = GetElapsedTime()
   If $nowTime - $_IsPuriExitButton_Time < 1000 Then
	  Return $_IsPuriExitButton_Response
   EndIf

   $_IsPuriExitButton_Response = 0
   ; Standard OK button
   If PixelCheck(154, 857, 0x2A2212, 10) AND PixelCheck(199, 855, 0x9B3820, 10) AND PixelCheck(328, 853, 0x2A2118, 10) Then
	  $_IsPuriExitButton_Response = 1
   EndIf

   ; Darkened OK button from Rank Up
   If PixelCheck(157, 855, 0x090704, 10) AND PixelCheck(186, 849, 0x230E08, 10) AND PixelCheck(332, 851, 0x0B0905, 10) Then
	  $_IsPuriExitButton_Response = 1
   EndIf

   $_IsPuriExitButton_Time = $nowTime
   Return $_IsPuriExitButton_Response
EndFunc

Func PuriCircle()
   Local $var = 5

   $puriRefreshLockoutPeriod = GetElapsedTime() + ($puriLockoutTimeHours * 60 * 60 * 1000)

   ; The dead center locations of each puri victim
   Local $realPositions[16] = [374, 473, 383, 591, 352, 729, 228, 716, 110, 646, 93,  510, 160, 393, 287, 378]

   ; Build 5 points between each real point
   Local $positionMultiplier = 1
   Local $positions[$positionMultiplier*16]

   Local $i = 0
   While $i < 16
	  Local $a = 0
	  While $a < $positionMultiplier
		 Local $positionOffset = ($i*$positionMultiplier)+(2*$a)

		 Local $realX = $realPositions[$i+0]
		 Local $realY = $realPositions[$i+1]

		 Local $nextX = $realPositions[Mod($i+2,16)]
		 Local $nextY = $realPositions[Mod($i+3,16)]

		 Local $dx = Round(($nextX - $realX) * $a / $positionMultiplier)
		 Local $dy = Round(($nextY - $realY) * $a / $positionMultiplier)

		 $positions[$positionOffset+0] = $realX + $dx
		 $positions[$positionOffset+1] = $realY + $dy

		 ;Write("$positions[" & ($positionOffset/2) & "] = (" & $positions[$positionOffset+0] & ", " & $positions[$positionOffset+1] & ") comes from ("&$realX & ","&$realY&")->("&$nextX&","&$nextY&") step " & $a)

		 $a = $a + 1
	  WEnd

	  $i = $i + 2
   WEnd

   Write("Starting purify")

   ; It's basically impossible for there to be an exit
   ; after less than 35s
   $_IsPuriExitButton_Response = 0
   $_IsPuriExitButton_Time = GetElapsedTime() + 35000

   While True
      MoveMouse($positions[0], $positions[1], $var) ; Start
      HoldMouse(True)

      Local $i = 0
	  Local $expectedTime = GetElapsedTime()
      While True
         Local $x = $positions[$i]
         Local $y = $positions[$i+1]
         MoveMouse($x, $y, $var)

		 If IsPuriSkillActive() Then
			HoldMouse(False)

			Write("Special skill")

			Local $minimumClicks = 10
			While $minimumClicks > 0
			   If Not IsPuriSkillActive() Then
				  $minimumClicks = $minimumClicks - 1
			   EndIf
			   If IsPuriExitButton() Then
				  ExitLoop
			   EndIf
			   Click(241, 522, 8)
			   Sleep(50)
			WEnd

			Write("Special Skill Done")
			ExitLoop
		 EndIf

         If IsPuriExitButton() Then
            ExitLoop
         EndIf

         $i = Mod($i + 2, 16*$positionMultiplier)
      WEnd

      If IsPuriExitButton() Then
         ExitLoop
      EndIf
   WEnd

   Write("Exit button detected")
   Sleep(1000)

   ; Double While loop ensures that exit button stays hidden for 3+ seconds before we stop clicking
   ; This is due to animations being annoying
   While IsPuriExitButton()
	  While IsPuriExitButton()
		 Click(244, 855, 10)
		 Sleep(1000)
	  WEnd
	  Sleep(2000)
   WEnd

   Write("Purify complete")
EndFunc

; -------------------------------------------------------------------------------
; -------------------------------------------------------------------------------
; -------------------------------------------------------------------------------

$windowHandle = 0

Init()
Func Init()
   Write("Please focus the bluestacks window...")
   $windowHandle = WinWaitActive("BlueStacks")

   Write("Window found " & $windowHandle & " - retrieving children")

   Local $children = _WinAPI_EnumChildWindows($windowHandle)
   If @error <> 0 Then
	  Local $realHandle = _WinAPI_GetParent($windowHandle)
	  If @error <> 0 Then
		 Write("Failed secondary lookup: " & @error)
		 Exit
	  EndIf
	  Write("Window found " & $realHandle & " retrieving children")

	  $windowHandle = $realHandle
	  $children = _WinAPI_EnumChildWindows($windowHandle)
	  If @error <> 0 Then
		 Write("Failed secondary child lookup: " & @error)
		 Exit
	  EndIf

	  $globalOffsetX2 = 0
	  $globalOffsetY2 = -32
   Else
	  $globalOffsetX2 = -2
	  $globalOffsetY2 = -44
	  Write("Warning: This might not work. Are you using BlueStacks 4? This is made for 5")
   EndIf

   ; Note, window actually becomes 488,899 and I give up on figuring out what to do
   ; Main this is consistency and it seems to be consistent
   WinMove($windowHandle, "", $globalOffsetX, $globalOffsetY, 489, 899)
   Sleep(50)
   WinMove($windowHandle, "", $globalOffsetX, $globalOffsetY, 489, 899)
   Sleep(500)

   If PixelCheck(466, 561, 0x232642, 10) Then
	  Write("It seems you didn't close the controls on the right")
	  Exit
   EndIf

   Write("Array count: " & $children[0][0])
   Local $i = 1
   Local $correctIndex = 0
   While $i <= $children[0][0]
	  Write("[" & $i & "][0] = " & $children[$i][0])
	  Write("[" & $i & "][1] = " & $children[$i][1])

	  If $children[$i][1] = "plrNativeInputWindowClass" Then
		 $correctIndex = $i
	  EndIf

	  $i = $i + 1
   WEnd
   If $correctIndex = 0 Then
	  Write("Unable to find plrNativeInputWindowClass")
	  Exit
   EndIf
   ; Expectation:
   $sendMessageHandle = $children[$correctIndex][0]

   Write("Window hooked")
EndFunc

Func ClaimPresentBox()
   While 1
	  If Not WinExists($windowHandle) Then
		 Write("Window not found - did it close?")
		 AlertProblem()
		 ContinueLoop
	  EndIf

	  If PixelCheck(381, 767, 0x9A3723, 10) Then
		 Write("Claim All")
		 Click(427, 768, 10)
		 Sleep(500)
		 ContinueLoop
	  EndIf
	  If PixelCheck(152, 842, 0x2D2514, 10) AND PixelCheck(200, 843, 0x872C13, 10) AND PixelCheck(331, 839, 0x2A2211, 10) Then
		 Write("OK")
		 Click(240, 841, 10)
		 Sleep(500)
		 ContinueLoop
	  EndIf
	  If PixelCheck(222, 846, 0xDACAB9, 10) AND PixelCheck(263, 841, 0x8F2D14, 10) AND PixelCheck(243, 839, 0x2C2415, 10) Then
		 Write("Cancel OK")
		 If PixelCheck(479, 505, 0x1E1C1B, 10) Then
			Write("Nothing is being claimed")
			AlertProblem()
			ContinueLoop
		 EndIf
		 Click(163, 842, 10)
		 Sleep(500)
		 ContinueLoop
	  EndIf
   WEnd
EndFunc

Func ShootingGallery()
   Write("TBD")
EndFunc

If PixelCheck(382, 823, 0xE5D498, 10) AND PixelCheck(408, 836, 0x836A49, 10) AND PixelCheck(339, 845, 0x403727, 10) AND PixelCheck(182, 122, 0x151515, 10) Then
   Write("Claim Present Box mode detected")
   ClaimPresentBox()
   Write("Done")
   Exit
EndIf

If PixelCheck(55, 764, 0x5E4E3D, 10) AND PixelCheck(187, 642, 0xAC512E, 10) AND PixelCheck(431, 774, 0x7B766C, 10) Then
   Write("Shooting Gallery Mode")
   ShootingGallery()
   Write("Done")
   Exit
EndIf

While 1
   If GetElapsedTime() > $maxScriptTime Then
	  Write("Time limit reached.")
	  AlertProblem()
	  ContinueLoop
   EndIf

   If Not WinExists($windowHandle) Then
	  Write("Window not found - did it close?")
	  AlertProblem()
	  ContinueLoop
   EndIf

   $timeout = $timeout + 1
   If $timeout > $maxTimeout Then
	 Write("Timeout has been reached. Something's wrong.")
	 AlertProblem()
	 ContinueLoop
   EndIf

   If PixelCheck(67, 703, 0xB48666, 10) AND PixelCheck(440, 857, 0x735231, 10) Then
	  Write("In battle")

	  OnBattleTick()

	  $battleTimeout = $battleTimeout + 1
	  If $battleTimeout > $maxBattleTimeout Then
		 Write("Battle is taking a long time")
		 AlertProblem()
	  EndIf

	  If PixelCheck(355, 885, 0x4F2E1E, 10) Then
		 ; Manual clicking
		 If Random(0, 100) < 50 Then
			Click(67, 794, 10)
		 Else
			Click(154, 792, 10)
		 EndIf
	  ElseIf PixelCheck(358, 884, 0x935941, 10) Then
		 Write("Disabling Auto Mode")
		 Click(355, 871, 5)
		 Sleep(1000)
	  Else
		 Write("Unknown Auto Status")
	  EndIf

	  Sleep(Random(500, 750, 1))
	  ContinueLoop
   EndIf

   AdjustSettings(False)
   Sleep(Random(500, 1000, 1))

   If (PixelCheck(443, 345, 0xCABAAA, 10) AND PixelCheck(280, 841, 0x8D2E15, 10) AND PixelCheck(416, 828, 0x373024, 10)) OR (PixelCheck(463, 344, 0xD5C0AC, 10) AND PixelCheck(458, 579, 0x8E7F70, 10) AND PixelCheck(275, 844, 0x8D3017, 10) AND PixelCheck(415, 830, 0x4C3A28, 10)) OR (PixelCheck(455, 367, 0xC6C1B1, 10) AND PixelCheck(458, 588, 0x8A7E70, 10)) OR (PixelCheck(468, 367, 0xD5C1AE, 10) AND PixelCheck(471, 421, 0x7D715D, 10) AND PixelCheck(418, 829, 0x8B7A5D, 10)) OR (PixelCheck(245, 360, 0xB9A292, 10) AND PixelCheck(417, 830, 0x8A7960, 10) AND PixelCheck(239, 159, 0xEFEBDD, 10)) OR (PixelCheck(428, 154, 0xC1B29E, 10) AND PixelCheck(469, 345, 0xCDBEAC, 10) AND PixelCheck(415, 830, 0x897858, 10)) OR (PixelCheck(144, 842, 0xDBCBC2, 10) AND PixelCheck(195, 843, 0x832E0F, 10) AND PixelCheck(416, 829, 0x3A3325, 10)) Then
	  If $returnToHome Then
		 Write("Clicking OK after story due to Return To Home mode")
		 Click(247, 843, 10)
		 ContinueLoop
	  EndIf

	  If (Not $farmMastery) AND $coopMode AND PixelCheck(277, 844, 0x8E3017, 10) Then
		 Write("Clicking OK after story due to coop mode")
		 Click(247, 843, 10)
		 ContinueLoop
	  EndIf

	  If PixelCheck(139, 844, 0xDCCCC3, 10) Then
		 If PixelCheck(46, 843, 0x443C35, 10) OR PixelCheck(45, 846, 0x6E6760, 10) OR PixelCheck(46, 844, 0x685E57, 10) Then
			If $clearStoryMode Then
			   Write("Done with story")
			   AlertProblem()
			   ContinueLoop
			EndIf

			Write("Try Again")
			Click(86, 845, 10)
			OnStoryStart()
			Sleep(2000)
			ContinueLoop
		 EndIf

		 If PixelCheck(72, 845, 0x5C524B, 10) Then
			Write("Next Button Detected")
			If $clearStoryMode Then
			   Click(86, 845, 10)
			   OnStoryStart()
			   Sleep(1000)
			   ContinueLoop
			EndIf
		 EndIf

		 Write("Drop Rewards > White Button detected")
		 ContinueLoop
	  EndIf

	  Write("Drop Rewards - No white button")
	  ContinueLoop
   EndIf

   If (PixelCheck(310, 825, 0x8B7858, 10) AND PixelCheck(310, 852, 0xD4CCB3, 10) AND PixelCheck(466, 860, 0x756249, 10)) OR (PixelCheck(304, 824, 0x91785D, 10) AND PixelCheck(386, 824, 0x92795E, 10) AND PixelCheck(476, 885, 0x2A221A, 10)) OR (PixelCheck(321, 794, 0x3F3626, 10) AND PixelCheck(354, 771, 0x9E7E56, 10) AND PixelCheck(446, 804, 0x736342, 10)) Then
	  If PixelCheck(34, 824, 0xE1D190, 10) Then
		 Write("At Home")
		 $returnToHome = 0
	  EndIf

	  If Not PixelCheck(102, 823, 0xE5D49A, 10) Then
		 Write("Clicking on Story")
		 Click(104, 858, 10)
		 Sleep(1000)
		 ContinueLoop
	  EndIf

	  If PixelCheck(57, 769, 0x604F3F, 10) AND PixelCheck(190, 766, 0x892E15, 10) Then

		 If PixelCheck(436, 752, 0x463D2D, 10) OR PixelCheck(434, 753, 0x8B7A5A, 10) Then
			If $avoidCompletedStories Then
			   If PixelCheck(66, 416, 0x611F07, 10) OR (PixelCheck(79, 416, 0xDAD0C7, 10) AND PixelCheck(125, 402, 0xDED0C6, 10)) Then
				  Write("Start Story - Story is already complete, returning")
				  $timeout = $timeout - 2
				  Click(45, 771, 10)
				  Sleep(500)
				  ContinueLoop
			   EndIf
			EndIf

			Write("Start Story - Skip ticket visible")
			Click(245, 767, 10)
			OnStoryStart()
			Sleep(3000)
			ContinueLoop
		 EndIf

		 Write("Unknown Start Story")
		 ContinueLoop
	  EndIf

	  If (PixelCheck(173, 488, 0x50422B, 10) AND PixelCheck(367, 398, 0xA86634, 10) AND PixelCheck(332, 667, 0x403627, 11)) OR (PixelCheck(97, 431, 0x000000, 10) AND PixelCheck(172, 668, 0x3F3627, 10) AND PixelCheck(412, 718, 0x9B8A71, 10)) Then
		 Write("Co-Op Battle, Event, Main Story")

		 If $farmMastery Then
			Write("Clicking Event to farm mastery")
			Click(370, 438, 10)
			Sleep(1000)
			ContinueLoop
		 EndIf

		 If $coopMode Then
			Write("Clicking Co-Op Battle")
			Click(116, 445, 10)
			Sleep(1000)
			ContinueLoop
		 EndIf

		 ContinueLoop
	  EndIf

	  If PixelCheck(55, 771, 0x5D4C3C, 10) AND PixelCheck(78, 771, 0xDBD3CB, 10) AND PixelCheck(354, 765, 0xD7C7BE, 10) AND PixelCheck(383, 768, 0x513921, 10) Then
		 If Not $coopMode Then
			Write("Co-op menu while not in coop - returning to home")
			Click(34, 860, 10)
			Sleep(1000)
			ContinueLoop
		 EndIf

		 Local $currentCoopTab = 0
		 If PixelCheck(148, 171, 0x4B3A2A, 10) AND PixelCheck(172, 172, 0xDACAC1, 10) AND PixelCheck(334, 174, 0xD9C9C0, 10) Then
			$currentCoopTab = 1
		 ElseIf PixelCheck(149, 176, 0xD2C2B9, 10) AND PixelCheck(166, 177, 0x3E3525, 10) AND PixelCheck(336, 183, 0xC8B7AF, 10) Then
			$currentCoopTab = 2
		 ElseIf PixelCheck(150, 178, 0xD3C3BA, 10) AND PixelCheck(173, 180, 0xCEBDB5, 10) AND PixelCheck(334, 178, 0x473E2E, 10) Then
			$currentCoopTab = 3
		 Else
			Write("Co-op menu detected but can't determine current tab")
			ContinueLoop
		 EndIf

		 If Not ($currentCoopTab = $coopMode) Then
			If $coopMode = 1 Then
			   Click(79, 172, 10)
			ElseIf $coopMode = 2 Then
			   Click(241, 174, 10)
			ElseIf $coopMode = 3 Then
			   Click(410, 173, 10)
			Else
			   Write("Co-op menu detected on menu " & $currentCoopTab & " instead of " & $coopMode & " but wtf is that.")
			   ContinueLoop
			EndIf
			Write("Co-op menu detected, switching to tab " & $coopMode)
			Sleep(1000)
			ContinueLoop
		 EndIf

		 Local $goodCoop = 1

		 If PixelCheck(154, 273, 0x2F2C2A, 10) AND PixelCheck(391, 274, 0x2F2B29, 10) Then
			Write("Co-op story is unavilable - Clicking Update")
			$goodCoop = 0
		 EndIf

		 If $goodCoop AND PixelCheck(358, 224, 0xC5B597, 12) AND PixelCheck(239, 230, 0xD3C2A8, 16) AND PixelCheck(79, 235, 0xCCB296, 16) Then
			Write("No in-story players could be found - Clicking Update")
			$goodCoop = 0
		 EndIf

		 If $goodCoop AND PixelCheck(96, 296, 0xD1BCA4, 11) AND PixelCheck(246, 278, 0xCCBB9C, 15) Then
			Write("No in-story players could be found 2 - Clicking Update")
			$goodCoop = 0
		 EndIf

		 If $goodCoop AND Not IsCoopBattleGood() Then
			Write("Bad coop battle detected - Clicking Update")
			$goodCoop = 0
		 EndIf

		 If Not $goodCoop Then
			Click(414, 763, 10)
			Sleep(1000)
			$timeout = $timeout - 1
			ContinueLoop
		 EndIf

		 Write("Detected good coop - joining")
		 Click(248, 285, 10)
		 Sleep(1000)
		 ContinueLoop
	  EndIf

	  If PixelCheck(16, 170, 0x403727, 10) AND PixelCheck(235, 174, 0x423929, 10) AND PixelCheck(258, 175, 0xD5C5BC, 10) AND PixelCheck(469, 177, 0xCFBFB6, 10) Then
		 Write("Limited-Time Events")

		 If $farmMastery Then
			If PixelCheck(255, 497, 0x294528, 10) AND PixelCheck(389, 531, 0xFBF5EC, 10) AND PixelCheck(427, 625, 0x6A6352, 10) Then
			   Write("Study Hall found - clicking")
			   Click(246, 545, 10)
			   Sleep(1000)
			   ContinueLoop
			EndIf

			Write("Study Hall not found, scrolling down")

			Local $y = 700

			MoveMouse(470, $y, 10)
			Sleep(50)

			HoldMouse(True)
			Sleep(50)

			While $y > 230
			   MoveMouse(470, $y, 10)
			   $y = $y - 10
			   Sleep(50)
			WEnd
			HoldMouse(False)

			Sleep(2000)
			ContinueLoop
		 EndIf
		 ContinueLoop
	  EndIf

	  If PixelCheck(443, 704, 0x6D441A, 10) AND PixelCheck(379, 710, 0x6D451B, 10) Then
		 If $returnToHome Then
			Write("Last stage clear, but returning to home")
			Click(34, 859, 10)
			ContinueLoop
		 EndIf

		 If $farmMastery AND (PixelCheck(424, 689, 0x9CB9C0, 10) OR PixelCheck(389, 683, 0xBDCFD6, 10) OR PixelCheck(392, 684, 0xBACBCE, 10)) Then
			Write("Artifact Study Hall detected")
			Click(243, 687, 10)
			ContinueLoop
		 EndIf

		 Write("Last Stage CLEAR - what am I supposed to do? Returning to home")
		 $returnToHome = 1
		 ContinueLoop
	  EndIf

	  Write("Main buttons visible")
	  ContinueLoop
   EndIf

   If PixelCheck(220, 840, 0xD8CDC0, 10) AND PixelCheck(241, 838, 0x2F2716, 10) AND PixelCheck(268, 838, 0x8E331A, 10) Then
	  If (PixelCheck(177, 370, 0xD5CDC1, 10) AND PixelCheck(164, 367, 0x060606, 10)) OR (PixelCheck(178, 401, 0xBBB5AA, 10) AND PixelCheck(177, 397, 0x0B0B0B, 10) AND PixelCheck(458, 542, 0x141311, 10) AND PixelCheck(455, 578, 0x0E0C0B, 10)) Then
		 Write("Start purifying?")
		 Click(324, 841, 10) ; OK
		 Sleep(5000)
		 PuriCircle()
		 ContinueLoop
	  EndIf

	  If PixelCheck(447, 436, 0x161413, 10) AND PixelCheck(444, 403, 0x060606, 10) AND PixelCheck(444, 363, 0x141312, 10) AND PixelCheck(290, 771, 0x0E0401, 10) Then
		 Write("Small text box")
		 If PixelCheck(222, 402, 0x948E87, 10) Then
			Write("Start purifying? 2")
			Click(324, 841, 10) ; OK
			Sleep(5000)
			PuriCircle()
			ContinueLoop
		 EndIf

		 Write("UNKNOWN SITUATION. Either need to puri or connection failed. Clicking cancel.")
		 Click(163, 839, 10)
		 ContinueLoop
	  EndIf


	  If PixelCheck(397, 401, 0x060606, 10) AND PixelCheck(407, 737, 0x0C0D0A, 10) AND PixelCheck(26, 776, 0x0A0A09, 10) AND PixelCheck(43, 99, 0x0B0807, 10) Then
		 Write("You're part way through a story. Continue?")
		 Click(163, 839, 10)
		 Sleep(1000)
		 ContinueLoop
	  EndIf

	  If PixelCheck(95, 455, 0xDFDC9C, 10) AND PixelCheck(156, 476, 0xE9D8D0, 10) AND PixelCheck(305, 488, 0xC3B7A9, 10) Then
		 Write("Use a purification ticket to play?")
		 If $puriTicketRefresh Then
			Click(324, 841, 10) ; OK
			Sleep(5000)
			PuriCircle()
			ContinueLoop
		 EndIf

		 AdjustSettings(True)
		 Click(164, 843, 10) ; Cancel

		 If $returnToHome Then
			Write("Returning to Home")
			Sleep(2000)
			Click(32, 856, 10)
			ContinueLoop
		 EndIf

		 Write("Waiting 60s to retry")
		 Sleep(60000)
		 ContinueLoop
	  EndIf

	  Write("White Red button")
	  ContinueLoop
   EndIf

   If PixelCheck(153, 852, 0x2F2716, 10) AND PixelCheck(202, 848, 0x872C13, 10) AND PixelCheck(324, 848, 0x282017, 10) Then
	  If PixelCheck(155, 298, 0xF8F0DC, 10) AND PixelCheck(75, 416, 0xECE2C2, 10) Then
		 Write("Login Bonus - Standard Login Bonus")
		 Click(243, 847, 10)
		 ContinueLoop
	  EndIf
	  If PixelCheck(148, 94, 0xFFFDED, 10) AND PixelCheck(250, 99, 0xFFFDED, 10) AND NOT PixelCheck(158, 94, 0xFFFDED, 10) Then
		 Write("Login Bonus - Supplamental")
		 Click(243, 847, 10)
		 ContinueLoop
	  EndIf
	  If PixelCheck(285, 767, 0x0E0502, 10) AND PixelCheck(437, 640, 0x151413, 10) AND PixelCheck(55, 769, 0x0A0806, 10) Then
		 Write("Failed to join story")
		 Click(243, 847, 10)
		 ContinueLoop
	  EndIf

	  Write("Red button")
	  Click(243, 847, 10)
	  ContinueLoop
   EndIf

   If (PixelCheck(153, 837, 0x2A2212, 10) AND PixelCheck(185, 844, 0xD7C7B7, 10) AND PixelCheck(334, 843, 0x2C2413, 10)) OR (PixelCheck(141, 839, 0x2D2519, 10) AND PixelCheck(182, 842, 0xDACABA, 10) AND PixelCheck(327, 850, 0x2D251B, 10)) Then
	  If PixelCheck(303, 262, 0xC3AFA7, 10) AND PixelCheck(416, 377, 0xD8C8B7, 10) AND PixelCheck(377, 481, 0xD1C1B0, 10) Then
		 Write("Recover AP - Insufficient AP to continue the story")
		 If $puriRefresh Then
			Click(235, 378, 10)
			Sleep(1000)
		 EndIf
		 ContinueLoop
	  EndIf

	  If PixelCheck(83, 54, 0x675C45, 10) AND PixelCheck(110, 57, 0x383326, 10) AND PixelCheck(450, 135, 0xDACAC2, 10) Then
		 Write("Latest News")
		 Click(244, 841, 10)
		 ContinueLoop
	  EndIf

	  If PixelCheck(39, 595, 0x7B7671, 12) AND NOT PixelCheck(40, 614, 0x7B7671, 12) Then
		 Write("Don't display today")
		 Click(244, 841, 10)
		 ContinueLoop
	  EndIf

	  Write("White button")
	  ContinueLoop
   EndIf

   If PixelCheck(126, 152, 0xFFAA4E, 10) AND PixelCheck(472, 709, 0x090807, 11) AND PixelCheck(283, 843, 0x120603, 11) Then
	  Write("Clear Bonus")
	  Click(436, 707, 10)
	  ContinueLoop
   EndIf

   If PixelCheck(482, 694, 0x090807, 10) AND PixelCheck(285, 843, 0x110603, 10) AND PixelCheck(216, 428, 0x254555, 10) Then
	  Write("You received a Twilight Crystal")
	  Click(436, 707, 10)
	  ContinueLoop
   EndIf

   If PixelCheck(417, 828, 0xFFFFFF, 10) AND PixelCheck(436, 828, 0x000000, 10) AND PixelCheck(55, 120, 0xE1D2C1, 30) Then
	  Write("Tap to Start")
	  Click(256, 824, 14)
	  Sleep(5000)
	  ContinueLoop
   EndIf

   Write("Unknown situation")
   If $clearStoryMode = 1 Then
	  Click(425, 718, 10)
	  Sleep(Random(1, 500, 1))
   EndIf
   Sleep(Random(1000, 1300, 1))
WEnd