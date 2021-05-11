; This is for Bluestacks

#include <ScreenCapture.au3>
#Include <Date.au3>
#include <Math.au3>
#include <SendMessage.au3>
#include <WindowsConstants.au3>

HotKeySet("{end}", "end")
HotKeySet("{insert}", WriteColorCheck)

$globalOffsetX = 50
$globalOffsetY = 100
$maxTimeout = 150
$maxBattleTimeout = 1500
$writeColorCheckDelay = 200

$maxRetry = 20000
$maxScriptTime = 3000 * 60 * 1000
$clearStoryMode = 0

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

Func MoveMouse($x, $y, $var, $steps)
   Local $x2 = $globalOffsetX + $x + Round(Random(-1, 1) * $var)
   Local $y2 = $globalOffsetY + $y + Round(Random(-1, 1) * $var)

   $expectedMouseX = $x2
   $expectedMouseY = $y2
EndFunc

Func MouseAction($upDown)
   Local $x = $expectedMouseX - $globalOffsetX
   Local $y = $expectedMouseY - $globalOffsetY
   Local $wParam = 0
   Local $lParam = BitRotate($y,16,"D")
   $lParam = BitXOR($lParam,$x)

   If $upDown = "Up" Then
	  _SendMessage($windowHandle, $WM_LBUTTONUP, $wParam, $lParam)
   ElseIf $upDown = "Down" Then
	  _SendMessage($windowHandle, $WM_LBUTTONDOWN, $wParam, $lParam)
   Else
	  Write("wat")
   EndIf
EndFunc

Func Click($x, $y, $var)
   MoveMouse($x, $y, $var, 1)
   Sleep(10)
   MouseAction("Down")
   Sleep(100 + Random(0, 50, 1))
   MouseAction("Up")
   Sleep(100)
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

	  Send("PixelCheck("&$x&", "&$y&", 0x"&Hex($r,2)&Hex($g,2)&Hex($b,2)&", "&($v+10)&")")
   EndIf
EndFunc

; *******************************************************
; End specific helper definitions
; *******************************************************

$window = "???"
Write("Please focus the bluestacks window...")

Local $startTime = TimerInit()

$windowHandle = WinWaitActive($window)
WinMove($window, "", $globalOffsetX, $globalOffsetY, 583, 1284)

