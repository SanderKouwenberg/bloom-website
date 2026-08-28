param([Parameter(Mandatory=$true)][string]$InPath)
Add-Type -AssemblyName System.Drawing
$bmp = New-Object System.Drawing.Bitmap($InPath)
$w = $bmp.Width; $h = $bmp.Height
$stepX = [math]::Max(1,[math]::Floor($w/120))
$stepY = [math]::Max(1,[math]::Floor($h/160))
$sum=0.0; $n=0; $p90=New-Object System.Collections.Generic.List[double]
for ($y=0; $y -lt $h; $y+=$stepY) {
  for ($x=0; $x -lt $w; $x+=$stepX) {
    $c = $bmp.GetPixel($x,$y)
    $lum = 0.2126*$c.R + 0.7152*$c.G + 0.0722*$c.B
    $sum += $lum; $n++
    $p90.Add($lum)
  }
}
$p90.Sort()
$avg = $sum/$n
$p90idx = [math]::Floor($p90.Count*0.9)
$p50idx = [math]::Floor($p90.Count*0.5)
$p10idx = [math]::Floor($p90.Count*0.1)
Write-Output "$InPath : gemiddeld=$([math]::Round($avg,1)) p10=$([math]::Round($p90[$p10idx],1)) mediaan=$([math]::Round($p90[$p50idx],1)) p90=$([math]::Round($p90[$p90idx],1))"
$bmp.Dispose()
