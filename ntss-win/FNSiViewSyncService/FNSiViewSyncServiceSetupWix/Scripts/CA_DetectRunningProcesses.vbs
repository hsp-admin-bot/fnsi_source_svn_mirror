On Error Resume Next
Dim oWMI, oItems, sRunning
sRunning = ""
Set oWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
If Err.Number = 0 Then
  Set oItems = oWMI.ExecQuery("Select * from Win32_Process Where Name = 'FNSiViewSyncTool.exe'")
  If oItems.Count > 0 Then sRunning = "FNSiViewSyncTool.exe"
  Set oItems = oWMI.ExecQuery("Select * from Win32_Process Where Name = 'FNSiViewUpdateApp.exe'")
  If oItems.Count > 0 Then
    If Len(sRunning) > 0 Then sRunning = sRunning & vbCrLf
    sRunning = sRunning & "FNSiViewUpdateApp.exe"
  End If
  Set oItems = oWMI.ExecQuery("Select * from Win32_Service Where Name = 'FNSiViewSyncService' And State = 'Running'")
  If oItems.Count > 0 Then
    If Len(sRunning) > 0 Then sRunning = sRunning & vbCrLf
    sRunning = sRunning & "FNSiViewSyncService"
  End If
End If
Session.Property("RUNNING_PROCESSES") = sRunning
