@echo off
start "Codex Usage Viewer" powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File "%~dp0CodexUsageViewer.ps1"
