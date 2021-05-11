; This is for Bluestacks

#include <ScreenCapture.au3>
#Include <Date.au3>
#include <Math.au3>
#include <SendMessage.au3>
#include <WindowsConstants.au3>

HotKeySet("{end}", "end")
HotKeySet("{insert}", WriteColorCheck)
HotKeySet("{home}", PuriCircle)
;might need fn key

$window = "BlueStacks"
$globalOffsetX = 1
$globalOffsetY = 1
$maxTimeout = 150
$maxBattleTimeout = 1500
$writeColorCheckDelay = 200

$maxRetry = 20000
$maxScriptTime = 3000 * 60 * 1000
$clearStoryMode = 1
$coopMode = 0
$farmExp = 0
;0 if don't want auto 1 if do
;clear story mode for click next or try again farm xp 5-1
;clear story mode is when you want it to click screen in unknown situation

Func end()
   Exit
EndFunc

Func ResetBattleStats()
   $battleTimeout = 0
EndFunc

Func OnBattleTick()
	$timeout = 0
EndFunc

$expectedMouseX = 0
$expectedMouseY = 0

Func MoveMouseExact($x, $y)

    $x = $x * 65535 / @DesktopWidth
    $y = $y * 65535 / @DesktopHeight

    DllCall($User32, "none", "mouse_event", "int", 32769, "int", $x, "int", $y, "int", 0, "int", 0) ; 32769 0x8001 BitOR($MOUSEEVENTF_ABSOLUTE, $MOUSEEVENTF_MOVE)
 EndFunc

Func MoveMouse($x, $y, $var, $steps)
   $x = $x + Random(-1 * $var, $var, 1)
   $y = $y + Random(-1 * $var, $var, 1)

   Local $x2 = $x + $globalOffsetX
   Local $y2 = $y + $globalOffsetY

   If $steps <= 1 Then
	  MoveMouseExact($x2, $y2)
	  Return
   EndIf

   Local $mx = MouseGetPos(0)
   Local $my = MouseGetPos(1)

   Local $dx = ($x2 - $mx) / $steps
   Local $dy = ($y2 - $my) / $steps

   Local $i = 0

   While $i < $steps
	  MoveMouseExact($x2 - ($dx * ($steps - $i - 1)), $y2 - ($dy * ($steps - $i - 1)))
	  $i = $i + 1
   WEnd

   MoveMouseExact($x2, $y2)
EndFunc

$User32 = DllOpen("User32.dll")

Func Click($x, $y, $var)
    $x = $x * 65535 / @DesktopWidth
    $y = $y * 65535 / @DesktopHeight

	$returnX = MouseGetPos(0)
	$returnY = MouseGetPos(1)

    DllCall($User32, "none", "mouse_event", "int", 32769, "int", $x, "int", $y, "int", 0, "int", 0) ; 32769 0x8001 BitOR($MOUSEEVENTF_ABSOLUTE, $MOUSEEVENTF_MOVE)
    DllCall($User32, "none", "mouse_event", "int", 32770, "int", $x, "int", $y, "int", 0, "int", 0) ; 32770 0x8002 BitOR($MOUSEEVENTF_ABSOLUTE, $MOUSEEVENTF_LEFTDOWN)
    DllCall($User32, "none", "mouse_event", "int", 32772, "int", $x, "int", $y, "int", 0, "int", 0) ; 32772 0x8004 BitOR($MOUSEEVENTF_ABSOLUTE, $MOUSEEVENTF_LEFTUP)

	MouseMove($returnX, $returnY, 0)
   ;MoveMouse($x, $y, $var, 1)
   ;Sleep(10)
   ;MouseAction("Down")
   ;Sleep(100 + Random(0, 50, 1))
   ;MouseAction("Up")
   ;Sleep(100)
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

Func IsPuriSkillActive()
   If PixelCheck(244, 580, 0x3F3623, 10) Then
	  If PixelCheck(216, 573, 0xFFA73A, 30) AND PixelCheck(300, 572, 0xFFA430, 30) Then
		 ;more samples to see how tolerant should be
		 Return 1
	  EndIf
   EndIf
    Return 0
EndFunc
Func IsPuriExitButton()
   If PixelCheck(305, 931, 0x8C2910, 10) AND PixelCheck(359, 926, 0x2B2315, 10) Then
	  Return 1
   EndIf
   If PixelCheck(316, 917, 0x220D08, 10) AND PixelCheck(373, 920, 0x080603, 10) Then
	  Return 1
   EndIf
   Return 0
