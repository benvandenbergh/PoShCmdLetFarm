Function get-uptimeperiods {
    $shutdowntime = Get-Date
    Remove-Variable objectCollection -Force -ErrorAction SilentlyContinue
    $objectCollection=@()
    Get-EventLog -LogName System -After $((get-date).AddDays(-14)) -Source EventLog,USER32 | 
        Where-Object {($_.EventId -eq 6009) -or ($_.EventID -eq 1074)} | ForEach-Object {
            if ($_.EventId -eq 6009) {
                $objectCollection += New-Object PSObject -Property ([ordered]@{
                #$objectCollection += New-Object PSObject -Property (@{
                    "Startup"   = $_.TimeGenerated
                    "Shutdown"  = $shutdowntime
                    "Uptime"    = $($shutdowntime - $_.TimeGenerated)
                })
            } else {
                $shutdowntime = $_.TimeGenerated
            }
        }
    $objectCollection
}