#
# Check input params
#
if [ -n "${1}" -a -z "${2}" ]; then
    USERNAME='developer'
    PASSWORD="${1}"
elif [ -n "${1}" -a -n "${2}" ]; then
    USERNAME="${1}"
    PASSWORD="${2}"
else
    echo "Usage:"
    echo "  Setup password to user developer: ${0} 'password'"
    echo "  Setup user and password: ${0} 'user_name' 'password'"
    exit 1
fi

PASS=$(perl -e 'print crypt($ARGV[0], "abracadabra")' $PASSWORD)
useradd -m -p "$PASS" "$USERNAME"
usermod -aG sudo $USERNAME
