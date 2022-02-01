function sync-latestADObjects {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$false)][Int32]$pastMinutes = 60
    )
    $dte = (Get-Date).AddMinutes($pastMinutes * -1)
    $source = (Get-ADDomainController).Name
    
    $objectsToSync = Get-ADObject -Filter 'whencreated -gt $dte' -prop whencreated | Where-Object {$_.ObjectClass -in "group","user","computer"}| Sort-Object ObjectClass,whencreated | Out-GridView -PassThru -Title "Select Objects to sync"
    if ($objectsToSync) {
        $objectsToSync | Sync-ADObject -Source $source -Destination (Get-ADDomainController -Filter * | Select-Object Site,Name,Ipv4Address,OperatingSystem | Sort-Object Site,Name | Out-GridView -OutputMode Single -Title "Select Destination DC").name -Verbose
    }
}
