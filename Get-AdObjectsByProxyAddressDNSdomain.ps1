function Get-AdObjectsByProxyAddressDNSdomain {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)][string]$DNSdomain
    )
    $adobjectfilter = "proxyaddresses -like ""*@$DNSdomain*"""
    Get-ADObject -Filter $adobjectfilter -Properties samaccountname,proxyaddresses,canonicalname | foreach-object {
        $obj = $_
        $obj.proxyaddresses | Select-String -SimpleMatch $DNSdomain | ? {$_.Line -like "*@$DNSdomain"} | foreach-object {
            $line = $_
            $obj | Select-Object canonicalname,objectclass,@{name="proxyaddr";e={$line.Line}},ObjectGUID
        }
    }
}