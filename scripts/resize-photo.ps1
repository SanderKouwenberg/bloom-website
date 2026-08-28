<#
Eenmalig gebruikt hulpscript om brongfoto's uit sources/ te croppen naar een vaste
beeldverhouding, te verkleinen en als JPEG te comprimeren. Niet onderdeel van de
build - los uit te voeren met PowerShell.
#>
param(
    [Parameter(Mandatory=$true)][string]$InPath,
    [Parameter(Mandatory=$true)][string]$OutPath,
    [Parameter(Mandatory=$true)][int]$TargetW,
    [Parameter(Mandatory=$true)][int]$TargetH,
    [double]$FocusX = 0.5,
    [double]$FocusY = 0.5,
    [int]$Quality = 82
)

Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Image]::FromFile($InPath)
$srcW = $src.Width
$srcH = $src.Height

$targetRatio = $TargetW / $TargetH
$srcRatio = $srcW / $srcH

if ($srcRatio -gt $targetRatio) {
    # bron is relatief breder -> breedte inkorten
    $cropH = $srcH
    $cropW = [math]::Round($srcH * $targetRatio)
} else {
    # bron is relatief hoger -> hoogte inkorten
    $cropW = $srcW
    $cropH = [math]::Round($srcW / $targetRatio)
}

$maxX = $srcW - $cropW
$maxY = $srcH - $cropH
$cropX = [math]::Round($maxX * $FocusX)
$cropY = [math]::Round($maxY * $FocusY)

$bmp = New-Object System.Drawing.Bitmap($TargetW, $TargetH)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

$srcRect = New-Object System.Drawing.Rectangle($cropX, $cropY, $cropW, $cropH)
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
Write-Output "$OutPath : ${TargetW}x${TargetH}, $([math]::Round($fileSize/1KB)) KB (bron crop ${cropW}x${cropH} bij $cropX,$cropY)"
