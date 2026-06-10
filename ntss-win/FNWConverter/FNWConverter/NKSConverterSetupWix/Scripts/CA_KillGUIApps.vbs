On Error Resume Next

Dim oWMI, oItems, oProc, uRet, oShell
Set oWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
Set oShell = CreateObject("WScript.Shell")

Sub ForceKillProcess(ByVal processName)
  Dim cmd
  cmd = "cmd.exe /c taskkill /F /IM " & processName & " >nul 2>&1"
  oShell.Run cmd, 0, True
End Sub

If Err.Number = 0 Then
  Set oItems = oWMI.ExecQuery("Select * from Win32_Process Where Name = 'FNW2FNSI_Converter.exe'")
  For Each oProc In oItems
    uRet = oProc.Terminate(0)
  Next
  ForceKillProcess "FNW2FNSI_Converter.exe"
End If

Session.Property("RUNNING_PROCESSES") = ""

