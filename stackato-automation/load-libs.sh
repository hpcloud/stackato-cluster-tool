# Load the libraries
for lib in lib/* ; do
  if [ -f "$lib" ] ; then
    source $lib
  fi
done

for role in roles/* ; do
  if [ -f "$role" ] ; then
    source $role
  fi
done
