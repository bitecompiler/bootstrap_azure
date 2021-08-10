resource "azurerm_dns_zone" "main" {
  name                = var.base_domain
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_dns_mx_record" "mx" {
  name                = "@"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300

  record {
    preference = 1
    exchange   = "ASPMX.L.GOOGLE.COM"
  }

  record {
    preference = 5
    exchange   = "ALT1.ASPMX.L.GOOGLE.COM"
  }

  record {
    preference = 5
    exchange   = "ALT2.ASPMX.L.GOOGLE.COM"
  }

  record {
    preference = 10
    exchange   = "ASPMX2.L.GOOGLE.COM"
  }

  record {
    preference = 10
    exchange   = "ASPMX3.L.GOOGLE.COM"
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_dns_txt_record" "spf" {
  name                = "@"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300

  record {
    value = var.root_txt_record
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_dns_txt_record" "_dmarc" {
  name                = "_dmarc"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300

  record {
    value = var.dmarc_record
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_dns_txt_record" "google_domainkey" {
  name                = "google._domainkey"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300

  record {
    value = var.google_domainkey
  }

  tags = {
    Environment = "Production"
  }
}

