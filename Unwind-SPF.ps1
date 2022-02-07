function Unwind-SPF {
    param (
        [string]$DNSName,
        [int]$Level=0,
        [string]$DNSserver = "1.1.1.1"
    )
    Resolve-DnsName $DNSName -Type TXT -Server $DNSserver |
        ForEach-Object {
            if ($_.Text -match 'v=spf1\s'){
                [PSCustomObject]@{
                    Depth = $Level
                    'DNS Name' =$_.Name
                }
                $_.Text -Split '\s' |
                    Where-Object {$_ -match 'include:(.+$)'}|
                        ForEach-Object  {
                            Unwind-SPF $Matches[1] ($Level + 1)
                        }
            }
        }
}