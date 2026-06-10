On Error Resume Next

Dim sRunning, bServiceRunning
sRunning = ""
bServiceRunning = False

' 1) First try WMI (fast when available)
DetectByWmi sRunning, bServiceRunning

' 2) MSI custom action host can fail WMI; fallback to tasklist/sc query
If Len(sRunning) = 0 Then
  DetectByShellFallback sRunning, bServiceRunning
End If

Session.Property("RUNNING_PROCESSES") = sRunning
If bServiceRunning Then
  Session.Property("SERVICE_WAS_RUNNING") = "1"
Else
  Session.Property("SERVICE_WAS_RUNNING") = "0"
End If

Sub AppendRunningItem(ByRef currentText, ByVal itemText)
  If Len(currentText) > 0 Then
    currentText = currentText & vbCrLf
  End If
  currentText = currentText & itemText
End Sub

Sub DetectByWmi(ByRef runningText, ByRef serviceWasRunning)
  Dim oWMI, oItems

  Err.Clear
  Set oWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
  If Err.Number <> 0 Then Exit Sub

  Set oItems = oWMI.ExecQuery("Select * from Win32_Process Where Name = 'NKKWeightTool.exe'")
  If oItems.Count > 0 Then
    AppendRunningItem runningText, "体重計アプリ (NKKWeightTool.exe)"
  End If

  Set oItems = oWMI.ExecQuery("Select * from Win32_Process Where Name = 'NKKWeightScaleApp.exe'")
  If oItems.Count > 0 Then
    AppendRunningItem runningText, "オフライン体重計アプリ (NKKWeightScaleApp.exe)"
  End If

  Set oItems = oWMI.ExecQuery("Select * from Win32_Service Where Name = 'NKKWeightService' And State = 'Running'")
  If oItems.Count > 0 Then
    AppendRunningItem runningText, "NKKWeight サービス (NKKWeightService)"
    serviceWasRunning = True
  End If
End Sub

Sub DetectByShellFallback(ByRef runningText, ByRef serviceWasRunning)
  Dim oShell
  Dim toolRes, scaleRes, serviceRes

  Set oShell = CreateObject("WScript.Shell")

  Err.Clear
  toolRes = oShell.Run("cmd /c tasklist /FI ""IMAGENAME eq NKKWeightTool.exe"" | find /I ""NKKWeightTool.exe"" >nul", 0, True)
  If Err.Number = 0 And toolRes = 0 Then
    AppendRunningItem runningText, "体重計アプリ (NKKWeightTool.exe)"
  End If

  Err.Clear
  scaleRes = oShell.Run("cmd /c tasklist /FI ""IMAGENAME eq NKKWeightScaleApp.exe"" | find /I ""NKKWeightScaleApp.exe"" >nul", 0, True)
  If Err.Number = 0 And scaleRes = 0 Then
    AppendRunningItem runningText, "オフライン体重計アプリ (NKKWeightScaleApp.exe)"
  End If

  Err.Clear
  serviceRes = oShell.Run("cmd /c sc query NKKWeightService | find /I ""STATE"" | find /I ""RUNNING"" >nul", 0, True)
  If Err.Number = 0 And serviceRes = 0 Then
    AppendRunningItem runningText, "NKKWeight サービス (NKKWeightService)"
    serviceWasRunning = True
  End If
End Sub
