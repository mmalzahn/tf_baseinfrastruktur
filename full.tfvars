aws_region = "eu-west-1"
aws_accountId = "681337066511"
#
# CIDR-Rage des zu erstellenden VPC
#
vpc_cdir = "10.23.0.0/16"


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

mm_debug = 1

az_count = 3

efs_storage = true

api_deploy = true

optimal_design = true

servicenet_deploy = true
pubkeyList = ["matthiasm.pub","testuser1.pub","testuser2.pub"]