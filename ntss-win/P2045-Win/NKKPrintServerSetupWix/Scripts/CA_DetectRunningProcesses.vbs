On Error Resume Next

Dim oWMI, oItems
Dim sRunning
sRunning = ""

Set oWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
If Err.Number = 0 Then
  Set oItems = oWMI.ExecQuery("Select * from Win32_Process Where Name = 'FNWSiPrintServerTool.exe'")
  If oItems.Count > 0 Then
    If Len(sRunning) > 0 Then sRunning = sRunning & vbCrLf
    sRunning = sRunning & "印刷サーバー保守ツール (FNWSiPrintServerTool.exe)"
  End If

  Set oItems = oWMI.ExecQuery("Select * from Win32_Service Where Name = 'NKKPrintServer' And State = 'Running'")
  If oItems.Count > 0 Then
    If Len(sRunning) > 0 Then sRunning = sRunning & vbCrLf
    sRunning = sRunning & "NKKPrintServer サービス (NKKPrintServer)"
  End If
End If

Session.Property("RUNNING_PROCESSES") = sRunning
