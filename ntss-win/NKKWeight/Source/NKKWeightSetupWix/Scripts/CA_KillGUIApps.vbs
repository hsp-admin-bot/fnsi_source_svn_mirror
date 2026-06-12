On Error Resume Next

Dim oShell
Set oShell = CreateObject("WScript.Shell")

Sub ForceKillProcess(ByVal processName)
  Dim cmd
  cmd = "cmd.exe /c taskkill /F /IM " & processName & " >nul 2>&1"
  oShell.Run cmd, 0, True
End Sub

ForceKillProcess "FNWSiScaleTool.exe"
ForceKillProcess "NKKWeightTool.exe"
ForceKillProcess "NKKWeightScaleApp.exe"

Session.Property("RUNNING_PROCESSES") = ""
