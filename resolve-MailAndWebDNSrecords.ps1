function resolve-MailAndWebDNSrecords {
    <#
    .SYNOPSIS
        Get Mail- and Web-related DNS records
    .PARAMETER DNSdomain 
        Public DNS domain-name
    .EXAMPLE
        resolve-MailAndWebDNSrecords -DNSdomain spacex.com
    .NOTES   
        Name: resolve-MailAndWebDNSrecords
        Author: BenVDB
   #>
   [cmdletbinding()]
   Param (
           [Parameter(Mandatory=$true)][string]$DNSdomain,
           [string]$DNSserver = "1.1.1.1"
       ) 
   $mxrecords = Resolve-DnsName -Name $DNSdomain -Type MX -Server $DNSserver -ErrorAction SilentlyContinue
   $nsrecords = (Resolve-DnsName -Name $DNSdomain -Type NS -Server $DNSserver -ErrorAction SilentlyContinue).NameHost -join ","
   $txtrecords = Resolve-DnsName -Name $DNSdomain -Type TXT -Server $DNSserver -ErrorAction SilentlyContinue
   $dmarc = Resolve-DnsName -Name _dmarc.$DNSdomain -Type TXT -Server $DNSserver -ErrorAction SilentlyContinue
   $aroot = Resolve-DnsName -Name $DNSdomain -Server $DNSserver -ErrorAction SilentlyContinue -Type A
   $www = Resolve-DnsName -Name www.$DNSdomain -Server $DNSserver -ErrorAction SilentlyContinue -Type A
   $autodiscover = Resolve-DnsName -Name autodiscover.$DNSdomain -Server $DNSserver -ErrorAction SilentlyContinue
   $_autodiscover = Resolve-DnsName -Name _autodiscover._tcp.$DNSdomain -Server $DNSserver -Type SRV -ErrorAction SilentlyContinue
   $lyncdiscover = Resolve-DnsName -Name lyncdiscover.$DNSdomain -Server $DNSserver -ErrorAction SilentlyContinue -Type A
   $sip = Resolve-DnsName -Name sip.$DNSdomain -Server $DNSserver -ErrorAction SilentlyContinue -Type A
   $meet = Resolve-DnsName -Name meet.$DNSdomain -Server $DNSserver -ErrorAction SilentlyContinue -Type A
   $_sipfederationtls = Resolve-DnsName -Name _sipfederationtls._tcp.$DNSdomain -Server $DNSserver -Type SRV -ErrorAction SilentlyContinue
   $_sip = Resolve-DnsName -Name _sip._tls.$DNSdomain -Server $DNSserver -Type SRV -ErrorAction SilentlyContinue
   $otherTXTrecords = ($txtrecords | Where-Object Type -ne "SOA" | Where-Object Strings -notlike "*spf*").count

   if ($aroot.IpAddress) {
       if ((Resolve-DnsName $aroot.IpAddress -ErrorAction SilentlyContinue).NameHost -eq "relay.hostbasket.com") {
           $arootresult = (Invoke-WebRequest $DNSdomain -MaximumRedirection 0 -ErrorAction SilentlyContinue).Headers.Location
       } else {
           $arootresult = $aroot.IPAddress
       }
   }

   if($www.IpAddress) {
       if ((Resolve-DnsName $www.IpAddress -ErrorAction SilentlyContinue).NameHost -eq "relay.hostbasket.com") {
           $wwwresult = (Invoke-WebRequest $DNSdomain -MaximumRedirection 0 -ErrorAction SilentlyContinue).Headers.Location
       } else {
           $wwwresult = $www.IPAddress
       }
   }

   [PSCustomObject]@{DNSserver=$DNSserver;DNSdomain=$DNSdomain;NameServers=$nsrecords;aRoot=$arootresult;www=$wwwresult;MX=$mxrecords.NameExchange;autodiscover=$autodiscover.IpAddress;_autodiscover=$_autodiscover.NameTarget;lyncdiscover=$lyncdiscover.IpAddress;sip=$sip.IpAddress;meet=$meet.IpAddress;_sip="$($_sip.NameTarget):$($_sip.Port)";_sipfederationtls="$($_sipfederationtls.NameTarget):$($_sipfederationtls.Port)";SPF1=($txtrecords | Where-Object Strings -like "*spf1*").Strings;SPF2=($txtrecords | Where-Object Strings -like "*spf2*").Strings;DMARC=$dmarc.Strings;"#otherRootTXT"=$otherTXTrecords}
}