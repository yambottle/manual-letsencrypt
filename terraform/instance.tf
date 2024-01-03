module "auto-letsencrypt-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name                        = "auto-letsencrypt"
  ami                         = "ami-0960ab670c8bb45f3" # 20.04 
  instance_type               = "t3a.micro"
  key_name                    = "dj-ops-key"
  monitoring                  = false
  vpc_security_group_ids      = var.instance_vpc_security_group_ids
  subnet_id                   = var.instance_subnet_id
  associate_public_ip_address = true

  enable_volume_tags = false
  root_block_device = [{
    encrypted             = true
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = 8
    tags = merge(local.tags, {
      Name = "auto-letsencrypt.root"
    })
  }]

  user_data = templatefile("./userdata.yaml",
    merge({
      CERT_CONTACT_EMAIL      = var.cert_contact_email,
      CERT_STAGING            = var.cert_staging,
      ROUTE53_ZONE_NAME       = var.route53_zone_name,
      ROUTE53_RECORD_NAME     = var.route53_record_name,
      MANUAL_LETSENCRYPT_REPO = var.manual_letsencrypt_repo
    })
  )

  tags = local.tags
}
