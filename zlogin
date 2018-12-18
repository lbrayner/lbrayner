# https://superuser.com/questions/141036/use-of-gnome-keyring-daemon-without-x

if [ -e /usr/bin/gnome-keyring-daemon ]
then
    if [ -n "`kill -0 $GNOME_KEYRING_PID 2>&1`" ]
    then
        # Create dbus transport link for SVN to talk to the keyring.
        eval `dbus-launch --sh-syntax`

        # Start the keyring daemon.
        # The use of export here captures the GNOME_KEYRING_PID, GNOME_KEYRING_SOCK
        # env values echoed out at startup.
        # variables actually output: GNOME_KEYRING_CONTROL, SSH_AUTH_SOCK
        export `/usr/bin/gnome-keyring-daemon`
    fi
fi
