param(
  [int]$Port = 8000
)

$root = Get-Location
function Get-ContentType($file) {
  $ext = [System.IO.Path]::GetExtension($file).ToLower()
  switch ($ext) {
    '.html' { 'text/html' }
    '.htm'  { 'text/html' }
    '.js'   { 'application/javascript' }
    '.css'  { 'text/css' }
    '.json' { 'application/json' }
    '.png'  { 'image/png' }
    '.jpg'  { 'image/jpeg' }
    '.jpeg' { 'image/jpeg' }
    '.gif'  { 'image/gif' }
    default { 'application/octet-stream' }
  }
}

$listener = New-Object System.Net.HttpListener
$prefix = "http://localhost:$Port/"
$listener.Prefixes.Add($prefix)
Write-Host "Starting simple server at $prefix (root: $root)"
$listener.Start()
try {
  while ($true) {
    $context = $listener.GetContext()
    Start-Job -ScriptBlock {
      param($ctx, $rootPath)
      try {
        $req = $ctx.Request
        $path = [System.Uri]::UnescapeDataString($req.Url.AbsolutePath.TrimStart('/'))
        if ([string]::IsNullOrEmpty($path)) { $path = 'index.html' }
        $file = Join-Path $rootPath $path
        $resp = $ctx.Response
        if (Test-Path $file) {
          $bytes = [System.IO.File]::ReadAllBytes($file)
          $resp.ContentType = Get-ContentType $file
          $resp.ContentLength64 = $bytes.Length
          $resp.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
          $resp.StatusCode = 404
          $body = [Text.Encoding]::UTF8.GetBytes("404 Not Found")
          $resp.OutputStream.Write($body, 0, $body.Length)
        }
        $resp.Close()
      } catch {
        try { $ctx.Response.Close() } catch {}
      }
    } -ArgumentList $context, $root | Out-Null
  }
} finally {
  $listener.Stop()
  $listener.Close()
}
