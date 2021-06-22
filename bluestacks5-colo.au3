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
$clearStoryMode = 0               ; For clearing new content with a Next button
$coopMode = 0					  ; For clearing things in coop

; More internalish things
$maxTimeout = 150
$maxBattleTimeout = 1500
$writeColorCheckDelay = 20

$globalOffsetX = 10
$globalOffsetY = 10

$timeout = 0
$battleTimeout = 0

; Super internaly things

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

$_IsPuriExitButton_Response = 0
$_IsPuriExitButton_Time = 0
Func IsPuriExitButton()
   Local $nowTime = GetElapsedTime()
   If $nowTime - $_IsPuriExitButton_Time < 0 Then
	  Return $_IsPuriExitButton_Response
   EndIf

   $_IsPuriExitButton_Response = 0
   ; Standard OK button
   If PixelCheck(55, 117, 0xF1E08B, 10) AND PixelCheck(55, 124, 0xC3A349, 10) Then
	  $_IsPuriExitButton_Response = 0
   Else
	   $_IsPuriExitButton_Response = 1
   EndIf

   $_IsPuriExitButton_Time = $nowTime
   Return $_IsPuriExitButton_Response
EndFunc

Func PuriCircle()
   Local $var = 5

   Write("Puri started")

   ; The dead center locations of each puri victim
   Local $realPositions[16] = [411, 372, 408, 509, 355, 642, 165, 655, 55, 564, 111, 429, 108, 297, 302, 282]

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

   $_IsPuriExitButton_Response = 0
   $_IsPuriExitButton_Time = GetElapsedTime() + 5000

   While True
      MoveMouse($positions[0], $positions[1], $var) ; Start
      HoldMouse(True)

      Local $i = 0
	  Local $expectedTime = GetElapsedTime()
      While True
         Local $x = $positions[$i]
         Local $y = $positions[$i+1]
         MoveMouse($x, $y, $var)

         If IsPuriExitButton() Then
            ExitLoop
         EndIf

		 Sleep(30)

         $i = Mod($i + 2, 16*$positionMultiplier)
      WEnd

      If IsPuriExitButton() Then
         ExitLoop
      EndIf
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
   If Not WinExists($windowHandle) Then
	  Write("Window not found - did it close?")
	  AlertProblem()
	  ContinueLoop
   EndIf

   If PixelCheck(230, 768, 0xCE5A31, 10) AND PixelCheck(319, 808, 0x412414, 10) Then
	  Write("Ship")

	  If Not PixelCheck(349, 729, 0xE8C66F, 10) Then
		 Write("Low ship SP, entering recovery")
		 Click(433, 717, 10)
		 Sleep(500)
		 ContinueLoop
	  EndIf

	  Click(416, 375, 20)
	  Sleep(500)
	  ContinueLoop
   EndIf

   If PixelCheck(242, 765, 0xCCA258, 10) Then
	  Write("Reload")
	  Click(243, 794, 10)
	  Sleep(500)
	  ContinueLoop
   EndIf

   If PixelCheck(152, 840, 0x282011, 10) and PixelCheck(185, 839, 0x892E15, 10) and PixelCheck(325, 840, 0x271F0E, 10) Then
	  Write("OK button")
	  Click(242, 839, 10)
	  Sleep(500)
	  ContinueLoop
   EndIf

   If PixelCheck(149, 730, 0xD2B057, 10) Then
	  Write("Enough SP - clicking attack")
	  Click(62, 790, 10)
	  Sleep(100)
	  ContinueLoop
   EndIf

   If PixelCheck(55, 117, 0xF1E08B, 10) AND PixelCheck(55, 124, 0xC3A349, 10) Then
	  Write("Recovering SP")
	  PuriCircle()
	  ContinueLoop
   EndIf

   Write("Unknown situation")
WEnd