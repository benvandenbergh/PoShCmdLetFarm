Function Drain-RDS {
    [CmdletBinding()]
    param(
    [Parameter(Position=0, ParameterSetName="Value", Mandatory=$true)]
    [String[]]$servers,
    [Parameter(Position=1, ParameterSetName="Value", Mandatory=$true)]
    [Int32]$idleTimeInMinutes
     )
   
   1..9999 | ForEach-Object {
       Foreach ($server in $servers) {
   
           Get-RDSsession $server | Where-Object {(($_.IdleTime.TotalMinutes -gt $idleTimeInMinutes) -and ($_.IdleTime.Days -ne 24692)) -or ($_.SessionState -ne "Active")} | Sort-Object IdleTime | Format-Table -AutoSize
           Get-RDSsession $server | Where-Object {(($_.IdleTime.TotalMinutes -gt $idleTimeInMinutes) -and ($_.IdleTime.Days -ne 24692)) -or ($_.SessionState -ne "Active")} | ForEach-Object {
               Write-Host "$(Get-Date): Logging of $_" -ForegroundColor Cyan
               Write-Host "logoff $($_.SessionId) /SERVER:$($_.server)"
               logoff.exe $($_.SessionId) /SERVER:$($_.server)
               Write-Host "$(Get-Date): Done" -ForegroundColor Cyan
           }
       }
       Start-Sleep -Seconds 60
   }
}
