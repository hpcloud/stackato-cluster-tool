# Print messages to the user
function message() {
  local msg_type="$1"
  local msg="$2"
  local vars="${@:3}"

  case "$msg_type" in
    "error")  >&2 printf "$msg\n" $vars; exit 1;;
    "info")   >&2 printf "$msg\n" $vars;;
    "stdout") >&1 printf "$msg\n" $vars;;
    *)        >&2 printf "$MSG_INTERNAL_UNKNOWN_MSG_TYPE" "$msg_type\n"; exit 1;;
  esac
}
