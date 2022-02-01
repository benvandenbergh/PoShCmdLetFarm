Function Schedule-Restart {
    <#
    .SYNOPSIS
        Schedule a restart on a remote computer
    .PARAMETER ComputerName
        The name of the computer to restart
    .PARAMETER AddDays
        The number of days in the future you want to perform the restart
    .PARAMETER Hour
        The hour you want the restart to initiate
    .PARAMETER Minute
        The minute you want the restart to initiate
    .EXAMPLE
        Schedule-Restart -ComputerName Server1 -AddDays 1 -Hour 5 -Minute 5
    .NOTES
        Author:            Ben Van den Bergh
    #>
    Param(
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,
        [Int32]$AddDays = 1,
        [Int32]$Hour = 3,
        [Int32]$Minute = 0
        
    )

    $TotalSeconds = ([decimal]::round(((get-date -Hour $Hour -Minute $Minute -Second 00).adddays($AddDays) - (Get-Date)).TotalSeconds))

    if ($TotalSeconds -gt 0) {
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {shutdown -r -t $using:TotalSeconds}
    } else {
        Write-Error -Message "You are trying te schedule in the past"
        Break
    }
}