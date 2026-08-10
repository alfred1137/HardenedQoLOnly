param([string]$Path)
$sr = New-Object System.IO.StreamReader($Path, [System.Text.Encoding]::UTF8)
$chunk = New-Object char[] 8388608
$carry = ""
$h = @{}
$rx = [regex]"the index '([^']+)' does not exist"
while (($n = $sr.Read($chunk, 0, $chunk.Length)) -gt 0) {
    $s = $carry + (-join $chunk[0..($n-1)])
    $m = $rx.Matches($s)
    foreach ($x in $m) {
        $k = $x.Groups[1].Value
        if ($h.ContainsKey($k)) { $h[$k]++ } else { $h[$k] = 1 }
    }
    $carry = $s.Substring([Math]::Max(0, $s.Length - 400))
}
$sr.Close()
$total = 0
$h.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
    $total += $_.Value
    "{0} x {1}" -f $_.Value, $_.Key
}
"TOTAL index-errors: $total"

"---"
"row error count:"; $sr2 = New-Object System.IO.StreamReader($Path, [System.Text.Encoding]::UTF8); $chunk2 = New-Object char[] 8388608; $carry2=""; $rowerr=0; $screrr=0; $msg=@{}; $rx3=[regex]"<div class=\x22text\x22>([^<]+)</div>"; while (($n=$sr2.Read($chunk2,0,$chunk2.Length)) -gt 0) { $s2=$carry2+(-join $chunk2[0..($n-1)]); $rowerr += ([regex]::Matches($s2,"class=\x22row error\x22")).Count; $screrr += ([regex]::Matches($s2,"Script Error")).Count; $mm=$rx3.Matches($s2); foreach($x in $mm){$k=$x.Groups[1].Value; if($msg.ContainsKey($k)){$msg[$k]++}else{$msg[$k]=1}}; $carry2=$s2.Substring([Math]::Max(0,$s2.Length-400)) }; $sr2.Close(); "row error: $rowerr"; "Script Error literals: $screrr"; "top text msgs (>10):"; $msg.GetEnumerator() | Sort-Object Value -Descending | Where-Object {$_.Value -gt 10} | Select-Object -First 25 | ForEach-Object { "{0} x {1}" -f $_.Value, $_.Key.Substring(0,[Math]::Min(90,$_.Key.Length)) }
