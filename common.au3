#include <ScreenCapture.au3>
#Include <Date.au3>
#include <Math.au3>
#include <SendMessage.au3>
#include <WindowsConstants.au3>
#include <WinAPISysWin.au3>

Func End()
   Exit
EndFunc

$user32 = DllOpen("User32.dll")
$sendMessageHandle = 0
Func _PostMessage($a, $b, $c)
   If $sendMessageHandle = 0 Then
	  Write("Cannot interact until window is set")
	  Return
   EndIf
   _SendMessage($sendMessageHandle, $a, $b, $c)
   ;DllCall($user32, "int", "PostMessage", "hwnd", $sendMessageHandle, "int", $a, "int", $b, "long", $c)
EndFunc

$mouseIsDown = False
$mouseX = 0
$mouseY = 0

$globalOffsetX = 0
$globalOffsetY = 0
$globalOffsetX2 = 0
$globalOffsetY2 = 0

Func MoveMouse($x, $y, $var)
   $x = $x + Random(-1 * $var, $var, 1)
   $y = $y + Random(-1 * $var, $var, 1)

   $mouseX = $x + $globalOffsetX2
   $mouseY = $y + $globalOffsetY2

   Local $param = 0
   If $mouseIsDown Then
	  $param = 1
   EndIf

   _PostMessage($WM_MOUSEMOVE, $param, _WinAPI_MakeLong($x, $y))
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

Func Click($x, $y, $var)
   MoveMouse($x, $y, $var)

   HoldMouse(True)
   HoldMouse(False)
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
