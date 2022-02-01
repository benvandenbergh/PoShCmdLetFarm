Function Get-DfsrBacklogCounters {
    $replicatedfolder = Get-DfsReplicationGroup | Out-GridView -Title "Select Replication Group" -OutputMode Single | Get-DfsReplicatedFolder | Out-GridView -Title "Select Replicated Folder" -OutputMode Single

    Get-DfsReplicationGroup -DomainName $replicatedfolder.DomainName -GroupName $replicatedfolder.GroupName | Get-DfsrConnection | Invoke-Parallel -ImportVariables -ScriptBlock {
        $replconnection = $_
        $backlog = ((dfsrdiag backlog /rgname:$($replconnection.GroupName) /rfname:$($replicatedfolder.FolderName) /smem:$($replconnection.SourceComputerName) /rmem:$($replconnection.DestinationComputerName))[1]).split(":")[1]
        $replconnection | Select-Object *,@{n="BackLog";e={$backlog}}
    } | Select-Object GroupName,SourceComputerName,DestinationComputerName,BackLog
}
