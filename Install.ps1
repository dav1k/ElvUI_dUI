# Install ElvUI_dUI for WoW/Live

# RunAs Admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
# -----

$plugin = 'C:\Users\Dave\Dev\ElvUI_dUI\'
$dest = 'C:\Program Files (x86)\World of Warcraft\Interface\AddOns\ElvUI_dUI\'


Remove-Item -Path $dest -Recurse
New-Item -ItemType directory -Path $dest
Copy-Item -Path $plugin\* -Destination $dest -Recurse
