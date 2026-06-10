On Error Resume Next
Dim oWMI, oItems, sRunning
sRunning = ""
Set oWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
If Err.Number = 0 Then
  Set oItems = oWMI.ExecQuery("Select * from Win32_Process Where Name = 'StatisticsTool_2025.exe'")
  If oItems.Count > 0 Then sRunning = "StatisticsTool_2025.exe"
End If
Session.Property("RUNNING_PROCESSES") = sRunning
