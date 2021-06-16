#include <ScreenCapture.au3>
#Include <Date.au3>
#include <Math.au3>
#include <SendMessage.au3>
#include <WindowsConstants.au3>
#include <WinAPISysWin.au3>

; Controls / Emergency off button
HotKeySet("{end}", "end")
HotKeySet("{insert}", WriteColorCheck)
HotKeySet("{home}", PuriCircle)

; This is for Bluestacks
; 540x960 portrait resolution
; 160 DPI

; 0 means "no" or "off"
; 1 means "on" or "yes"

$maxRetry = 20000                 ; Maximum number of times to repeat a map
$maxScriptTime = 3000 * 60 * 1000 ; Maximum time to macro, in milliseconds

$clearStoryMode = 1               ; For clearing new content with a Next button
$farmMastery = 0                  ; This is for farming Mastery from Study Hall

Func Test()
   Write("Testing")
   Click(50, 443, 0)
EndFunc

; -------------------------------------------------------------------------------
; -------------------------------------------------------------------------------
; -------------------------------------------------------------------------------

Func end()
   Exit
EndFunc

$user32 = DllOpen("User32.dll")
Func _PostMessage($a, $b, $c)
   _SendMessage($sendMessageHandle, $a, $b, $c)
   ;DllCall($user32, "int", "PostMessage", "hwnd", $sendMessageHandle, "int", $a, "int", $b, "long", $c)
EndFunc

$mouseIsDown = False
$mouseX = 0
$mouseY = 0
Func MoveMouse($x, $y, $var)
   $x = $x + Random(-1 * $var, $var, 1)
   $y = $y + Random(-1 * $var, $var, 1)

   $mouseX = $x - 2
   $mouseY = $y - 44

   Local $param = 0
   If $mouseIsDown Then
	  $param = 1
   EndIf

   _PostMessage($WM_MOUSEMOVE, $param, _WinAPI_MakeLong($x, $y))
EndFunc

Func Click($x, $y, $var)
   MoveMouse($x, $y, $var)

   HoldMouse(True)
   HoldMouse(False)
EndFunc

Func HoldMouse($down)
   ; bool only bro
   If $down Then
	  $down = True
   Else
	  $down = False
   EndIf

   If $mouseIsDown = $down Then
	  Return
   EndIf

   $mouseIsDown = $down

   If $down Then
	  _PostMessage($WM_LBUTTONDOWN, 0, _WinAPI_MakeLong($mouseX, $mouseY))
   Else
	  _PostMessage($WM_LBUTTONUP, 0, _WinAPI_MakeLong($mouseX, $mouseY))
   EndIf
EndFunc

$startTime = TimerInit()
Func GetElapsedTime()
   Return TimerDiff($startTime)
EndFunc

Func CompareColors($c1, $c2, $tol)
   $r = BitShift(BitAND($c1, 0xFF0000), 16)
   $g = BitShift(BitAND($c1, 0xFF00), 8)
   $b = BitAND($c1, 0xFF)

   $r2 = BitShift(BitAND($c2, 0xFF0000), 16)
   $g2 = BitShift(BitAND($c2, 0xFF00), 8)
   $b2 = BitAND($c2, 0xFF)

   If Abs($r - $r2) > $tol Then
	  return False
   EndIf

   If Abs($g - $g2) > $tol Then
	  return False
   EndIf

   If Abs($b - $b2) > $tol Then
	  return False
   EndIf

   return True
EndFunc

Func PixelCheck($x, $y, $rgb, $tol)
   $c = PixelGetColor($x + $globalOffsetX, $y + $globalOffsetY)

   return CompareColors($c, $rgb, $tol)
EndFunc

Func AlertProblem()
   SoundPlay(@WindowsDir & "\media\tada.wav", 1)
   Sleep(5000)
EndFunc

Func Write($str)
   ConsoleWrite("[" & _NowTime() & "] " & $str & @CRLF)
EndFunc

