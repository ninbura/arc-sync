@echo off

set scriptPath=%~dp0scripts\setup.ps1

echo script path = %scriptPath%
echo.

pwsh -noprofile -executionpolicy bypass -file "%scriptPath%"

exit
