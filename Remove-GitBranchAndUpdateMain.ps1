function Remove-GitBranchAndUpdateMain {
    param(
        [string]$BranchToDelete = "Branch$env:USERNAME",
        [string]$MainBranch = "main",
        [string]$Remote = "origin"
    )

    # Ensure we're inside a git repository
    if (-not (git rev-parse --is-inside-work-tree 2>$null)) {
        Write-Error "Not inside a git repository."
        return
    }

    # Switch to main branch
    $checkout = git checkout $MainBranch 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to checkout '$MainBranch':`n$checkout"
        return
    }

    # Delete the local branch if it exists
    $localBranches = git branch --list $BranchToDelete 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to list local branches:`n$localBranches"
        return
    }

    if ([string]::IsNullOrWhiteSpace($localBranches)) {
        Write-Host "Local branch '$BranchToDelete' does not exist."
        return
    }

    # Pull latest changes for main
    $pull = git pull $Remote $MainBranch 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to pull '$MainBranch' from '$Remote':`n$pull"
        return
    }

    # Use -D to force delete; use -d if you want safe delete
    $delete = git branch -D $BranchToDelete 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to delete local branch '$BranchToDelete':`n$delete"
        return
    }

    Write-Host "Switched to '$MainBranch', pulled from '$Remote/$MainBranch', and deleted local branch '$BranchToDelete'."
}