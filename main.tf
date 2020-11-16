#Terraform `provider` section is required since the `azurerm` provider update to 2.0+
provider "azurerm" {
  features {}
}

# This next block solves a few problems, and we'll explain the syntax as a result.
# The contrast_security.yaml file now referenced from the user's home directory, in "~/.contrast/demo"
# The pathexpand function resolves "~/" so yours is different from mine, and this helps with terraform knowing its workspace
# the yamldecode block focuses on the ["api"] section only, since we're pulling values from there
locals {
  raw_yaml = "${yamldecode(file(pathexpand("contrast_security.yaml")))["api"]}"

  api_key     = tostring(local.raw_yaml.api_key)
  service_key = tostring(try(local.raw_yaml.service_key, null))
  url         = tostring(try(local.raw_yaml.url, null))
  user_name   = tostring(try(local.raw_yaml.user_name, null))
}

#Set up a personal resource group for the SE local to them
resource "azurerm_resource_group" "personal" {
  name     = "student-${var.initials}"
  location = var.location
}

#Set up a container group 
resource "azurerm_container_group" "app" {
  name                = "${var.appname}-${var.initials}"
  location            = azurerm_resource_group.personal.location
  resource_group_name = azurerm_resource_group.personal.name
  ip_address_type     = "public"
  dns_name_label      = "${replace(var.appname, "/[^-0-9a-zA-Z]/", "-")}-${var.initials}"
  os_type             = "linux"

  container {
    name   = "web"
    image  = "contrastsecuritydemo/spring-petclinic:1.5.1"
    cpu    = "1"
    memory = "1.5"
    ports {
      port     = 8080
      protocol = "TCP"
    }
    environment_variables = {
      JAVA_TOOL_OPTIONS = "-javaagent:target/contrast.jar -Dcontrast.agent.java.standalone_app_name=spring-petclinic -Dcontrast.api.url=${local.url} -Dcontrast.api.api_key=${local.api_key} -Dcontrast.api.service_key=${data.external.yaml.result.service_key} -Dcontrast.api.user_name=${data.external.yaml.result.user_name} -Dcontrast.standalone.appname=${var.appname} -Dcontrast.server.name=${var.servername} -Dcontrast.server.environment=${var.environment} -Dcontrast.application.session_metadata=${var.session_metadata} -Dcontrast.application.tags=${var.apptags} -Dcontrast.server.tags=${var.servertags}"
    }
  }
}

