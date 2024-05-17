output "api-gw-invoke_url" {
  value = "${module.api-gw.api-gw-endpoint}${module.api-gw.stage_name}"
}