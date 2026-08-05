param([string]$Path)
$sr = New-Object System.IO.StreamReader($Path, [System.Text.Encoding]::UTF8)
$chunk = New-Object char[] 8388608
$carry = ""
$h = @{}
$rx = [regex]"class=\x22row error\x22.{0,2500}?class=\x22text\x22>([^<]+)</div>"
$total = 0
while (($n = $sr.Read($chunk, 0, $chunk.Length)) -gt 0) {
    $s = $carry + (-join $chunk[0..($n-1)])
    $m = $rx.Matches($s)
    foreach ($x in $m) {
        $k = $x.Groups[1].Value
        if ($h.ContainsKey($k)) { $h[$k]++ } else { $h[$k] = 1 }
        $total++
    }
    $carry = $s.Substring([Math]::Max(0, $s.Length - 2600))
}
$sr.Close()
"HASH-COUNT: $total"
$h.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 30 | ForEach-Object {
    "{0} x {1}" -f $_.Value, $_.Key.Substring(0, [Math]::Min(110, $_.Key.Length))
}
"UNIQUE: $($h.Count)"
