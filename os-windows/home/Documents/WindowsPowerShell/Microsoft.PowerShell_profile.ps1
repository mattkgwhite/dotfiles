# Starship configuration is not used as PowerShell is loading the last configuration file specifically.
Invoke-Expression (&starship init powershell)

oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/mattkgwhite/dotfiles/main/files/omp-configs/easy-term.omp.json' | Invoke-Expression
# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# Force Fastfetch to use YOUR config every time (bypass path confusion)
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    fastfetch -c "C:/Users/kaygee/.config/fastfetch/config.jsonc"
}