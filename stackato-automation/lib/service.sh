function service_mgnt {
  local service="$1"
  local state="$2"

  service $service $state
}
