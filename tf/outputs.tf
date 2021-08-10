
output "subscription_id" {
  value = data.azurerm_subscription.current.id
}

output "tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}

output "resource_group" {
  value = azurerm_resource_group.main.name
}


output "le_sp_client_id" {
  value = azuread_application.lets_encrypt.application_id
}

output "le_sp_client_secret" {
  value = azuread_service_principal_password.le_service_principal_password.value
  sensitive = true
}


output "gitlab_omniauth_app_id" {
  value = azuread_application.gitlab.application_id
}

output "gitlab_omniauth_app_secret" {
  value = azuread_application_password.gitlab_application_secret.value
  sensitive = true
}