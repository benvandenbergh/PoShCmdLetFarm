Function Read-FortinetLog {
    [CmdletBinding()]
    param(
    [Parameter(Mandatory=$true)]$FilePath
    )

    Get-Content -Path $FilePath | ForEach-Object {
        $obj = [PSCustomObject]@{}
        ($_ -replace ".$").Substring(1).Split(""",""") | ForEach-Object {
            "XX $_ XX"
            $obj | Add-Member -MemberType NoteProperty -Name $_.Split("=")[0] -Value $_.Split("=",2)[1].replace("""","")
        }
        $obj
    }
}