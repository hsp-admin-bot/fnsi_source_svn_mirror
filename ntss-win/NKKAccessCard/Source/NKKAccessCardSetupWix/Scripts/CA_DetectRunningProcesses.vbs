On Error Resume Next

Dim oWMI, oItems
Dim sRunning
sRunning = ""

Set oWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
If Err.Number = 0 Then
  Set oItems = oWMI.ExecQuery("Select * from Win32_Process Where Name = 'FNWSiAccessCardTool.exe'")
  If oItems.Count > 0 Then
    If Len(sRunning) > 0 Then sRunning = sRunning & vbCrLf
    sRunning = sRunning & "カード保守ツール (FNWSiAccessCardTool.exe)"
  End If

  Set oItems = oWMI.ExecQuery("Select * from Win32_Process Where Name = 'NKKAccessCardApp.exe'")
  If oItems.Count > 0 Then
    If Len(sRunning) > 0 Then sRunning = sRunning & vbCrLf
    sRunning = sRunning & "カードアプリ (NKKAccessCardApp.exe)"
  End If

  Set oItems = oWMI.ExecQuery("Select * from Win32_Service Where Name = 'NKKAccessCardService' And State = 'Running'")
  If oItems.Count > 0 Then
    If Len(sRunning) > 0 Then sRunning = sRunning & vbCrLf
    sRunning = sRunning & "カードサービス (NKKAccessCardService)"
  End If
End If

Session.Property("RUNNING_PROCESSES") = sRunning