Func GetSeconds()
   Return (_DateDiff("s","1970/01/01 00:00:00",@YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC))
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

	  Write("PixelCheck("&$x&", "&$y&", 0x"&Hex($r,2)&Hex($g,2)&Hex($b,2)&", "&($v+10)&")")
   EndIf
EndFunc

; -------------------------------------------------------------------------------
; -------------------------------------------------------------------------------
; -------------------------------------------------------------------------------

Func ResetBattleStats()
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
   If $nowTime - $_IsPuriSkillActive_Time < 250 Then
	  Return $_IsPuriSkillActive_Response
   EndIf

   $_IsPuriSkillActive_Response = 0

   If PixelCheck(244, 580, 0x3F3623, 10) Then
	  If PixelCheck(216, 573, 0xFFA73A, 30) AND PixelCheck(300, 572, 0xFFA430, 30) Then
		 ;more samples to see how tolerant should be
		 $_IsPuriSkillActive_Response = 1
	  EndIf
   EndIf
   If PixelCheck(324, 573, 0xF58E3B, 32) AND PixelCheck(205, 573, 0xFF9236, 28) Then
	  $_IsPuriSkillActive_Response = 1
   EndIf

   $_IsPuriSkillActive_Time = $nowTime
   Return $_IsPuriSkillActive_Response
EndFunc

$_IsPuriExitButton_Response = 0
$_IsPuriExitButton_Time = 0
Func IsPuriExitButton()
   Local $nowTime = GetElapsedTime()
   If $nowTime - $_IsPuriExitButton_Time < 250 Then
	  Return $_IsPuriExitButton_Response
   EndIf

   $_IsPuriExitButton_Response = 0
   ; Standard OK button
   If PixelCheck(167, 920, 0x2B2314, 10) AND PixelCheck(201, 920, 0xA03D25, 10) AND PixelCheck(357, 920, 0x2F2718, 10) Then
	  $_IsPuriExitButton_Response = 1
   EndIf

   ; Darkened OK button from Rank Up
   If PixelCheck(163, 920, 0x0A0804, 10) AND PixelCheck(207, 919, 0x210C07, 10) AND PixelCheck(363, 916, 0x0B0905, 10) Then
	  $_IsPuriExitButton_Response = 1
   EndIf

   $_IsPuriExitButton_Time = $nowTime
   Return $_IsPuriExitButton_Response
EndFunc

Func PuriCircle()
   Local $var = 5

   Local $positions = 24
   Local $xArray[$positions] = [369,402,405,410,405,399,383,377,331,284,245,191,160,124,115,99,102,116,146,176,206,268,301,338]
   Local $yArray[$positions] = [452,489,528,564,609,651,717,767,751,735,726,701,686,674,633,570,542,505,438,410,397,387,385,415]

   Write("Starting purify")

   While True
      MoveMouse($xArray[0], $yArray[0], $var) ; Start
      HoldMouse(True)

      Local $i = 0
      While True
         Local $x = $xArray[Mod($i, $positions)]
         Local $y = $yArray[Mod($i, $positions)]
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

			   Click(258, 556, 8)
			WEnd

			Write("Special Skill Done")

			Sleep(100)
			ExitLoop
		 EndIf

         If IsPuriExitButton() Then
            ExitLoop
         EndIf

         $i = $i + 1

		 Sleep(20)
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
		 Click(261, 922, 10)
		 Sleep(1000)
	  WEnd
	  Sleep(2000)
   WEnd

   Write("Purify complete")
EndFunc

; -------------------------------------------------------------------------------
; -------------------------------------------------------------------------------
; -------------------------------------------------------------------------------

$maxTimeout = 150
$maxBattleTimeout = 1500
$writeColorCheckDelay = 200

$globalOffsetX = 1
$globalOffsetY = 1

$windowHandle = 0
$sendMessageHandle = 0

