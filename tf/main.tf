resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = "westus2"
}

data "azuread_client_config" "current" {}
data "azurerm_subscription" "current" {}

resource "random_uuid" "gitlab_scope_id" {}

resource "azuread_application" "gitlab" {
  display_name     = "git.${var.base_domain}"
  identifier_uris  = ["api://git.${var.base_domain}"]
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"

  api {
    oauth2_permission_scope {
      admin_consent_description  = "Access gitlab as a user"
      admin_consent_display_name = "Access gitlab as a user"
      enabled                    = true
      id                         = random_uuid.gitlab_scope_id.result
      type                       = "User"
      user_consent_description   = "Access gitlab as a user"
      user_consent_display_name  = "Access gitlab as a user"
      value                      = "access_as_user"
    }
  }


  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }

    resource_access {
      id   = "37f7f235-527c-4136-accd-4a02d197296e"
      type = "Scope"
    }

    resource_access {
      id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0"
      type = "Scope"
    }

    resource_access {
      id   = "14dad69e-099b-42c9-810b-d002981feec1"
      type = "Scope"
    }

  }

  web {
    homepage_url  = "https://git.${var.base_domain}"
    #logout_url    = "https://app.example.net/logout"
    redirect_uris = ["https://git.${var.base_domain}/users/auth/azure_activedirectory_v2/callback"]

    implicit_grant {
      access_token_issuance_enabled = false
    }
  }
}

resource "azuread_application_password" "gitlab_application_secret" {
  application_object_id = azuread_application.gitlab.object_id
}


resource "random_uuid" "dns_txt_role_id" {}
resource "azurerm_role_definition" "dns_txt_contributor" {
  role_definition_id = random_uuid.dns_txt_role_id.result
  name        = "DNS TXT Contributor"
  scope       = data.azurerm_subscription.current.id
  description = "Can manage DNS TXT records only."

  permissions {
    actions     = ["Microsoft.Network/dnsZones/TXT/*",
                   "Microsoft.Network/dnsZones/read",
                   "Microsoft.Authorization/*/read",
                   "Microsoft.Insights/alertRules/*",
                   "Microsoft.ResourceHealth/availabilityStatuses/read",
                   "Microsoft.Resources/deployments/read",
                   "Microsoft.Resources/subscriptions/resourceGroups/read"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id, # /subscriptions/00000000-0000-0000-0000-000000000000
  ]
}

resource "azuread_application" "lets_encrypt" {
  display_name = "Lets Encrypt DNS Validator"
  sign_in_audience = "AzureADMyOrg"
}

resource "azuread_service_principal" "le_service_principal" {
  application_id = azuread_application.lets_encrypt.application_id
}

resource "azuread_service_principal_password" "le_service_principal_password" {
  service_principal_id = azuread_service_principal.le_service_principal.object_id
}

resource "azurerm_role_assignment" "le_contributor_assignment" {
  scope              = data.azurerm_subscription.current.id
  role_definition_id = azurerm_role_definition.dns_txt_contributor.role_definition_resource_id
  principal_id       = azuread_service_principal.le_service_principal.object_id
}

#gitlab app
#redirect https://gitlab.example.com/users/auth/azure_activedirectory_v2/callback
