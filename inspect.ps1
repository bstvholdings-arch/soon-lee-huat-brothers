$ErrorActionPreference = "Stop"
$proj = "C:\Users\Sheinwong88\projects\soon-lee-huat-motor"
$paths = @("/", "/admin", "/used-bikes", "/parts", "/about", "/motorcycles/test-123")

function Strip($html) {
    $h = $html -replace '(?s)<script.*?</script>', ' '
    $h = $h -replace '(?s)<style.*?</style>', ' '
    $h = $h -replace '(?s)<[^>]+>', ' '
    $h = $h -replace '&[a-z]+;', ' '
    $h = $h -replace '&#\d+;', ' '
    $words = $h -split '\s+' | Where-Object { $_ -ne '' }
    return ($words -join ' ')
}

foreach ($p in $paths) {
    try {
        $r = Invoke-WebRequest -Uri ("http://localhost:3000" + $p) -UseBasicParsing -TimeoutSec 25
        $txt = Strip $r.Content
        Write-Host ("===== " + $p + "  [HTTP " + $r.StatusCode + ", " + $r.Content.Length + " bytes] =====")
        if ($txt.Length -gt 1500) { $txt = $txt.Substring(0, 1500) }
        Write-Host $txt
        Write-Host ""
    } catch {
        Write-Host ($p + " -> ERROR: " + $_.Exception.Message)
        Write-Host ""
    }
}
