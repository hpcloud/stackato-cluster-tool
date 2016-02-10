function mbus_wait_ready() {
  local ip="${1:?missing input}"
  local port="${2:?missing input}"

  while ! nc -z ${ip} ${port}; do
    >&2 echo "Waiting for MBUS on ${ip}:${port}"
    sleep 5
  done
}
