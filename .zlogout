# https://superuser.com/questions/141036/use-of-gnome-keyring-daemon-without-x

# Kill the message bus established for SVN / Keyring communication
if [ ! -z "`kill -0 $DBUS_SESSION_BUS_PID 2>&1`" ]
then
    kill $DBUS_SESSION_BUS_PID > /dev/null 2>&1
fi

# Kill the Gnome Keyring Daemon prior to logout.
if [ ! -z "`kill -0 $GNOME_KEYRING_PID 2>&1`" ]
then
    kill $GNOME_KEYRING_PID > /dev/null 2>&1
fi
