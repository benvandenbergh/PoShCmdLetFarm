Function Get-DomainResolvesFromDNSServerDebugLog {
    [cmdletbinding()]
    Param (
            [Parameter(Mandatory=$true)][string]$DNSserver,
            [Parameter(Mandatory=$true,ParameterSetName="domainname")][string]$domainname,
            [Parameter(Mandatory=$true,ParameterSetName="simplestring")][string]$simplestring,
            [Parameter(Mandatory=$false)][Switch]$Raw
        ) 
    
        if ($simplestring) {
            $domainnameformatted = $simplestring
        } else {
            $domainnameformatted = $domainname.replace(".","(2)") + "(0)"
        }
    
    $resultraw = (Invoke-Command -ComputerName $DNSserver -ScriptBlock {(Select-String -Path 'c:\Logs\dnsdebug.log' -Pattern $using:domainnameformatted -SimpleMatch).Line})
    
    if ($raw) {$resultraw} else {
        $resultraw | ForEach-Object {
            $line = $_.replace("        "," ").replace("       "," ").replace("      "," ").replace("     "," ").replace("    "," ").replace("   "," ").replace("  "," ")
            [PSCustomObject]@{date=get-date "$($line.split(" ")[0]) $($line.split(" ")[1])";Protocol=$line.split(" ")[5];SendRcv=$line.split(" ")[6];ClientIP=$line.split(" ")[7];QuestionType=$line.split(" ")[13];QuestionName=$line.split(" ")[14]}
        }
    }
}