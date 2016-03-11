function supervisord_wait() {
  local service_name="stackato-supervisord"
  while ! status stackato-supervisord | grep running; do
    message "info" "Waiting for supervisord to start"
    sleep 2
  done
}

function supervisord_check_cli_exists() {
  local cli_name="supervisorctl"
  if ! which $cli_name >/dev/null; then
    message "error" "$cli_name command missing"
  fi
}

function supervisord_start_process() {
  local process="${1:?missing input}"
  if supervisorctl status $process | grep -v RUNNING; then
    supervisorctl start $process
  fi
}
