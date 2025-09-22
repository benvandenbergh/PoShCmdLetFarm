function New-GitBranchAndPush {
    param(
        [Parameter(Mandatory=$true)][ValidateSet('feat','fix','build', 'chore','docs','test','style','ci','refactor','perf')][string]$CommitType,
        [Parameter(Mandatory=$true)][string]$CommitMessage,
        [string]$BranchName = "Branch$($env:USERNAME)",
        [string]$Remote = "origin"
    )

    # Ensure we're inside a git repository
    if (-not (git rev-parse --is-inside-work-tree 2>$null)) {
        Write-Error "Not inside a git repository."
        return
    }

    # Create and switch to the new branch
    $create = git checkout -b $BranchName 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create/switch to branch '$BranchName'. Details:`n$create"
        return
    }

    # Stage all changes
    $add = git add -A 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to stage files. Details:`n$add"
        return
    }

    # Commit changes (allow empty commit if there are no staged changes)
    $commit = git commit -m "$($CommitType): $CommitMessage" --allow-empty 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to commit. Details:`n$commit"
        return
    }

    # Push branch to remote and set upstream
    $push = git push -u $Remote $BranchName 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to push branch '$BranchName' to '$Remote'. Details:`n$push"
        return
    }

    Write-Host "Branch '$BranchName' created, committed, and pushed to '$Remote'."
}