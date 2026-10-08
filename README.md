# Лаб. П01 — Базовое администрирование Linux

Подготовка виртуальной машины Ubuntu 24.04, диагностика, сеть, установка пакетов,
создание пользователя (домашний каталог, вход по SSH-ключу, `sudo` без пароля).

## Стенд

VM Ubuntu Server 24.04 в **VMware Workstation** (2 vCPU, 4 ГБ RAM, 30 ГБ диск), NAT-сеть
`192.168.227.0/24`, адрес VM `192.168.227.15`. Хост подключается к VM напрямую по
этому IP, поэтому проброс порта 22 (как в VirtualBox из лекции) не требуется.

## Содержимое

| Файл | Назначение |
|---|---|
| `create_user.sh` | создаёт пользователя: домашний каталог, SSH-ключ, `sudo NOPASSWD` |
| `screenshots/` | подтверждение работы |

## Выполненные шаги

| # | Шаг из задания | Как выполнено |
|---|---|---|
| 1–3 | VM и Ubuntu 24.04 | VMware, готовый cloud-образ Ubuntu 24.04 (вместо установки с ISO), настройка при первом запуске через cloud-init |
| 4 | SSH-сервер | `openssh-server` входит в образ, `systemctl is-active ssh` → `active` |
| 5 | Диагностика | `uname`, `lsb_release`, `top`, `ls`, `lsblk`, `df`, `chown/chmod` (права на `.ssh`) — скриншот 1 |
| 6 | Сеть | `ip addr`, `ip route`, `ping`, `traceroute` — скриншот 2 |
| 7 | Пакеты | `python3` 3.12.3 и `git` 2.43.0 установлены |
| 8 | Новый пользователь: домашний каталог, SSH, sudo без пароля | `create_user.sh` — скриншоты 3 и 4 |
| 9–10 | Вход по ключу | ключ `ed25519` на хосте, публичная часть в `~/.ssh/authorized_keys`, вход `ssh -i <ключ>` — скриншот 3 |

## Создание пользователя

```bash
ssh-keygen -t ed25519 -f ~/.ssh/lab01_key          # на хосте
scp create_user.sh runner@192.168.227.15:
ssh runner@192.168.227.15 "sudo ./create_user.sh student '$(cat ~/.ssh/lab01_key.pub)'"
ssh -i ~/.ssh/lab01_key student@192.168.227.15 "id; sudo -n whoami"
```

Скрипт: `useradd -m -s /bin/bash`, группа `sudo`, каталог `.ssh` (700), `authorized_keys` (600),
правило `/etc/sudoers.d/<имя>` (`NOPASSWD:ALL`, права 440, проверка `visudo -cf`). Правило лежит
в `sudoers.d`, а не правит основной `/etc/sudoers`. Пароль пользователю не задаётся
(`passwd -S` → `L`), вход возможен только по ключу.

## Что отличается от лекции / не выполнено

- Для остальных лабораторных на VM используется пользователь `runner` (домашний каталог, вход по ключу,
  `sudo` без пароля). Шаги 8–10 продемонстрированы на отдельном пользователе `student`,
  созданном скриптом `create_user.sh`.
- Шаг 11 (VS Code с плагином Remote-SSH) **не выполнялся**: это настройка графического клиента.
  Для него достаточно записи в `~/.ssh/config` (`Host vm1`, `HostName 192.168.227.15`, `User runner`).
- Приватный ключ в репозиторий не добавлялся.

## Скриншоты

1. `screenshots/01-system-diagnostics.png` — `uname`, `lsb_release`, `lsblk`, `df`, `top`, SSH, `python3`/`git`.
2. `screenshots/02-network.png` — `ip addr`, `ip route`, `ping`, `traceroute`.
3. `screenshots/03-user-ssh-key-sudo.png` — создание пользователя, вход по ключу, `sudo` без пароля.
4. `screenshots/04-user-files.png` — `sudoers.d`, права `.ssh`, запись в `passwd`.
