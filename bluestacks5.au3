#include "common.au3"

; Controls
HotKeySet("{end}", "end")
HotKeySet("{insert}", WriteColorCheck)
HotKeySet("{home}", PuriCircle)

; This is for Bluestacks v5
; 540x960 portrait resolution
; 160 DPI
; 60 FPS
; DirectX Compatibility
; Sidebar closed
; Controls hidden

; Make sure to set in-game quality to High

; 0 means "no" or "off"
; 1 means "on" or "yes"

$maxRetry = 20000                 ; Maximum number of times to repeat a map
$maxScriptTime = 3000 * 60 * 1000 ; Maximum time to macro, in milliseconds

$farmMastery = 0                  ; This is for farming Mastery from Study Hall
$clearStoryMode = 1               ; For clearing new content with a Next button


; More internalish things
$maxTimeout = 150
$maxBattleTimeout = 1500
$writeColorCheckDelay = 20

$globalOffsetX = 10
$globalOffsetY = 10

$timeout = 0
$battleTimeout = 0

; Super internaly things

Func Test()
   Write("Testing")
   Click(175, 699, 0)
EndFunc

Func WriteColorCheck()
   $x = MouseGetPos(0) - $globalOffsetX
   $y = MouseGetPos(1) - $globalOffsetY
   $c = PixelGetColor($x + $globalOffsetX, $y + $globalOffsetY)

   ;Send("PixelCheck("&$x&", "&$y&", 0x"&Hex($c,6)&", 10)")
   ;Send("Click("&$x&", "&$y&", 10)")

   If True Then
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

	  $i = 0
	  While $i < $writeColorCheckDelay
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

		 Sleep(10)
		 $i = $i + 1
	  WEnd

	  $r = Int(($maxr + $minr) / 2)
	  $g = Int(($maxg + $ming) / 2)
	  $b = Int(($maxb + $minb) / 2)

	  Local $vr = $maxr - $r
	  Local $vg = $maxg - $g
	  Local $vb = $maxb - $b

	  Local $v = _Max(_Max($vr, $vg), $vb)

	  Local $str = "PixelCheck("&$x&", "&$y&", 0x"&Hex($r,2)&Hex($g,2)&Hex($b,2)&", "&($v+10)&")"
	  Write($str)
	  ClipPut($str)
   EndIf
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

			Local $minimumClicks = 3
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

   Sleep(Random(500, 1000, 1))

   If PixelCheck(455, 367, 0xC6C1B1, 10) AND PixelCheck(458, 588, 0x8A7E70, 10) Then
	  If PixelCheck(148, 844, 0xDCCCC3, 10) AND PixelCheck(46, 843, 0x443C35, 10) Then
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

	  If PixelCheck(148, 844, 0xDCCCC3, 10) AND PixelCheck(72, 845, 0x5C524B, 10) Then
		 Write("Next Button Detected")
		 If $clearStoryMode Then
			Click(86, 845, 10)
			OnStoryStart()
			Sleep(1000)
			ContinueLoop
		 EndIf
	  EndIf

	  Write("Drop Rewards")
	  ContinueLoop
   EndIf

   If PixelCheck(310, 825, 0x8B7858, 10) AND PixelCheck(310, 852, 0xD4CCB3, 10) AND PixelCheck(466, 860, 0x756249, 10) Then
	  If Not PixelCheck(102, 823, 0xE5D49A, 10) Then
		 Write("Clicking on Story")
		 Click(104, 858, 10)
		 Sleep(2000)
		 ContinueLoop
	  EndIf

	  If PixelCheck(57, 769, 0x604F3F, 10) AND PixelCheck(190, 766, 0x892E15, 10) Then
		 If PixelCheck(436, 752, 0x463D2D, 10) Then
			Write("Start Story - Skip ticket disabled")
			Click(245, 767, 10)
			OnStoryStart()
			Sleep(3000)
			ContinueLoop
		 EndIf

		 Write("Unknown Start Story")
		 ContinueLoop
	  EndIf

	  Write("Main buttons visible")
	  ContinueLoop
   EndIf

   If PixelCheck(220, 840, 0xD8CDC0, 10) AND PixelCheck(241, 838, 0x2F2716, 10) AND PixelCheck(268, 838, 0x8E331A, 10) Then
	  If PixelCheck(177, 370, 0xD5CDC1, 10) AND PixelCheck(164, 367, 0x060606, 10) Then
		 Write("Start purifying?")
		 Click(324, 841, 10) ; OK
		 Sleep(5000)
		 PuriCircle()
		 ContinueLoop
	  EndIf

	  Write("White Red button")
	  ContinueLoop
   EndIf

   Write("Unknown situation")
   If $clearStoryMode = 1 Then
	  Click(425, 718, 10)
	  Sleep(Random(1, 500, 1))
   EndIf
   Sleep(Random(1000, 1300, 1))
WEnd