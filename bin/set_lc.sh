# Pick one EVENT or SWIFTIPLY
# To run a Rails app in evented mode (eventmachine gem)
export EVENT=1

# To run in swiftiplied mode (swiftiply gem)
#export SWIFTIPLY=1

# HACK: broken locales
my_hosttype="${HOSTTYPE:='unknown_hosttype'}"
my_kernel="${OSTYPE:='unknown_kernel'}"
my_hosttype=$(uname -a)
my_kernel=$(uname -s)

if [ "${my_kernel}" != 'Darwin' ]; then
 my_kernel="${my_kernel/SunOS/solaris}"
fi

# TODO: re-write my_osver detection to include major-minor-patch
my_ostype="${my_kernel/Darwin*/darwin}"
my_osver="${my_kernel/darwin/}"

if [ "${my_ostype}" != 'darwin' ]; then
  my_ostype="${my_kernel/Linux*/linux}"
  if [ "${my_ostype}" != 'linux' ]; then
    my_ostype="${my_kernel/-gnu/}"
  fi
  my_osver="${my_kernel/linux-/}"
  if [ ${my_ostype} != 'linux' ]; then
    my_ostype="${my_kernel/solaris*/solaris}"
    my_osver="${my_kernel/solaris/}"
  fi
fi

case "${my_ostype}" in
'darwin' )
  LC_CTYPE='en_US.UTF-8'; builtin export LC_CTYPE
  LC_ALL='en_US.UTF-8'; builtin export LC_ALL # Mnt. Lion
  ;;
'linux' )
  LANG='en_US.UTF-8'; builtin export LANG
  LC_ALL='en_US.UTF-8'; builtin export LC_ALL
  ;;
* )
  echo "Unsupported OS: ${my_ostype}"
  ;;
esac

