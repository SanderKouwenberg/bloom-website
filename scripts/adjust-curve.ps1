<#
Eenmalig hulpscript: past een helderheidscurve toe (lineaire vermenigvuldiging
onder een drempel, een aparte helling erboven om specifiek hooglichten te
temperen of juist op te lichten). Werkt per kanaal via een lookup-table op de
ruwe pixelbytes (snel genoeg voor foto's van een paar megapixel). Niet
onderdeel van de build.
#>
param(
    [Parameter(Mandatory=$true)][string]$InPath,
    [Parameter(Mandatory=$true)][string]$OutPath,
    [double]$BelowMult = 1.0,
    [int]$Threshold = 255,
    [double]$AboveSlope = 1.0,
    [int]$Quality = 90
)

Add-Type -AssemblyName System.Drawing

# LUT opbouwen
$lut = New-Object byte[] 256
for ($v = 0; $v -lt 256; $v++) {
    if ($v -le $Threshold) {
        $o = $v * $BelowMult
    } else {
        $baseVal = $Threshold * $BelowMult
        $o = $baseVal + ($v - $Threshold) * $AboveSlope
    }
    if ($o -lt 0) { $o = 0 }
    if ($o -gt 255) { $o = 255 }
    $lut[$v] = [byte][math]::Round($o)
}

$src = New-Object System.Drawing.Bitmap($InPath)
$bmp = New-Object System.Drawing.Bitmap($src.Width, $src.Height, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.DrawImage($src, 0, 0, $src.Width, $src.Height)
$g.Dispose()
$src.Dispose()

$rect = New-Object System.Drawing.Rectangle(0, 0, $bmp.Width, $bmp.Height)
$data = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)

$stride = $data.Stride
$byteCount = $stride * $bmp.Height
$bytes = New-Object byte[] $byteCount
[System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $byteCount)

for ($i = 0; $i -lt $byteCount; $i++) {
    $bytes[$i] = $lut[$bytes[$i]]
}

[System.Runtime.InteropServices.Marshal]::Copy($bytes, 0, $data.Scan0, $byteCount)
$bmp.UnlockBits($data)

$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]$Quality)
$bmp.Save($OutPath, $jpegCodec, $encParams)
$bmp.Dispose()

$fileSize = (Get-Item $OutPath).Length
Write-Output "$OutPath : $([math]::Round($fileSize/1KB)) KB"
