aws_region = "eu-west-1"
aws_accountId = "681337066511"
#
# CIDR-Rage des zu erstellenden VPC
#
vpc_cdir = "10.200.0.0/16"


#
# Startbereich der DMZ Subnetze
#
subnetoffset_dmz = 40


#
# Startbereich der Internen Subnetze
#
subnetoffset_intra = 10


#
# Startbereich der AMZ Service Subnetze
#
subnetoffset_service = 30

#hard_change = "true"

tag_responsibel = "Matthias Malzahn"

aws_key_name = "CSA-DemoVPCKey1"

#aws_key_name = ""
laufzeit_tage = 60

project_name = "DcaBaseInf"

debug_on = true
testhost_deploy = true
az_count = 3

efs_storage = true

api_deploy = false

optimal_design = false

servicenet_deploy = true

pubkeyList = ["matthiasm.pub","testuser1.pub","testuser2.pub"]
#pubkeyList = ["matthiasm.pub"]