Инструкции по инициализации нового сервера VDS на основе Centos 7
1.Инициализировать ключи SSH.
    Либо запускаем новый init_ssh_key.sh -new -host <new_host>
    Либо инициализируем уже имеющийся init_ssh_key.sh -host <new_host>
2.Устанавливаем окружение докер:
    Копируем на сервер скрипт install_docker.sh
    Ставим ему разрешение на запускаем
    Запускаем.
    Статьи: https://netpoint-dc.com/blog/ustanovka-docker-ce-v-centos-7/
            https://docs.docker.com/install/linux/docker-ce/centos/

3. Периодически чистить систему
   docker system prune -a -f
   
   
Инструкции по инициализации нового сервера VDS на основе Debian 10
1.Инициализировать ключи SSH.
    Либо запускаем новый init_ssh_key.sh -new -host <new_host>
    Либо инициализируем уже имеющийся init_ssh_key.sh -host <new_host>
2.Устанавливаем окружение докер и вспомогательные утилиты:
    Копируем на сервер скрипт install_docker_debian.sh
    Ставим ему разрешение на запуск и запускаем.
    Статьи: https://docs.docker.com/engine/install/debian/
3. При необходимости устанавливаем MariaDB.
    Открываем для редактирования файл install_mariadb_debian.sh. Меняем версию MariaDB на последнюю. --mariadb-server-version="mariadb-10.5"
    Открываем файл init_db.sql меняем название базы для создания, а так же название пользователя базы.
    Копируем на сервер файлы  install_mariadb_debian.sh и init_db.sql
    Ставим ему разрешение на запуск и запускаем.
    Ставим ему разрешение на запуск и запускаем install_mariadb_debian.sh 'your_new_root_password'.
4. При необходимости устанавливаем Redis кэш

5. Переписываем файл корон если необходимости. Обязательно в файле крон проставляем права 600. И смотрим по логу чтобы он подцепился к крону.
6. Переписываем в /etc/logrotate.d файл ротации логов файлы из папки logrotate