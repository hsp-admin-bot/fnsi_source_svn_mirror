On Error Resume Next

Dim oWMI, oItems, oProc, oSvc, uRet, oShell
Set oWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
Set oShell = CreateObject("WScript.Shell")

Sub ForceKillProcess(ByVal processName)
  Dim cmd
  cmd = "cmd.exe /c taskkill /F /IM " & processName & " >nul 2>&1"
  oShell.Run cmd, 0, True
End Sub

If Err.Number = 0 Then
  Set oItems = oWMI.ExecQuery("Select * from Win32_Process Where Name = 'FNWSiAccessCardTool.exe'")
  For Each oProc In oItems
    uRet = oProc.Terminate(0)
  Next
  ForceKillProcess "FNWSiAccessCardTool.exe"

  Set oItems = oWMI.ExecQuery("Select * from Win32_Process Where Name = 'NKKAccessCardTool.exe'")
  For Each oProc In oItems
    uRet = oProc.Terminate(0)
  Next
  ForceKillProcess "NKKAccessCardTool.exe"

  Set oItems = oWMI.ExecQuery("Select * from Win32_Process Where Name = 'NKKAccessCardApp.exe'")
  For Each oProc In oItems
    uRet = oProc.Terminate(0)
  Next
  ForceKillProcess "NKKAccessCardApp.exe"

  Set oItems = oWMI.ExecQuery("Select * from Win32_Service Where Name = 'NKKAccessCardService'")
  For Each oSvc In oItems
    If LCase(oSvc.State) = "running" Then
      uRet = oSvc.StopService()
    End If
  Next
End If

Session.Property("RUNNING_PROCESSES") = ""
