function Get-FileTimestampsAndOwner {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True,Position=1)]
        [string]$Path
    )
	
	#dir <folderpath> -Recurse -File | % {Get-FileTimestampsAndOwner -Path $_.FullName} | sort LastWriteTime -Descending | Out-GridView
	
    get-Item $Path | Select-Object CreationTime,LastWriteTime,LastAccessTime,@{n="owner";e={(Get-ADUser ((get-acl $_.fullname).owner).replace("REYNAERS\","")).name}},fullname
}