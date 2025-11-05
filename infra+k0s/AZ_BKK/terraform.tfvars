# Auth
os_username      = "tanvanat@nipa.cloud"
os_password      = "Homee1234460!"
os_project_name  = "Nipa-SRE-intern"

# Router external network + FIP pool (from your output)
external_network_name_bkk = "Standard_Public_IP_Pool_BKK"
public_ip_pool_name_bkk   = "Standard_Public_IP_Pool_BKK"

# Image / flavor / keypair (must exist)
image_id   = "d00037bf-85f6-4bc3-b271-2ef9f55c36e9"
volume_size = 100
flavor_name  = "coa.large.v2" #3d7f13f6-11df-45a0-a78b-fb20a64c2849
keypair_name = "KeyPair"              # must match `openstack keypair list`

# Optional AZ (leave "" to auto-schedule)
availability_zone_bkk = "NCP-BKK"

# SSH for k0s
ssh_user        = "ubuntu"
private_key_path = "~/.ssh/KeyPair.pem"  # local file that matches keypair_name
