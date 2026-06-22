On Error Resume Next

Dim sh, oWMI, oItems, oProc, oSvc, uRet
Set sh = CreateObject("WScript.Shell")

' First, stop service using SCM command for reliability.
uRet = sh.Run("cmd /c sc stop FNSiViewSyncService >nul 2>&1", 0, True)

Set oWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
If Err.Number = 0 Then
  Set oItems = oWMI.ExecQuery("Select * from Win32_Process Where Name = 'FNSiViewSyncTool.exe'")
  For Each oProc In oItems
    uRet = oProc.Terminate(0)
  Next

  Set oItems = oWMI.ExecQuery("Select * from Win32_Process Where Name = 'FNSiViewUpdateApp.exe'")
  For Each oProc In oItems
    uRet = oProc.Terminate(0)
  Next

  Set oItems = oWMI.ExecQuery("Select * from Win32_Process Where Name = 'FNSiViewSyncService.exe'")
  For Each oProc In oItems
    uRet = oProc.Terminate(0)
  Next

  uRet = sh.Run("cmd.exe /c taskkill /F /IM FNSiViewSyncTool.exe >nul 2>&1", 0, True)
  uRet = sh.Run("cmd.exe /c taskkill /F /IM FNSiViewUpdateApp.exe >nul 2>&1", 0, True)
  uRet = sh.Run("cmd.exe /c taskkill /F /IM FNSiViewSyncService.exe >nul 2>&1", 0, True)

  Set oItems = oWMI.ExecQuery("Select * from Win32_Service Where Name = 'FNSiViewSyncService'")
  For Each oSvc In oItems
    If LCase(oSvc.State) = "running" Or LCase(oSvc.State) = "start pending" Then
      uRet = oSvc.StopService()
    End If
  Next
End If

Session.Property("RUNNING_PROCESSES") = ""
