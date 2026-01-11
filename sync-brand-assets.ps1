# ETHINX Brand Sync Script
# Run this to sync assets from design folders to repository

param(
    [string]$SourceBase = "C:\Users\tdogg\OneDrive\Desktop\Design",
    [string]$CommitMessage = "Sync brand assets"
)

$RepoPath = "C:\Users\tdogg\OneDrive\Desktop\ethinx-autonomous\ETHINX_Brand"

function Write-Status {
    param([string]$Message, [string]$Status = "info")
    
    switch ($Status) {
        "success" { Write-Host "✅ $Message" -ForegroundColor Green }
        "warning" { Write-Host "⚠ $Message" -ForegroundColor Yellow }
        "error" { Write-Host "❌ $Message" -ForegroundColor Red }
        default { Write-Host "ℹ $Message" -ForegroundColor Cyan }
    }
}

Write-Host "🔄 ETHINX Brand Asset Sync" -ForegroundColor Magenta
Write-Host "==========================================" -ForegroundColor Magenta

# Check if source folders exist
if (-not (Test-Path $SourceBase)) {
    Write-Status "Source directory not found: $SourceBase" "warning"
    Write-Status "Creating placeholder structure..." "info"
    
    # Create source structure
    New-Item -ItemType Directory -Force -Path "$SourceBase\Logos" | Out-Null
    New-Item -ItemType Directory -Force -Path "$SourceBase\Banners" | Out-Null
    New-Item -ItemType Directory -Force -Path "$SourceBase\Gradients" | Out-Null
    New-Item -ItemType Directory -Force -Path "$SourceBase\Charts" | Out-Null
    
    Write-Status "Created source directory structure at $SourceBase" "success"
    Write-Status "Please place your design files in these folders:" "info"
    Write-Host "   • $SourceBase\Logos\" -ForegroundColor Gray
    Write-Host "   • $SourceBase\Banners\" -ForegroundColor Gray
    Write-Host "   • $SourceBase\Gradients\" -ForegroundColor Gray
    Write-Host "   • $SourceBase\Charts\" -ForegroundColor Gray
} else {
    # Sync existing files
    $syncOperations = 0
    
    if (Test-Path "$SourceBase\Logos") {
        Write-Status "Syncing logos..." "info"
        robocopy "$SourceBase\Logos" "$RepoPath\Logos_&_Icons" /E /XO /NJH /NJS /NDL /NC /NS
        $syncOperations++
    }
    
    if (Test-Path "$SourceBase\Banners") {
        Write-Status "Syncing banners..." "info"
        robocopy "$SourceBase\Banners" "$RepoPath\Banners" /E /XO /NJH /NJS /NDL /NC /NS
        $syncOperations++
    }
    
    if (Test-Path "$SourceBase\Gradients") {
        Write-Status "Syncing gradients..." "info"
        robocopy "$SourceBase\Gradients" "$RepoPath\Gradients_LUTs" /E /XO /NJH /NJS /NDL /NC /NS
        $syncOperations++
    }
    
    if (Test-Path "$SourceBase\Charts") {
        Write-Status "Syncing charts..." "info"
        robocopy "$SourceBase\Charts" "$RepoPath\Charts" /E /XO /NJH /NJS /NDL /NC /NS
        $syncOperations++
    }
    
    Write-Status "Completed $syncOperations sync operations" "success"
}

# Git operations
Set-Location $RepoPath
Write-Status "Updating Git repository..." "info"

$changes = git status --porcelain
if ($changes) {
    git add .
    git commit -m "$CommitMessage - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    Write-Status "Committed changes with message: $CommitMessage" "success"
    
    # Show what changed
    Write-Host "
📝 Changes made:" -ForegroundColor Cyan
    git show --name-only --oneline HEAD | Select-Object -Skip 1
} else {
    Write-Status "No changes to commit" "info"
}

Write-Host "
🎯 Next steps:" -ForegroundColor Magenta
Write-Host "1. Review BRAND_GUIDELINES.md for brand compliance" -ForegroundColor Cyan
Write-Host "2. Check Templates/ folder for usage examples" -ForegroundColor Cyan
Write-Host "3. Run .\brand-health-check.ps1 to validate assets" -ForegroundColor Cyan
