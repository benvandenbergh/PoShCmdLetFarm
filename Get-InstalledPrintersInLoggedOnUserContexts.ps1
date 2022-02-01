Function Get-InstalledPrintersInLoggedOnUserContexts {
        [cmdletbinding()]
    Param (
            [Parameter(Mandatory=$true)][string]$Server,
            [Parameter(Mandatory=$true)][string]$UserName    
        ) 
    $SID = (get-aduser $UserName).SID
    Invoke-Command -ComputerName $Server -ScriptBlock {
        New-PSDrive -Name HKEY_USERS -PSProvider Registry -Root HKEY_USERS | Out-Null
        (Get-ChildItem "HKEY_USERS:\$using:SID\Printers\Connections").PSChildName.Replace(",","\")
    }
}
