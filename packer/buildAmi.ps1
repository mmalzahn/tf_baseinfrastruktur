$jsonpayload = [Console]::In.ReadLine()
# Convert to JSON
$json = ConvertFrom-Json $jsonpayload

# Access JSON values 
$responsible = $json.responsible
$packerId = $json.packerId
$project = $json.project
$projectprefix = $json.projectprefix
$jsonfile = $json.jsonfile
$workdir = $json.workdir

Out-File -FilePath $($workdir+"tmp-var.json") -Encoding utf8 -InputObject $jsonpayload


packer.exe build -var-file $($workdir+"tmp-var.json") $($workdir+$jsonfile)