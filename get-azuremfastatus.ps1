function get-AzureMFAstatus {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)][string]$UserPrincipalName
    )
    Get-MsolUser -UserPrincipalName $userprincipalname | Select-Object userprincipalname,@{n="MFA Status";e={$_.StrongAuthenticationRequirements.state}},@{n="default MFAmethod";e={($_.StrongAuthenticationMethods | Where-Object IsDefault).MethodType}},@{n="other MFAmethods";e={($_.StrongAuthenticationMethods | Where-Object {!$_.IsDefault}).MethodType -join ","}},@{n="PhoneNumber";e={$_.StrongAuthenticationUserDetails.PhoneNumber}},@{n="AlternativePhoneNumber";e={$_.StrongAuthenticationUserDetails.AlternativePhoneNumber}}
}