EndFunc
Func PuriCircle()
   Local $var = 5

   Local $positions = 24
   Local $xArray[$positions] = [369,402,405,410,405,399,383,377,331,284,245,191,160,124,115,99,102,116,146,176,206,268,301,338]
   Local $yArray[$positions] = [452,489,528,564,609,651,717,767,751,735,726,701,686,674,633,570,542,505,438,410,397,387,385,415]
;24 puri positions. you can get them by insert x,y,color,tolerance

   Click($xArray[$positions - 1], $yArray[$positions - 1], $var)
   Sleep(500)

   Write("Starting purify")

   While True
      MoveMouse($xArray[$positions - 1], $yArray[$positions - 1], $var, 1) ; Start
      MouseDown("left")

      Local $i = $positions * 1000 - 2
      While True
         Local $x =$xArray[Mod($i, $positions)]
         Local $y =$yArray[Mod($i, $positions)]
         MoveMouse($x, $y, $var, 5)

		 If IsPuriSkillActive() Then
			MouseUp("left")

			Write("Special skill")

			Local $minimumClicks = 3
			While $minimumClicks > 0
			   If Not IsPuriSkillActive() Then
				  $minimumClicks = $minimumClicks - 1
			   EndIf
			   If IsPuriExitButton() Then
				  ExitLoop
			   EndIf

			   MoveMouse(258, 556, 8, 0)
			   Click(258, 556, 8)
			WEnd

			Sleep(100)
			ExitLoop
		 EndIf

         If IsPuriExitButton() Then
            ExitLoop
         EndIf

         $i = $i - 1
      WEnd

      If IsPuriExitButton() Then
         ExitLoop
      EndIf
   WEnd

   Write("Exit button detected")
   Sleep(1000)

   While IsPuriExitButton()
	  Click(261, 922, 10)
      Sleep(1000)
   WEnd

   Write("Purify complete")
EndFunc

; *******************************************************
; End specific helper definitions
; *******************************************************

Write("Please focus the bluestacks window...")

Local $startTime = TimerInit()

$windowHandle = WinWaitActive($window)
WinMove($windowHandle, "", $globalOffsetX, $globalOffsetY, 584, 971)

$controlHandle = ControlGetHandle($windowHandle, "", "[CLASS:BlueStacksApp; INSTANCE:1]")

Write("Window found...")

$timeout = 0
$battleTimeout = 0

While 1
   $timeout = $timeout + 1

   If $timeout > $maxTimeout Then
	 Write("Timeout has been reached. Something's wrong.")
	 AlertProblem()
	 ContinueLoop
   EndIf

   If TimerDiff($startTime) > $maxScriptTime Then
	  Write("Time limit reached")
	  AlertProblem()
	  ContinueLoop
   EndIf

   If Not WinExists($window) Then
	  Write("Window not found")
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
	  If PixelCheck(51, 909, 0x6F645D, 10) Then
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

	  If PixelCheck(73, 905, 0x393029, 10) Then
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

	  If PixelCheck(423, 811, 0xC8B796, 10) AND PixelCheck(448, 812, 0xCBC2A1, 10) AND PixelCheck(445, 774, 0x9A8A71, 10) Then
		 If $farmExp Then
			Write("Clicking on Main Story")
			Click(271, 657, 10)
			Sleep(1000)
			ContinueLoop
		 EndIf


		 Write("Co-Op Battle Settings")
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

	  Write("Home Story Gear Menu Visible")
	  ContinueLoop
   EndIf

   If PixelCheck(163, 907, 0x292114, 10) AND PixelCheck(203, 911, 0xD6C6BD, 10) AND PixelCheck(365, 907, 0x2A2211, 10) Then
	  If PixelCheck(354, 289, 0xC6B3AB, 10) AND PixelCheck(451, 408, 0xD4C4BA, 10) AND PixelCheck(451, 504, 0xD7C7B8, 10) Then
		 Write("Recover AP - Insufficient AP to continue the story")
		 Click(256, 410, 10)
		 Sleep(2000)
		 ContinueLoop
	  EndIf

	  Write("Single Button")
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

   Write("Unknown situation")
   If $clearStoryMode = 1 Then
	  ;If PixelCheck(440, 180, 0x5B5039, 11) AND PixelCheck(463, 186, 0xDCD0C2, 11) Then
		 ;Click(491, 185, 5)
		 ;Sleep(500)
	  ;EndIf
	  If Random(0, 99) < 50 Then
		 Click(279, 514, 13)
		 Sleep(Random(1, 500, 1))
	  EndIf
   EndIf
   Sleep(Random(1000, 1300, 1))
WEnd