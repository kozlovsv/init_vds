#!/bin/bash

# Запуск с параметром -n для геренации нового ключа.
# Если был сгенерирован новый ключ то тогда необходимо для Putty Открыть и пересохранить в формат ppk закрытый ключ при помощи программы PuttyGen

SSH_USER="root"
SSH_HOST="127.0.0.1"
SSH_PORT="22"
SSH_COMMENT="deploy@linosoft.ru"
SSH_KEY_FILE_NAME="deploy_rsa"
GEN_KEY=0

while [ -n "$1" ]
do
    case "$1" in
        -new) GEN_KEY=1;;
        -host) SSH_HOST="$2"
            shift ;;
        -port)
            SSH_PORT="$2"
            shift ;;
        -user)
            SSH_USER ="$2"
            shift ;;
        -comment)
            SSH_COMMENT="$2"
            shift ;;
        -fn)
            SSH_KEY_FILE_NAME="$2"
            shift ;;
    esac
shift
done

if [ $GEN_KEY -eq 1 ]
then
    ssh-keygen -m PEM -b 4096 -t rsa -C $SSH_COMMENT -f ./$SSH_KEY_FILE_NAME -N ""
fi

ssh-copy-id -i $SSH_KEY_FILE_NAME.pub -p $SSH_PORT  $SSH_USER@$SSH_HOST

