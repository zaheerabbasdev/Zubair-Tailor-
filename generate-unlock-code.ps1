# Generates a per-device unlock code for the Tailor Management app.
# Usage: .\generate-unlock-code.ps1 "AP3A.240905.015.A2"

param(
  [Parameter(Mandatory=$true)]
  [string]$DeviceId
)

$salt = 'ZubairSecret2026'
$md5 = [System.Security.Cryptography.MD5]::Create()
$bytes = [System.Text.Encoding]::UTF8.GetBytes($DeviceId + $salt)
$hex = ($md5.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") }) -join ''
$code = $hex.Substring(0,8).ToUpper()

Write-Output "Device ID:   $DeviceId"
Write-Output "Unlock code: $code"
