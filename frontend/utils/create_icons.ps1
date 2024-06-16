# Define the source image and the destination folder
$sourceImage = "C:\Users\j_jor\OneDrive\Pictures\c379a424-8c9d-4056-89e5-552a8172eeca.webp"
$destinationFolder = "./"

# Ensure the destination folder exists
if (-not (Test-Path $destinationFolder)) {
    New-Item -ItemType Directory -Path $destinationFolder
}

# Define the sizes and names for the Flutter web icons
$icons = @(
    @{ name = "Icon-192.png"; width = 192; height = 192 },
    @{ name = "Icon-512.png"; width = 512; height = 512 },
    @{ name = "Icon-maskable-192.png"; width = 192; height = 192 },
    @{ name = "Icon-maskable-512.png"; width = 512; height = 512 }
)

# Function to resize an image using mspaint and PowerShell
function Resize-Image {
    param (
        [string]$sourcePath,
        [string]$destinationPath,
        [int]$width,
        [int]$height
    )
    
    # Open the image in mspaint
    Start-Process mspaint.exe $sourcePath
    Start-Sleep -Seconds 2
    
    # Get the handle of the mspaint window
    $handle = (Get-Process mspaint | Select-Object -First 1).MainWindowHandle
    
    # Send keys to resize the image
    [System.Windows.Forms.SendKeys]::SendWait('%i')  # Alt + Image menu
    Start-Sleep -Milliseconds 500
    [System.Windows.Forms.SendKeys]::SendWait('s')  # Select resize option
    Start-Sleep -Milliseconds 500
    [System.Windows.Forms.SendKeys]::SendWait('%w')  # Select width field
    Start-Sleep -Milliseconds 500
    [System.Windows.Forms.SendKeys]::SendWait("$width{TAB}$height{ENTER}")  # Enter width and height
    Start-Sleep -Milliseconds 500
    [System.Windows.Forms.SendKeys]::SendWait('^s')  # Save image with Ctrl + S
    Start-Sleep -Milliseconds 500
    
    # Save the resized image
    Copy-Item -Path $sourcePath -Destination $destinationPath -Force
    
    # Close mspaint
    Stop-Process -Id (Get-Process mspaint).Id
}

# Loop through each icon size and create the resized image
foreach ($icon in $icons) {
    $outputPath = Join-Path -Path $destinationFolder -ChildPath $icon.name
    Resize-Image -sourcePath $sourceImage -destinationPath $outputPath -width $icon.width -height $icon.height
    Write-Output "Created: $outputPath"
}

Write-Output "All icons have been created and resized successfully."