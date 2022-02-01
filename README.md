# PoShCmdLetFarm
My own PowerShell Farm that brings useful CmdLets to life for any Lazy System Admin

## Usage
If you trust me, add the following command to your PoSh-profile.
```powershell
Get-ChildItem -Path "C:\Users\<username>\Git\PoShCmdLetFarm" -Filter *.ps1 | ForEach-Object {. $_.FullName}`
```