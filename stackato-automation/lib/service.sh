function service_mgnt {
  local service="$1"
  local state="$2"

  service $service $state
}

function service_autostart {
  local service="$1"
  update-rc.d $service defaults
}

