key_file = "./id_rsa.pub"
manager_instance_type = "Standard_D2S_v3"
dmarc_record = "v=DMARC1; p=none; rua=mailto:postmaster@example.com"
root_txt_record = "v=spf1 include:_spf.google.com ~all"
google_domainkey = "v=DKIM1; k=rsa; p=XXXX"
base_domain = "example.com"