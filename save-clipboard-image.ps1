Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$img = [System.Windows.Forms.Clipboard]::GetImage()
if ($null -eq $img) {
    Write-Output ""
    exit 0
}

$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$path = "$env:TEMP\cc-img-$timestamp.png"
$img.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
$img.Dispose()
Write-Output $path
