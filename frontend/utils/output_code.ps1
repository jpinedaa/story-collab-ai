# Get all files in the current working directory
$files = Get-ChildItem -File

# Loop through each file
foreach ($file in $files) {
    # Output the name of the file
    Write-Output "File: $($file.Name)"
    
    # Output the content of the file
    Get-Content $file.FullName | ForEach-Object { Write-Output $_ }
    
    # Add a blank line for separation between files
    Write-Output ""
}
