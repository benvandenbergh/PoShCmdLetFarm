function Get-VssShadowStorage {
      <#
    .SYNOPSIS
        PoSh-alternative to vssadmin list shadowstorage, using WMI
    .PARAMETER Computername
        this is the computer you want to connect to
    .EXAMPLE
        list-VssShadowStorage -Computername myComputer
    #>
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)][string]$Computername
    )

    $volumes = Get-WmiObject -ComputerName $Computername -Class Win32_volume
    $storage = Get-WmiObject -ComputerName $Computername -Class Win32_ShadowStorage
    
    $storage | ForEach-Object {
        $Volumeid = $_.Volume.substring(30,44)
        $DiffVolumeid = $_.DiffVolume.substring(30,44)
    
        $Volume = $volumes | Where-Object {$_.DeviceID -like "*$Volumeid*"}
        $DiffVolume = $volumes | Where-Object {$_.DeviceID -like "*$DiffVolumeid*"}
    
        $_ | Select-Object `
        @{n='Computername';e={$Computername}},
        @{n='ForVolume';e={$volume.DriveLetter}},
        @{n='ShadowCopyStorageVolume';e={$DiffVolume.DriveLetter}},
        @{n='UsedSpaceGB';e={"{0:N2}" -f ($_.UsedSpace / 1GB)}},
        @{n='AllocatedSpaceGB';e={"{0:N2}" -f ($_.AllocatedSpace / 1GB)}},
        @{n='MaxSpaceGB';e={"{0:N2}" -f ($_.MaxSpace / 1GB)}},
        @{n='UsedSpace%';e={"{0:N}" -f ($_.UsedSpace / $DiffVolume.Capacity * 100)}},
        @{n='AllocatedSpace%';e={"{0:N}" -f ($_.AllocatedSpace / $DiffVolume.Capacity * 100)}},
        @{n='MaxSpace%';e={"{0:N}" -f ($_.MaxSpace / $DiffVolume.Capacity * 100)}},
        @{n='VolumeCapacityGB';e={"{0:N2}" -f ($DiffVolume.Capacity / 1GB)}},
        @{n='VolumeFreespaceGB';e={"{0:N2}" -f ($DiffVolume.FreeSpace / 1GB)}}
    }
}