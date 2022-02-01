Function Get-MacVendor {   <#
    .SYNOPSIS
        Get MAC Vendor through macvendors.com-api
    .PARAMETER MAC
        The MAC-address as a string. The format can be:
            00-11-22-33-44-55
            00:11:22:33:44:55
            00.11.22.33.44.55
            001122334455
            0011.2233.4455
    .EXAMPLE
        Get-MacVendor -MAC 001122334455
    #>
    
    Param(
        [Parameter(Position=0, ParameterSetName="Value", Mandatory=$true)]
        [string]$MAC
    )
    (Invoke-WebRequest "http://api.macvendors.com/$MAC").Content
}