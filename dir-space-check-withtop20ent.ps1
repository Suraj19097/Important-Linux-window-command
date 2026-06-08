$root = "C:\"
$output = "C:\Disk_Usage_Report.txt"

# Clean start
"==============================" | Out-File $output -Encoding UTF8
"C DRIVE DISK USAGE REPORT" | Out-File $output -Append -Encoding UTF8
"Generated: $(Get-Date)" | Out-File $output -Append -Encoding UTF8
"==============================" | Out-File $output -Append -Encoding UTF8
"" | Out-File $output -Append -Encoding UTF8

Write-Host "Scanning C drive... Please wait (this will take time)" -ForegroundColor Cyan

# Store all directories for TOP 20 later
$allDirs = @()

function Get-FolderSize($path) {
    try {
        $size = (Get-ChildItem $path -Recurse -Force -File -ErrorAction SilentlyContinue |
                Measure-Object Length -Sum).Sum
        if ($null -eq $size) { $size = 0 }
        return $size
    }
    catch {
        return 0
    }
}

# =========================
# TREE STRUCTURE SECTION
# =========================

$folders = Get-ChildItem $root -Directory -Force -ErrorAction SilentlyContinue

foreach ($folder in $folders) {

    $folderSize = Get-FolderSize $folder.FullName

    # Save for TOP 20 analysis
    $allDirs += [PSCustomObject]@{
        Path = $folder.FullName
        Size = $folderSize
    }

    $line = "{0} [{1:N2} GB]" -f $folder.FullName, ($folderSize / 1GB)
    $line | Out-File $output -Append -Encoding UTF8

    $subFolders = Get-ChildItem $folder.FullName -Directory -Force -ErrorAction SilentlyContinue

    foreach ($sub in $subFolders) {

        $subSize = Get-FolderSize $sub.FullName

        # Save subfolder also for TOP 20
        $allDirs += [PSCustomObject]@{
            Path = $sub.FullName
            Size = $subSize
        }

        $subLine = "    ↳ {0} [{1:N2} GB]" -f $sub.FullName, ($subSize / 1GB)
        $subLine | Out-File $output -Append -Encoding UTF8
    }

    "" | Out-File $output -Append -Encoding UTF8
}

# =========================
# TOP 20 SECTION (IMPORTANT)
# =========================

"`n==============================" | Out-File $output -Append -Encoding UTF8
"TOP 20 HIGH SPACE DIRECTORIES" | Out-File $output -Append -Encoding UTF8
"==============================" | Out-File $output -Append -Encoding UTF8
"" | Out-File $output -Append -Encoding UTF8

$top20 = $allDirs |
    Where-Object { $_.Size -gt 0 } |
    Sort-Object Size -Descending |
    Select-Object -First 20

$rank = 1

foreach ($item in $top20) {

    $line = "{0,2}. {1} [{2:N2} GB]" -f $rank, $item.Path, ($item.Size / 1GB)

    $line | Out-File $output -Append -Encoding UTF8

    $rank++
}

"`n===== REPORT COMPLETED =====" | Out-File $output -Append -Encoding UTF8

Write-Host "Report generated at: $output" -ForegroundColor Green
