function run_as {
  local user="$1"
  local cmd="${@:2}"

  su - $user -c "$cmd"
}
