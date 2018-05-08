;~ File: setMTU_1200_1500.au3
;~ Author: Christopher Meskill
;~ Date: 5-2-2018
;~ Purpose: Quickly and easily change the MTU size as needed

;~ #NoTrayIcon
#RequireAdmin

#include <Array.au3>
#include <Constants.au3>
#include <GUIConstants.au3>

Opt("GUIOnEventMode", 1)

Global $MainGUI = GUICreate("MTU Size Utility", 600, 400)
Global $labelcombo = GUICtrlCreateLabel("Select Network Interface", 420, 10, 150, 25)
Global $cNetInterface = GUICtrlCreateCombo("", 420, 50)
Global $labelbuttons = GUICtrlCreateLabel("Click desired MTU size:", 420, 75, 150, 25)
Global $set1200 = GUICtrlCreateButton("1200", 450, 100)
Global $set1500 = GUICtrlCreateButton("1500", 500, 100)
Global $buttonClose = GUICtrlCreateButton("Close", 450, 200, 85, 25)
Global $StdOut_Display = GUICtrlCreateEdit("", 10, 10, 400, 300, BitOR($GUI_SS_DEFAULT_EDIT,$ES_READONLY))

Global $numInterfaces = 0
Global $aName[10]
Global $selectedInterfaceName

GUICtrlSetOnEvent($set1200, '_SetMTU1200')
GUICtrlSetOnEvent($set1500, '_SetMTU1500')
GUICtrlSetOnEvent($buttonClose, '_AllExit')
GUISetOnEvent($GUI_EVENT_CLOSE, '_AllExit', $MainGUI)

_getInterfaceNames()
GuiCtrlSetData($cNetInterface, "All" & "|" & _ArrayToString($aName), "All")
GUISetState(@SW_SHOW, $MainGUI)
_ShowInterfaces()

While 1
   ; Wait for user input
WEnd

Func _AllExit()
   GUIDelete(@GUI_WinHandle)
   Exit
EndFunc

Func _getInterfaceNames()
   Local $sExtCmd = "netsh interface ipv4 show subinterfaces"
   Local $iPID = Run(@ComSpec & " /c " & $sExtCmd, @WorkingDir, @SW_MINIMIZE, $STDOUT_CHILD)
   Local $sStdOut = ""
   Local $aColumn

   Do
	   $sStdOut &= StdoutRead($iPID)
   Until @error

   Local $aLine = StringSplit($sStdOut, @CRLF) ;' 	')

   ; Parse StdOut line by line
   For $i = 9 To ($aLine[0]-3) Step 2 ;
		   $aColumn = StringSplit( StringStripWS( $aLine[$i], 4), ' 	')
		   For $j=6 To $aColumn[0] ; Parse StdOut by default delim (spaces)
			  $aName[$numInterfaces] &= $aColumn[$j] & ' '
		   Next
		   $aName[$numInterfaces] = StringStripWS( $aName[$numInterfaces], 2 )
		   $numInterfaces += 1
	Next

EndFunc

Func _ShowInterfaces()
   $iPID = Run("netsh interface ipv4 show subinterfaces", "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
   ProcessWaitClose($iPID)
   $sOutput = StringStripWS(StdoutRead($iPID), $STR_STRIPLEADING + $STR_STRIPTRAILING)
   GUICtrlSetData($StdOut_Display, GUICtrlRead($StdOut_Display) & 'Display id | ' & $sOutput & @CRLF)
EndFunc

Func _SetMTU_All_($mtuval)
   $iPID = RunWait(@ComSpec & " /c " & 'For /f  "usebackq skip=3 tokens=4*" %a In (`NetSh Interface IPv4 Show Interfaces ^| findstr /v "Loop"`) Do (netsh interface ipv4 set subinterface "%b" ' & $mtuval & ' store=persistent)' ,"",@SW_hide )
   ProcessWaitClose($iPID)
   $sOutput = StringStripWS(StdoutRead($iPID), $STR_STRIPLEADING + $STR_STRIPTRAILING)
   GUICtrlSetData($StdOut_Display, GUICtrlRead($StdOut_Display) & 'Display id | ' & $sOutput & @CRLF)

   _ShowInterfaces()
EndFunc

Func _SetMTU($mtuval)
	$iPID = RunWait(@ComSpec & " /c " & 'netsh interface ipv4 set subinterface "' & $selectedInterfaceName & '" mtu=' & $mtuval & ' store=persistent', "", @SW_HIDE)
	ProcessWaitClose($iPID)

	_ShowInterfaces()
EndFunc

Func _SetMTU1200()
   $selectedInterfaceName = GUICtrlRead($cNetInterface)

   If $selectedInterfaceName = "All" Then
		_SetMTU_All_(1200)
	Else
		_SetMTU(1200)
	EndIf
EndFunc

Func _SetMTU1500()
   $selectedInterfaceName = GUICtrlRead($cNetInterface)

	If $selectedInterfaceName = "All" Then
		_SetMTU_All_(1500)
	Else
		_SetMTU(1500)
	EndIf
EndFunc