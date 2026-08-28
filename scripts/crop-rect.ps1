<#
Eenmalig hulpscript: crop een expliciet rechthoekig gebied (in bronpixels) en
schaal naar een doelformaat. Voor situaties waarin de generieke aspect-ratio
crop in resize-photo.ps1 niet precies genoeg is (bijv. verder inzoomen op een
onderwerp). Niet onderdeel van de build.
#>
param(
    [Parameter(Mandatory=$true)][string]$InPath,
    [Parameter(Mandatory=$true)][string]$OutPath,
    [Parameter(Mandatory=$true)][int]$CropX,
    [Parameter(Mandatory=$true)][int]$CropY,
    [Parameter(Mandatory=$true)][int]$CropW,
    [Parameter(Mandatory=$true)][int]$CropH,
    [Parameter(Mandatory=$true)][int]$TargetW,
    [Parameter(Mandatory=$true)][int]$TargetH,
    [int]$Quality = 88
)

Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Image]::FromFile($InPath)

$bmp = New-Object System.Drawing.Bitmap($TargetW, $TargetH)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

$srcRect = New-Object System.Drawing.Rectangle($CropX, $CropY, $CropW, $CropH)
$dstRect = New-Object System.Drawing.Rectangle(0, 0, $TargetW, $TargetH)
$g.DrawImage($src, $dstRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)

$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]$Quality)

$bmp.Save($OutPath, $jpegCodec, $encParams)

$g.Dispose()
$bmp.Dispose()
$src.Dispose()

$fileSize = (Get-Item $OutPath).Length
Write-Output "$OutPath : ${TargetW}x${TargetH}, $([math]::Round($fileSize/1KB)) KB"
