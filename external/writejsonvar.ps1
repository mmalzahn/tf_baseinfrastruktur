$jsonpayload = [Console]::In.ReadLine()
$json = ConvertFrom-Json $jsonpayload
$workdir = $json.workdir
Out-File -FilePath $($workdir+"tmp-var.json") -InputObject $json.dumps()
Write-Output '{"result":"ok"}'
