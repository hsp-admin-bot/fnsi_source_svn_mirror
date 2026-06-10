On Error Resume Next

Dim sRunning
sRunning = ""

' 1) Try WMI first
DetectByWmi sRunning

' 2) Fallback: in MSI upgrade context, WMI may fail to enumerate
If Len(sRunning) = 0 Then
  DetectByTasklist sRunning
End If

Session.Property("RUNNING_PROCESSES") = sRunning

Sub DetectByWmi(ByRef runningText)
  Dim oWMI, oItems
  Err.Clear
  Set oWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
  If Err.Number <> 0 Then Exit Sub

  Set oItems = oWMI.ExecQuery("Select * from Win32_Process Where Name = 'CoopEventCreateOrStopTool.exe'")
  If oItems.Count > 0 Then
    runningText = "CoopEventCreateOrStopTool.exe"
    Exit Sub
  End If

  ' 旧名称が残る環境向け
  Set oItems = oWMI.ExecQuery("Select * from Win32_Process Where Name = 'CoopEventCreateTool.exe'")
  If oItems.Count > 0 Then
    runningText = "CoopEventCreateTool.exe"
  End If
End Sub

Sub DetectByTasklist(ByRef runningText)
  Dim sh, ret1, ret2
  Set sh = CreateObject("WScript.Shell")

  Err.Clear
  ret1 = sh.Run("cmd /c tasklist /FI ""IMAGENAME eq CoopEventCreateOrStopTool.exe"" | find /I ""CoopEventCreateOrStopTool.exe"" >nul", 0, True)
  If Err.Number = 0 And ret1 = 0 Then
    runningText = "CoopEventCreateOrStopTool.exe"
    Exit Sub
  End If

  Err.Clear
  ret2 = sh.Run("cmd /c tasklist /FI ""IMAGENAME eq CoopEventCreateTool.exe"" | find /I ""CoopEventCreateTool.exe"" >nul", 0, True)
  If Err.Number = 0 And ret2 = 0 Then
    runningText = "CoopEventCreateTool.exe"
  End If
End Sub
