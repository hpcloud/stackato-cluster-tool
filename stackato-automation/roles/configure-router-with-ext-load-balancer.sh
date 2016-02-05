#!/usr/bin/env bash
: ${TERMINATE_SSL:=false}
: ${KATO_BIN:=kato}

if [ "$TERMINATE_SSL" == "true" ]; then
  $KATO_BIN config set router2g prevent_x_spoofing false
elif [ "$TERMINATE_SSL" == "false" ]; then
  $KATO_BIN config set router2g prevent_x_spoofing true
else
  >&2 echo "Error with the TERMINATE_SSL option (wrong value: $TERMINATE_SSL)"
fi
