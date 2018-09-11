# Dokumentation :memo:
---

## Requirement 
- S3 Bucket für den Remote State
- AWS Account mit den entsprechenden Rechten
- API-Key für diesen Account
- Terraform von www.terraform.io
- OpenSSH for Windows
- oder [PuTTY](https://www.putty.org)

## Einschränkungen
- AWS-Region muss EFS anbieten, wenn gewünscht
- der Name der Publickey Datei in dem S3 Bucket MUSS komplett aus Kleinbuchstaben und Zahlen bestehen

## Statefile
Das Statefile wird in einem S3 Bucket auf AWS abgelegt um einen gemeinsamen Zugriff zu ermöglichen

## Provider Definition
```
provider "aws" {
  alias                              = "usa"
  region                           = "us-east-1"
  shared_credentials_file  = "C:/Users/<profilepath>/.aws/credentials"
  profile                            = "tfinfrauser"
}
```
## Tools 

## mögliche Erweiterungen
- API für das Management von Project IDs
- Katalog an 

## Links :link:
 *[Terraform Doku](https://www.terraform.io/docs/)
