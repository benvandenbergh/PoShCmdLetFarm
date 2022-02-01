Function Get-FortinetRating {   
    <#
    .SYNOPSIS
        Get Fortinet rating through fortiguard
    .PARAMETER url
        this is the url you want to check
    .EXAMPLE
        Get-FortinetRating -url spacex.com
    #>
    
    Param (
        [Parameter(Position=0, ParameterSetName="Value", Mandatory=$true)]
        [string]$url
    )
    
    $result = (Invoke-WebRequest "https://fortiguard.com/webfilter?q=$url") -split "`n" | Select-String -Pattern '<h4 class="info_title">Category:' -CaseSensitive -SimpleMatch -Context 0,1

    $result | Select-Object `
        @{name="Url";e={$url}},`
        @{name="Category";e={$_.line.split(":")[1].replace("</h4>","").Trim()}},`
        @{name="Description";e={$_.Context.PostContext.split("<br>")[0].replace("<p>","").trim()}},`
        @{name="Group";e={$_.Context.PostContext.split("<br>")[1].split("-")[0].replace("Group:","").Trim()}}       
}  
