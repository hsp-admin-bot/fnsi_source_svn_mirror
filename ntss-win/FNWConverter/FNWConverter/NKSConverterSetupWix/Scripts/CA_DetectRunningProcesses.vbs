On Error Resume Next

Dim sRunning
sRunning = ""

' 1) WMI (primary)
DetectByWmi sRunning

' 2) MSI コンテキストで WMI が失敗する場合に tasklist で fallback
If Len(sRunning) = 0 Then
  DetectByTasklist sRunning
End If

Session.Property("RUNNING_PROCESSES") = sRunning

Sub DetectByWmi(ByRef runningText)
  Dim oWMI, oItems
  Err.Clear
  Set oWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
  If Err.Number <> 0 Then Exit Sub

  Set oItems = oWMI.ExecQuery("Select * from Win32_Process Where Name = 'FNW2FNSI_Converter.exe'")
  If oItems.Count > 0 Then
    runningText = "FNW2FNSI_Converter.exe"
  End If
End Sub

Sub DetectByTasklist(ByRef runningText)
  Dim sh, ret
  Set sh = CreateObject("WScript.Shell")

  ' Exact match by IMAGENAME
  Err.Clear
  ret = sh.Run("cmd /c tasklist /FI ""IMAGENAME eq FNW2FNSI_Converter.exe"" | find /I ""FNW2FNSI_Converter.exe"" >nul", 0, True)
  If Err.Number = 0 And ret = 0 Then
    runningText = "FNW2FNSI_Converter.exe"
    Exit Sub
  End If

  ' Fallback: substring match (更に保険)
  Err.Clear
  ret = sh.Run("cmd /c tasklist | find /I ""FNW2FNSI_Converter"" >nul", 0, True)
  If Err.Number = 0 And ret = 0 Then
    runningText = "FNW2FNSI_Converter.exe"
  End If
End Sub

