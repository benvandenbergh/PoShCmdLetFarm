Function Get-PublicIP {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$false)][string]$ComputerName
    )
    If ($ComputerName) {
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {(Invoke-WebRequest -uri "http://ifconfig.me/ip").Content}
    } else {
        (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
    }
}