function update_redis_timeout() {
  local timeout="${1:?missing input}"
  local redis_config="${2:?missing input}"

  sed -i "s/timeout [0-9]+/timeout $timeout/" $redis_config
}
