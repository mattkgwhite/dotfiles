#Requires -RunAsAdministrator
# install.ps1 — Bootstrap chezmoi dotfiles on Windows.
# Usage: Run in an elevated PowerShell session.
#   iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/chipwolf/dotfiles/main/install.ps1'))
# Or clone the repo and run:
#   .\install.ps1

$ErrorActionPreference = "Stop"

# Install Chocolatey if not present
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    $env:PATH = "$env:ALLUSERSPROFILE\chocolatey\bin;$env:PATH"
}

# Install chezmoi if not present
if (-not (Get-Command chezmoi -ErrorAction SilentlyContinue)) {
    Write-Host "Installing chezmoi..." -ForegroundColor Cyan
    choco install chezmoi -y --no-progress
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
}

# Ensure git is on PATH (chezmoi init needs it)
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    $gitPaths = @("$env:ProgramFiles\Git\cmd", "${env:ProgramFiles(x86)}\Git\cmd", "$env:LOCALAPPDATA\Programs\Git\cmd")
    $found = $gitPaths | Where-Object { Test-Path "$_\git.exe" } | Select-Object -First 1
    if ($found) {
        Write-Host "Found git at $found, adding to PATH..." -ForegroundColor Cyan
        $env:PATH = "$found;$env:PATH"
    } else {
        Write-Host "Installing git..." -ForegroundColor Cyan
        choco install git -y --no-progress
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
    }
}

# Determine source directory
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }

Write-Host "Applying chezmoi dotfiles from $scriptDir..." -ForegroundColor Cyan
chezmoi init --apply --source="$scriptDir"

Write-Host "Done! Restart your terminal to pick up the new configuration." -ForegroundColor Green
