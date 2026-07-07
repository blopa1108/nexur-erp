$port = 5700
$root = $PSScriptRoot
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Serving $root on http://localhost:$port/"
while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $path = $ctx.Request.Url.LocalPath.TrimStart('/')
    if ($path -eq '') { $path = 'erp-index.html' }
    $file = Join-Path $root $path
    if (Test-Path $file -PathType Leaf) {
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $ext = [System.IO.Path]::GetExtension($file).ToLower()
        $mime = switch ($ext) { '.html' {'text/html; charset=utf-8'} '.css' {'text/css'} '.js' {'application/javascript'} default {'application/octet-stream'} }
        $ctx.Response.ContentType = $mime
        $ctx.Response.StatusCode = 200
        $ctx.Response.SendChunked = $true
        $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $ctx.Response.StatusCode = 404
    }
    $ctx.Response.Close()
}
