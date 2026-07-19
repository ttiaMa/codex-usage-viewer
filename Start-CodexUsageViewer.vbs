Option Explicit

Dim shell, fileSystem, scriptDirectory, viewerScript, command

Set shell = CreateObject("WScript.Shell")
Set fileSystem = CreateObject("Scripting.FileSystemObject")

scriptDirectory = fileSystem.GetParentFolderName(WScript.ScriptFullName)
viewerScript = fileSystem.BuildPath(scriptDirectory, "CodexUsageViewer.ps1")
command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File """ & viewerScript & """"

' Window style 0 starts PowerShell completely hidden, without Windows Terminal.
shell.Run command, 0, False

