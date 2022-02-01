function Download-File {
    <#
    .Synopsis
    Download file and show progress
    
    .DESCRIPTION
    This function downloads the file and show the progress it is downloading
    
    .NOTES   
    Name: Download-File
    Author: BenVDB
    Version: 1.0
    DateUpdated: 2017-03-30
    
    .PARAMETER Url
    The Sender Address
        
    .PARAMETER TargetFullPath
    The recipient
    #>
       [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory=$true)]
            [string]$Url,
            [Parameter(Mandatory=$true)]
            [string]$TargetFullPath
    
        )
       $uri = New-Object "System.Uri" "$Url"
       $request = [System.Net.HttpWebRequest]::Create($uri)
       $request.set_Timeout(15000) #15 second timeout
       $response = $request.GetResponse()
       $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
       $responseStream = $response.GetResponseStream()
       $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $TargetFullPath, Create
       $buffer = new-object byte[] 10KB
       $count = $responseStream.Read($buffer,0,$buffer.length)
       $downloadedBytes = $count
       while ($count -gt 0) {
           $targetStream.Write($buffer, 0, $count)
           $count = $responseStream.Read($buffer,0,$buffer.length)
           $downloadedBytes = $downloadedBytes + $count
           Write-Progress -activity "Downloading file '$($Url.split('/') | Select-Object -Last 1)'" -status "Downloaded ($([System.Math]::Floor($downloadedBytes/1024))K of $($totalLength)K): " -PercentComplete ((([System.Math]::Floor($downloadedBytes/1024)) / $totalLength)  * 100)
    
       }
    
       Write-Progress -activity "Finished downloading file '$($Url.split('/') | Select-Object -Last 1)'"
       $targetStream.Flush()
       $targetStream.Close()
       $targetStream.Dispose()
       $responseStream.Dispose()
    }    