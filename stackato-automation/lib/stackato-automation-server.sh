function stackato_automation_server_start {
  local nginx_version="${1:?missing input}"
  local server_name="${2:?missing input}"
  local server_port="${3:?missing input}"
  local server_root="${4:?missing input}"

  run_as "stackato" "docker run --publish=$server_port:80 --volume=${server_root}:/usr/share/nginx/html:ro --detach=true --name=$server_name nginx:$nginx_version"
}