Init()
Func Init()
   Write("Please focus the bluestacks window...")
   $windowHandle = WinWaitActive("BlueStacks")
   WinMove($windowHandle, "", $globalOffsetX, $globalOffsetY, 584, 971)

   Write("Window found...")

   Local $children = _WinAPI_EnumChildWindows($windowHandle)
   If @error <> 0 Then
	  Write("Failed to get children: " & @error)
	  Return
   EndIf
   Write("Array count: " & $children[0][0])
   Local $i = 1
   While $i <= $children[0][0]
	  Write("[" & $i & "][0] = " & $children[$i][0])
	  Write("[" & $i & "][1] = " & $children[$i][1])
	  $i = $i + 1
   WEnd
   $sendMessageHandle = $children[1][0]

   Write("Window locked")
EndFunc

$timeout = 0
$battleTimeout = 0

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

   If PixelCheck(41, 922, 0x5E5239, 10) AND PixelCheck(183, 935, 0xF0E8DF, 10) AND PixelCheck(320, 939, 0xE9E0D8, 10) Then
	  Write("In battle")

	  OnBattleTick()

	  $battleTimeout = $battleTimeout + 1
	  If $battleTimeout > $maxBattleTimeout Then
		 Write("Battle is taking a long time")
		 AlertProblem()
	  EndIf

	  If PixelCheck(360, 954, 0x4A2919, 10) Then
		 ; Manual clicking
		 If Random(0, 100) < 50 Then
			Click(71, 856, 5)
		 Else
			Click(188, 856, 5)
		 EndIf
	  ElseIf PixelCheck(357, 952, 0x754B32, 10) Then
		 Write("Disabling Auto Mode")
		 Click(381, 940, 5)
		 Sleep(1000)
	  Else
		 Write("Unknown Auto Status")
	  EndIf

	  Sleep(Random(500, 750, 1))
	  ContinueLoop
   EndIf

   Sleep(Random(500, 1000, 1))

   If PixelCheck(160, 909, 0xDCCCC3, 10) AND PixelCheck(313, 903, 0x8D3B1A, 10) AND PixelCheck(25, 421, 0x786856, 10) Then
	  If PixelCheck(51, 909, 0x6F645D, 10) OR PixelCheck(50, 910, 0x635851, 10) Then
		 If $clearStoryMode Then
			Write("Done with story")
			AlertProblem()
			ContinueLoop
		 EndIf

		 Write("Try Again")
		 Click(93, 910, 10)
		 ResetBattleStats()
		 Sleep(2000)
		 ContinueLoop
	  EndIf

	  If PixelCheck(73, 905, 0x393029, 10) OR (PixelCheck(76, 911, 0xC7BCB6, 10)) Then
		 Write("Next Button Detected")
		 If $clearStoryMode Then
			Click(73, 905, 10)
			Sleep(1000)
			ContinueLoop
		 EndIf
	  EndIf

	  Write("Drop Rewards")
	  ContinueLoop
   EndIf

   If PixelCheck(508, 936, 0x403828, 10) AND PixelCheck(509, 925, 0x716140, 10) AND PixelCheck(518, 901, 0x251304, 10) Then
	  If Not PixelCheck(115, 887, 0xE9CF96, 10) Then
		 Write("Clicking on Story")
		 Click(116, 921, 10)
		 Sleep(2000)
		 ContinueLoop
	  EndIf

	  If PixelCheck(304, 191, 0x864B1F, 10) AND PixelCheck(350, 746, 0xD2C2A9, 10) AND PixelCheck(346, 835, 0x596949, 10) Then
		 Write("Act of Reality - Hard")
		 Click(266, 748, 10) ; Ch. 5
		 Sleep(2000)
		 ContinueLoop
	  EndIf

	  If PixelCheck(127, 401, 0x082E32, 10) AND PixelCheck(105, 502, 0xFFFFFF, 10) AND PixelCheck(129, 703, 0x26D25C, 10) Then
		 Write("Chapter 5-1")
		 Click(267, 382, 10)
		 Sleep(2000)
		 ContinueLoop
	  EndIf

	  If PixelCheck(298, 826, 0x8C3118, 10) AND PixelCheck(465, 811, 0x8C7B5A, 10) AND PixelCheck(437, 832, 0x453921, 10) Then
		 Write("Start Story - Skip ticket visible")
		 Click(261, 830, 10)
		 ResetBattleStats()
		 Sleep(3000)
		 ContinueLoop
	  EndIf

	  If PixelCheck(202, 826, 0x8D3219, 10) AND PixelCheck(468, 812, 0x453D30, 10) Then
		 Write("Start Story - Skip ticket disabled")
		 Click(264, 827, 10)
		 ResetBattleStats()
		 Sleep(3000)
		 ContinueLoop
	  EndIf

	  Write("Home Story Gear Menu Visible")
	  ContinueLoop
   EndIf

   If PixelCheck(84, 901, 0x242211, 10) AND PixelCheck(227, 902, 0xDCCDC4, 10) AND PixelCheck(261, 902, 0x2D2416, 10) AND PixelCheck(293, 906, 0x842910, 10) Then
	  If PixelCheck(367, 404, 0x060606, 10) AND PixelCheck(200, 403, 0xABA69B, 10) Then
		 Write("Start purifying?")
		 AlertProblem()
		 ContinueLoop
	  EndIf

	  If PixelCheck(228, 438, 0xB8B2A7, 10) AND PixelCheck(283, 435, 0x1F1E1C, 10) Then
		 Write("Start purifying?")
		 AlertProblem()
		 ContinueLoop
	  EndIf

	  Write("White Red button")
	  ContinueLoop
   EndIf

   If PixelCheck(163, 907, 0x292114, 10) AND PixelCheck(203, 911, 0xD6C6BD, 10) AND PixelCheck(365, 907, 0x2A2211, 10) Then
	  If PixelCheck(354, 289, 0xC6B3AB, 10) AND PixelCheck(451, 408, 0xD4C4BA, 10) AND PixelCheck(451, 504, 0xD7C7B8, 10) Then
		 Write("Recover AP - Insufficient AP to continue the story")
		 Click(256, 410, 10)
		 Sleep(2000)
		 ContinueLoop
	  EndIf

	  If PixelCheck(263, 66, 0xDBCBBA, 10) AND PixelCheck(43, 641, 0x817C74, 10) Then
		 Write("Royal Pass")
		 Click(262, 907, 10)
		 Sleep(1000)
		 ContinueLoop
	  EndIf

	  Write("White Button")
	  ContinueLoop
   EndIf

   If PixelCheck(173, 913, 0x2C241B, 10) AND PixelCheck(196, 911, 0x8B3018, 10) AND PixelCheck(353, 909, 0x2A2215, 10) Then
	  If PixelCheck(168, 326, 0xF1E1CB, 10) AND PixelCheck(269, 327, 0xEFDDC6, 10) Then
		 Write("Login Bonus")
		 Click(262, 914, 10)
		 Sleep(500)
		 ContinueLoop
	  EndIf
	  If PixelCheck(160, 114, 0xF6EEDD, 10) AND PixelCheck(270, 114, 0xE4CFBA, 10) Then
		 Write("Login Bonus 2")
		 Click(262, 914, 10)
		 Sleep(500)
		 ContinueLoop
	  EndIf
	  If PixelCheck(133, 432, 0x060606, 10) AND PixelCheck(393, 430, 0x060606, 10) Then
		 Write("Black warning message")
		 Click(262, 914, 10)
		 Sleep(2000)
		 ContinueLoop
	  EndIf

	  Write("Red Button")
	  ContinueLoop
   EndIf

   Write("Unknown situation")
   If $clearStoryMode = 1 Then
	  Click(279, 514, 13)
	  Sleep(Random(1, 500, 1))
   EndIf
   Sleep(Random(1000, 1300, 1))
WEnd