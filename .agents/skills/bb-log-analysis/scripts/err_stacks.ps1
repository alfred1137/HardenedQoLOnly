param([string]$Path)
$sr = New-Object System.IO.StreamReader($Path, [System.Text.Encoding]::UTF8)
$chunk = New-Object char[] 8388608
$carry = ""
$rx = [regex]"class=\x22row error\x22.{0,2500}?class=\x22text\x22>([^<]+)</div>(.{0,700})"
$seen = @{}
$order = [System.Collections.ArrayList]::new()
while (($n = $sr.Read($chunk, 0, $chunk.Length)) -gt 0) {
    $s = $carry + (-join $chunk[0..($n-1)])
    $m = $rx.Matches($s)
    foreach ($x in $m) {
        $k = $x.Groups[1].Value
        if (-not $seen.ContainsKey($k)) {
            $seen[$k] = $x.Groups[2].Value
            [void]$order.Add($k)
        }
    }
    $carry = $s.Substring([Math]::Max(0, $s.Length - 3200))
}
$sr.Close()
foreach ($k in $order) {
    "=== $k ==="
    ($seen[$k] -replace '<[^>]+>', ' ') -replace '\s+', ' '
    ""
}
