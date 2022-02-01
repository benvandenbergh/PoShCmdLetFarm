function Shadow-RDSsession {
    [cmdletbinding()]
    Param (
            [Parameter(Mandatory=$true)][string]$RDSServer,
            [Parameter(Mandatory=$true)][string]$SessionID,
            [Parameter(Mandatory=$false)][Switch]$NoControl
        )
    
    $argumentlist = "/v:$RDSServer /shadow:$SessionID"
    if (!($NoControl)) {$argumentlist += " /control"}
    Start-Process -NoNewWindow -FilePath "C:\Windows\System32\mstsc.exe" -ArgumentList $argumentlist
}