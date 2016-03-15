function wait_node_ready() {
  local service_name="stackato"
  local service_expected_status="start/running"
  local sleep_time="4"

  local node_status="$(status $service_name)"
  while [ "$node_status" != "$service_name $service_expected_status" ]; do
    >&2 echo "Waiting for node to be ready (current status $node_status, expecting $service_expected_status)"
    sleep $sleep_time
    node_status="$(status $service_name)"
  done
}