Write("Window found...")

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

   Sleep(Random(1, 50, 1))

   If Not WinExists($window) Then
	  Write("Window not found")
	  AlertProblem()
	  ContinueLoop
   EndIf

   If PixelCheck(527, 1075, 0x000100, 10) AND PixelCheck(500, 1073, 0xFEFFFE, 10) Then ; The black/white in the logos bottom right
	  Write("Home Screen?")
	  If PixelCheck(174, 629, 0xFEFFFE, 11) AND PixelCheck(411, 528, 0xA09A8A, 40) AND PixelCheck(562, 143, 0xE2D6CD, 11) Then
		 Write("Home Screen")
		 $wasAtHomeScreen = True
		 Click(293, 735, 35)
		 Sleep(20000)
		 ContinueLoop
	  EndIf
   EndIf

   If PixelCheck(269, 1086, 0xDACEC3, 10) AND PixelCheck(310, 1083, 0x862F14, 10) AND PixelCheck(573, 952, 0x0D0A07, 10) Then
	  Write("Connection to server failed")
	  Click(387, 1086, 10)
	  Sleep(1000)
	  ContinueLoop
   EndIf

   If PixelCheck(325, 1083, 0x89301E, 10) AND PixelCheck(291, 1087, 0x292115, 10) AND PixelCheck(264, 1089, 0xD9CCBE, 10) AND PixelCheck(306, 1000, 0x000100, 10) Then
	  Write("Connection to server failed")
	  Click(389, 1085, 10)
	  Sleep(1000)
	  ContinueLoop
   EndIf

   If PixelCheck(34, 1073, 0xA78958, 11) AND PixelCheck(158, 1125, 0x2C261C, 10) AND PixelCheck(485, 1082, 0x463B2E, 10) AND PixelCheck(569, 1109, 0x736342, 10) Then
	  Write("Logged in > Home")
	  $wasAtHomeScreen = False
	  Click(126, 1110, 10) ; Story icon bottom
	  Sleep(2000)
	  ContinueLoop
   EndIf

   If PixelCheck(521, 235, 0x6F6046, 10) AND PixelCheck(157, 1138, 0x86704A, 10) Then
	  ;Write("Story Mode - Use Item Visible")
	  If PixelCheck(348, 994, 0x8C3318, 10) AND PixelCheck(530, 1023, 0xDFD9CB, 11) AND PixelCheck(531, 977, 0x968775, 10) Then
		 Write("Start Story")
		 StartStory()
		 ContinueLoop
	  EndIf

	  If PixelCheck(243, 994, 0x82301C, 10) AND PixelCheck(91, 1003, 0xDCD5C6, 10) AND PixelCheck(518, 981, 0x453D2D, 10) AND PixelCheck(154, 1117, 0x7E6745, 10) Then
		 Write("Start Story 2")
		 StartStory()
		 ContinueLoop
	  EndIf

	  If PixelCheck(348, 1000, 0x88290D, 10) AND PixelCheck(517, 981, 0x453D2C, 10) AND PixelCheck(93, 1001, 0xDDD5CB, 10) Then
		 Write("Start Story 3")
		 StartStory()
		 ContinueLoop
	  EndIf

	  If PixelCheck(184, 284, 0x3E3726, 11) AND PixelCheck(207, 284, 0xDCCEC3, 10) AND PixelCheck(520, 206, 0x645334, 11) Then
		 Write("Logged in > Story > Coop > Random")
		 If PixelCheck(237, 409, 0xD3C5AF, 15) AND NOT PixelCheck(532, 427, 0xCDBEB4, 10) Then
			Write("No matches detected - hitting Update")
			Click(496, 995, 10)
			Sleep(1000)
			ContinueLoop
		 EndIf

		 If PixelCheck(55, 367, 0xC5B6AE, 17) AND PixelCheck(114, 410, 0x676153, 10) Then
			Write("No matches detected 2 - hitting Update")
			Click(496, 995, 10)
			Sleep(1000)
			ContinueLoop
		 EndIf

		 If PixelCheck(261, 421, 0xDACBC1, 5) AND PixelCheck(260, 426, 0xD9C9BF, 5) AND PixelCheck(260, 429, 0xD7C7BE, 5) Then
			Write("Detected low difficulty - refreshing")
			;Click(496, 995, 10)
			;Sleep(1000)
			;ContinueLoop
		 EndIf

		 Write("Detected good coop")

		 $maxRetry = $maxRetry - 1
		 If $maxRetry < 0 Then
			Write("Out of Retries")
			Exit
		 EndIf
		 Write("Entries remaining: " & $maxRetry)

		 Click(299, 422, 20)
		 Sleep(1000)

		 ResetBattleStats()
		 ContinueLoop
	  EndIf

	  If (PixelCheck(183, 286, 0xDECFC3, 10) AND PixelCheck(209, 283, 0x433926, 11) AND PixelCheck(422, 995, 0xD5C6BC, 11)) OR (PixelCheck(215, 284, 0xDACFC1, 11) AND PixelCheck(399, 282, 0x483B28, 10)) Then
		 Write("Logged in > Story > Coop > Friends / Guild Members")

		 If PixelCheck(287, 445, 0x050605, 10) AND PixelCheck(483, 412, 0x2F2C29, 10) Then
			Write("Locked - hitting Update")
			$timeout = $timeout - 1
			Click(497, 994, 8)
			Sleep(1000 + Random(0, 1000, 1))
			ContinueLoop
		 EndIf
		 If (PixelCheck(68, 434, 0xD0C3A5, 15) AND PixelCheck(61, 501, 0xBEAE95, 10)) OR (PixelCheck(109, 439, 0x5F5550, 12) AND PixelCheck(55, 402, 0x857866, 14)) Then
			$timeout = $timeout - 1
			$updateCoopTimeout = $updateCoopTimeout + 1

			Write("No in-story friends - hitting Update " & $updateCoopTimeout)
			Sleep(Round(Random(0, 333) * _Min($updateCoopTimeout, 90)))

			Click(497, 994, 8)
			Sleep(500)

			ContinueLoop
		 EndIf

		 $timeout = $timeout + 1

		 If PixelCheck(507, 417, 0xDBCCC0, 10) Then
			Write("Found game - joining")
			$updateCoopTimeout = 0
			Click(415, 460, 10)
			Sleep(1000)
			ContinueLoop
		 EndIf

		 Write("Unknown coop situation")
		 ContinueLoop
	  EndIf
	  If PixelCheck(421, 500, 0x776C59, 11) AND PixelCheck(310, 361, 0x355B5E, 10) Then
		 Write("Twilight Illusionist")
		 Click(283, 401, 10)
		 Sleep(500)
		 ContinueLoop
	  EndIf

	  If PixelCheck(459, 420, 0xA72511, 10) AND PixelCheck(190, 348, 0x0B3040, 10) Then
		 Write("X-mas FEAST")
		 Click(283, 401, 10)
		 Sleep(500)
		 ContinueLoop
	  EndIf

	  If PixelCheck(462, 912, 0x3A352F, 10) AND PixelCheck(466, 931, 0x5F1E05, 10) Then
		 Write("Clicking bottom-most story")
		 Click(280, 897, 10)
		 Sleep(500)
		 ContinueLoop
	  EndIf

	  If PixelCheck(465, 919, 0x5E1F07, 10) AND PixelCheck(487, 890, 0x28373A, 10) Then
		 Write("Clicking bottom-most story 2")
		 Click(304, 886, 10)
		 Sleep(500)
		 ContinueLoop
	  EndIf

	  If PixelCheck(486, 857, 0x898A74, 28) AND PixelCheck(466, 789, 0x601F06, 11) Then
		 Write("Clicking second from bottom")
		 Click(301, 761, 10)
		 Sleep(500)
		 ContinueLoop
	  EndIf

	  If PixelCheck(197, 398, 0xE1BB7C, 10) AND PixelCheck(468, 341, 0x2AE7EA, 10) Then
		 Write("Lies and Prejudice")
		 Click(304, 405, 10)
		 Sleep(500)
		 ContinueLoop
	  EndIf

	  If PixelCheck(203, 879, 0x443D28, 11) AND PixelCheck(69, 669, 0x403A26, 11) AND PixelCheck(475, 983, 0xC8BE9F, 12) Then
		 Write("Logged in > Story")
		 If $coopMode Then
			Click(136, 611, 10) ; Coop
		 ElseIf False Then
			Click(297, 811, 10) ; Main Story
		 Else
			Click(442, 598, 10) ; Event
		 EndIf

		 Sleep(2000)
		 ContinueLoop
	  EndIf

	  If PixelCheck(204, 667, 0x413826, 10) AND PixelCheck(475, 987, 0xCDC0A4, 10) AND PixelCheck(527, 975, 0xD0C5A0, 10) Then
		 Write("Logged in > Story 2")
		 ;Click(297, 811, 10) ; Main Story
		 If $coopMode Then
			Click(136, 611, 10) ; Coop
		 Else
			Click(442, 598, 10) ; Event
		 EndIf

		 Sleep(2000)
		 ContinueLoop
	  EndIf

	  If PixelCheck(88, 438, 0x272D3E, 10) AND PixelCheck(215, 387, 0x8C4667, 10) Then
		 Write("Little Mermaid - 3-10")

		 Click(164, 729, 10)
		 Sleep(1000)
		 ContinueLoop
	  EndIf

	  If PixelCheck(420, 496, 0x736C59, 12) AND PixelCheck(351, 489, 0xCAC5B8, 27) Then
		 If PixelCheck(515, 456, 0x584E42, 10) AND PixelCheck(201, 458, 0xAA692D, 10) Then
			Write("End of the Dreary World")
			Click(256, 405, 10)
			Sleep(1000)
			ContinueLoop
		 EndIf

		 If PixelCheck(518, 900, 0x4F4439, 10) AND PixelCheck(237, 789, 0xBCA782, 11) Then
			Write("End of the Dreary World - Down")
			Click(268, 848, 10)
			Sleep(1000)
			ContinueLoop
		 EndIf

		 If PixelCheck(479, 452, 0x070803, 10) AND PixelCheck(180, 347, 0xFBF8E4, 10) Then
			Write("Campout Cuisine")
			Click(256, 405, 10)
			Sleep(1000)
			ContinueLoop
		 EndIf

		 If PixelCheck(484, 896, 0x070703, 10) AND PixelCheck(168, 786, 0xF7F5E0, 10) Then
			Write("Campout Cuisine - Down")
			Click(268, 848, 10)
			Sleep(1000)
			ContinueLoop
		 EndIf

		 If PixelCheck(100, 809, 0x9EB9E3, 10) AND PixelCheck(450, 820, 0x533B34, 10) Then
			Write("A Faraway Vow - Down")
			Click(268, 848, 10)
			Sleep(1000)
			ContinueLoop
		 EndIf

		 If PixelCheck(98, 388, 0x583B72, 10) AND PixelCheck(412, 405, 0xBDB3A7, 10) Then
			Write("Squirming Darkness - sword dungeon")
			Click(283, 401, 10)
			Sleep(500)
			ContinueLoop
		 EndIf

		 Write("Detected Limited-Time Events")
		 ContinueLoop
	  EndIf

	  Write("Story Mode - Use Item Visible")
	  ContinueLoop
   EndIf

   If $coopMode AND PixelCheck(32, 1023, 0xC9B7A6, 10) AND PixelCheck(234, 1087, 0x863016, 11) AND (PixelCheck(497, 1073, 0x8B7A5C, 10) OR PixelCheck(496, 1072, 0x353023, 10)) Then
	  Write("Done with coop story")
	  If PixelCheck(218, 1087, 0x8A3219, 10) Then
		 Click(293, 1090, 10)
	  EndIf

	  ContinueLoop
   EndIf

   IF PixelCheck(278, 285, 0x423B28, 10) AND PixelCheck(309, 291, 0xD3C4BB, 10) AND PixelCheck(488, 206, 0x544626, 10) Then
	  Write("Logged in > Story > Limited-Time Events")

	  $clickSlot = -1
	  If PixelCheck(96, 388, 0x644576, 10) AND PixelCheck(168, 389, 0x488C95, 10) Then
		 Write("Squirming Darkness - Weapon Upgrade")
		 $clickSlot = 1
	  EndIf

	  If PixelCheck(186, 825, 0x91550F, 10) AND PixelCheck(484, 851, 0xCFB062, 10) Then
		 Write("Secret To Riches")
		 $clickSlot = 3
	  EndIf

	  If PixelCheck(428, 427, 0xBAC8C3, 10) AND PixelCheck(115, 411, 0x2A2C28, 10) Then
		 Write("Memory of Judgment")
		 $clickSlot = 1
	  EndIf

	  If $clickSlot > 0 Then
		 Click(280, 180 + (222 * $clickSlot), 25)
		 Sleep(5000)
		 ContinueLoop
	  EndIf

	  ContinueLoop
   EndIf

   If PixelCheck(457, 280, 0xE4DDCD, 10) AND PixelCheck(488, 217, 0x4F4025, 11) AND PixelCheck(67, 1001, 0x5E513E, 10) AND PixelCheck(93, 1003, 0xDCD5CB, 10) Then
	  Write("Select specific Story")

	  If PixelCheck(481, 888, 0x324445, 10) AND PixelCheck(511, 922, 0x581703, 10) Then
		 Write("Verse 10")
		 Click(291, 896, 10)
		 Sleep(5000)
		 ContinueLoop
	  EndIf

	  If PixelCheck(102, 764, 0xDEE8DF, 10) AND PixelCheck(484, 743, 0x3E4848, 10) Then
		 Write("Weapon Guerilla - Advanced")
		 Click(303, 755, 10)
		 Sleep(5000)
		 ContinueLoop
	  EndIf
   EndIf

   If PixelCheck(319, 1089, 0x872E15, 10) AND PixelCheck(264, 1090, 0xD8CABD, 10) AND PixelCheck(481, 728, 0x131310, 10) AND PixelCheck(412, 574, 0x050605, 10) Then
	  Write("Loading failed")
	  Click(389, 1085, 10)
	  Sleep(1000)
	  ContinueLoop
   EndIf

   If PixelCheck(81, 923, 0xB0835E, 14) AND PixelCheck(534, 1108, 0x705133, 12) AND PixelCheck(153, 956, 0xD1AF54, 14) Then
	  Write("In battle")

	  OnBattleTick()

	  $battleTimeout = $battleTimeout + 1
	  If $battleTimeout > $maxBattleTimeout Then
		 Write("Battle is taking a long time")
		 AlertProblem()
	  EndIf

	  If PixelCheck(420, 1138, 0x4E2E1E, 12) Then
		 ; Manual clicking
		 If Random(0, 100) < 50 Then
			Click(298, 1030, 10) ; 1st slot
		 Else
			Click(72, 1024, 10) ; 2nd slot
		 EndIf
	  ElseIf PixelCheck(426, 1139, 0x965A41, 12) Then
		 Sleep(500)
		 Write("Disabling Auto Mode")
		 Click(422, 1120, 10)
		 Sleep(1000)
	  Else
		 Write("Unknown Auto Status")
	  EndIf

	  ContinueLoop
   EndIf

   If PixelCheck(221, 1087, 0x892F15, 10) AND PixelCheck(169, 1089, 0xD4CDBD, 10) Then
	  If PixelCheck(176, 1072, 0xE4D2C9, 10) AND PixelCheck(362, 1069, 0xB24928, 11) and PixelCheck(31, 766, 0x867C69, 10) AND PixelCheck(6, 763, 0xCCBBA9, 10) Then
		 If $tryAgain Then
			TryAgain()
			ContinueLoop
		 EndIF
	  EndIf

	  If PixelCheck(172, 1073, 0xE2D3C9, 10) AND PixelCheck(360, 1074, 0xAD4C2A, 10) AND PixelCheck(99, 725, 0xD4C5AE, 10) Then
		 If $tryAgain Then
			TryAgain()
			ContinueLoop
		 EndIf
	  EndIf

	  If PixelCheck(234, 1086, 0x873217, 10) AND PixelCheck(168, 1090, 0xCEBFB5, 10) AND PixelCheck(496, 1073, 0x8A795B, 10) Then
		 If $tryAgain Then
			TryAgain()
			ContinueLoop
		 EndIf
	  EndIf

	  If PixelCheck(180, 1092, 0xD7C8BE, 10) AND PixelCheck(221, 1092, 0x8A2A11, 10) AND PixelCheck(499, 1062, 0xA0927C, 10) Then
		 If $tryAgain Then
			TryAgain()
			ContinueLoop
		 EndIf
	  EndIf

	  If PixelCheck(487, 1059, 0x413C33, 10) Then
		If $tryAgain Then
			TryAgain()
			ContinueLoop
		 EndIf
	  EndIf

	  Write("White Red button detected")
	  ContinueLoop
   EndIf

   If PixelCheck(346, 1074, 0xDCD0C2, 10) AND PixelCheck(420, 618, 0xDDCEC4, 10) and PixelCheck(409, 166, 0x030403, 10) Then
	  Write("Recover AP - Use twilight crystals")

	  If Not $refreshCrystalsOnce Then
		 Click(290, 531, 10) ; Purify to Recover
		 Sleep(1000)

		 If PixelCheck(115, 584, 0xEEEBBA, 10) OR PixelCheck(363, 620, 0xC3B5A5, 10) OR PixelCheck(88, 547, 0xEBE0B2, 10) Then
			Write("Need to use tickets")
			If $dangerousRefresh = 1 Then
			   ; Nothing
			Else
			   Click(195, 1089, 10)
			   If $doNotRefresh = 1 Then
				  Write("Sleeping for 60s and trying again")
				  Sleep(60000)
			   Else
				  $refreshCrystalsOnce = True
			   EndIf
			   $timeout = 0
			   ContinueLoop
			EndIf
		 EndIf

		 If PixelCheck(308, 1085, 0x872E15, 10) AND PixelCheck(259, 1082, 0xDAD1C1, 10) AND PixelCheck(292, 1087, 0x282011, 11) Then
			Write("Starting purify")
			Click(386, 1088, 10)

			Write("Waiting for screen to change...")
			While PixelCheck(308, 1085, 0x872E15, 10)
			   Sleep(1000)
			WEnd

			Write("Screen changed, waiting a bit longer")
			Sleep(1000)

			Write("Doing puri circle now")
			PuriCircle()
			Write("Puri circle complete")
			ContinueLoop
		 EndIf

		 Write("Unexpected result of clicking Purify to Recover")
		 AlertProblem()
		 ContinueLoop
	  EndIf

	  $refreshCrystalsOnce = False
	  Click(295, 637, 20)
	  Sleep(500 + Random(0, 250, 1))
	  ContinueLoop
   EndIf

   If (Not $coopMode) AND PixelCheck(78, 1090, 0x000001, 10) AND PixelCheck(332, 1089, 0x8A3017, 10) AND PixelCheck(405, 1088, 0x000100, 10) Then
	  Write("No retries")
	  AlertProblem()
	  ContinueLoop
   EndIf

   If (PixelCheck(188, 1072, 0x261F0C, 10) AND PixelCheck(219, 1081, 0x8B3117, 10) AND PixelCheck(392, 1072, 0x2B2411, 10)) OR (PixelCheck(191, 1094, 0x28210D, 10) AND PixelCheck(223, 1096, 0x872C11, 10) AND PixelCheck(389, 1090, 0x292110, 10)) Then
	  Write("OK button detected")
	  If PixelCheck(421, 497, 0x4D2617, 15) Then
		 Write("Login Bonus - First Screen")
		 Click(292, 1092, 10)
		 ContinueLoop
	  EndIf
	  If PixelCheck(176, 197, 0xFEEFD3, 10) AND PixelCheck(298, 197, 0xFFF7E0, 10) AND PixelCheck(480, 276, 0xE1D9B1, 12) Then
		 Write("Login Bonus - Extra Items")
		 Click(292, 1092, 10)
		 ContinueLoop
	  EndIf
	  If PixelCheck(339, 1084, 0x8D321A, 10) AND PixelCheck(68, 723, 0x131310, 10) AND PixelCheck(202, 173, 0x040504, 10) Then
		 Write("AP recovered.")
		 Click(285, 1086, 10)
		 Sleep(500 + Random(0, 250, 1))
		 $tryAgain = True
		 ContinueLoop
	  EndIf
   EndIf

   If $wasAtHomeScreen Then
	  If PixelCheck(339, 1084, 0x8D321A, 10) AND PixelCheck(68, 723, 0x131310, 10) AND PixelCheck(202, 173, 0x040504, 10) Then
		 Write("Retry Story")
		 Click(285, 1086, 10)
		 Sleep(2000)
		 ContinueLoop
	  EndIf

	  If PixelCheck(188, 1088, 0x2B2310, 10) AND PixelCheck(215, 1087, 0xD8C8BA, 10) AND PixelCheck(404, 232, 0xDACAC3, 10) Then
		 Write("Closing News")
		 Click(297, 1091, 10)
		 Sleep(2000)
		 ContinueLoop
	  EndIf

	  If PixelCheck(188, 1081, 0x29210F, 11) AND PixelCheck(214, 1082, 0xD8CDBC, 10) AND PixelCheck(393, 1077, 0x2D2514, 10) Then
		 Write("Unloaed news")
		 Click(290, 1091, 10)
		 Sleep(1000)
		 ContinueLoop
	  EndIf

	  Write("Was at home screen but not sure what's going on")
	  Sleep(5000)
	  ContinueLoop
   EndIf

   If PixelCheck(241, 1087, 0x7E2B11, 10) AND PixelCheck(454, 1091, 0x3D392E, 10) AND NOT PixelCheck(167, 1091, 0xD8CABF, 15) Then
	  Write("Results - OK button - End of conquest")
	  Click(296, 1087, 10)
	  Sleep(1000)
	  ContinueLoop
   EndIf

   Write("Unknown situation")
   If $clearStoryMode = 1 Then
	  If PixelCheck(440, 180, 0x5B5039, 11) AND PixelCheck(463, 186, 0xDCD0C2, 11) Then
		 Click(491, 185, 5)
		 Sleep(500)
	  EndIf
	  If Random(0, 99) < 50 Then
		 Click(511, 958, 13)
		 Sleep(Random(1, 500, 1))
	  EndIf
   EndIf
   Sleep(Random(100, 300))
WEnd