#!/bin/bash
ssh-keygen -f "/root/.ssh/known_hosts" -R "anclave-777.ru"

ssh-keygen -f "/root/.ssh/known_hosts" -R "db01.anclave-777.ru"

ssh-keygen -f "/root/.ssh/known_hosts" -R "db02.anclave-777.ru"

ssh-keygen -f "/root/.ssh/known_hosts" -R "app.anclave-777.ru"

ssh-keygen -f "/root/.ssh/known_hosts" -R "gitlab.anclave-777.ru"

ssh-keygen -f "/root/.ssh/known_hosts" -R "monitoring.anclave-777.ru"

ssh-keygen -f "/root/.ssh/known_hosts" -R "runner.anclave-777.ru"


ssh-keygen -R 51.250.9.24

