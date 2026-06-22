On Error Resume Next

Dim wasRunning
wasRunning = False

' 1) Try WMI first
DetectByWmi wasRunning

' 2) Fallback for MSI execution context where WMI can fail
If Not wasRunning Then
  DetectByShellFallback wasRunning
End If

If wasRunning Then
  Session.Property("SERVICE_WAS_RUNNING") = "1"
Else
  Session.Property("SERVICE_WAS_RUNNING") = "0"
End If

Sub DetectByWmi(ByRef serviceWasRunning)
  Dim oWMI, oItems

  Err.Clear
  Set oWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
  If Err.Number <> 0 Then Exit Sub

  Set oItems = oWMI.ExecQuery("Select * from Win32_Service Where Name = 'NKKScaleBed' And State = 'Running'")
  If oItems.Count > 0 Then
    serviceWasRunning = True
  End If
End Sub

Sub DetectByShellFallback(ByRef serviceWasRunning)
  Dim oShell, ret

  Set oShell = CreateObject("WScript.Shell")
  Err.Clear
  ret = oShell.Run("cmd /c sc query NKKScaleBed | find /I ""STATE"" | find /I ""RUNNING"" >nul", 0, True)
  If Err.Number = 0 And ret = 0 Then
    serviceWasRunning = True
  End If
End Sub
