$root = "C:\"
$output = "C:\Disk_Usage_Report.txt"

# Initialize report
"==============================" | Out-File $output -Encoding UTF8
"C DRIVE DISK USAGE TREE REPORT" | Out-File $output -Append -Encoding UTF8
"Generated: $(Get-Date)"         | Out-File $output -Append -Encoding UTF8
"==============================" | Out-File $output -Append -Encoding UTF8
"" | Out-File $output -Append -Encoding UTF8

Write-Host "Scanning C drive (this may take time)..." -ForegroundColor Cyan

# Function to calculate folder size safely
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

# Get top-level folders
$folders = Get-ChildItem $root -Directory -Force -ErrorAction SilentlyContinue

foreach ($folder in $folders) {

    $folderSize = Get-FolderSize $folder.FullName
    $folderLine = "{0} [{1:N2} GB]" -f $folder.FullName, ($folderSize / 1GB)

    $folderLine | Out-File $output -Append -Encoding UTF8

    # Subfolders
    $subFolders = Get-ChildItem $folder.FullName -Directory -Force -ErrorAction SilentlyContinue

    foreach ($sub in $subFolders) {

        $subSize = Get-FolderSize $sub.FullName

        $subLine = "    ↳ {0} [{1:N2} GB]" -f $sub.FullName, ($subSize / 1GB)

        $subLine | Out-File $output -Append -Encoding UTF8
    }

    "" | Out-File $output -Append -Encoding UTF8
}

"`n===== REPORT COMPLETED =====" | Out-File $output -Append -Encoding UTF8

Write-Host "Report generated at: $output" -ForegroundColor Green
