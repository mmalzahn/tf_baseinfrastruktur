$proPath = $PWD

Set-Location -Path "$proPath\backendInit"
terraform.exe init
terraform.exe apply -auto-approve
Set-Location -Path $proPath
terraform.exe init -backend-config backendInit/cfg/backend.cfg
terraform.exe workspace new prod
terraform.exe workspace new test
terraform.exe workspace new dev
Set-Location -Path "$proPath\packer"
packer.exe build -var-file .\var-bastionhost.json .\bastionhost.json
Set-Location -Path $proPath
