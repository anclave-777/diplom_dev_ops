# Дипломный практикум в YandexCloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
      * [Регистрация доменного имени](#регистрация-доменного-имени) +
      * [Создание инфраструктуры](#создание-инфраструктуры)
          * [Установка Nginx и LetsEncrypt](#установка-nginx)
          * [Установка кластера MySQL](#установка-mysql)
          * [Установка WordPress](#установка-wordpress)
          * [Установка Gitlab CE, Gitlab Runner и настройка CI/CD](#установка-gitlab)
          * [Установка Prometheus, Alert Manager, Node Exporter и Grafana](#установка-prometheus)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

---
## Цели:

1. Зарегистрировать доменное имя (любое на ваш выбор в любой доменной зоне). +
2. Подготовить инфраструктуру с помощью Terraform на базе облачного провайдера YandexCloud. +
3. Настроить внешний Reverse Proxy на основе Nginx и LetsEncrypt. +
4. Настроить кластер MySQL. +
5. Установить WordPress. +
6. Развернуть Gitlab CE и Gitlab Runner. +
7. Настроить CI/CD для автоматического развёртывания приложения. +
8. Настроить мониторинг инфраструктуры с помощью стека: Prometheus, Alert Manager и Grafana.

---
## Этапы выполнения:

### Регистрация доменного имени

Подойдет любое доменное имя на ваш выбор в любой доменной зоне.

ПРИМЕЧАНИЕ: Далее в качестве примера используется домен `you.domain` замените его вашим доменом.

Рекомендуемые регистраторы:
  - [nic.ru](https://nic.ru)
  - [reg.ru](https://reg.ru)

Цель:

1. Получить возможность выписывать [TLS сертификаты](https://letsencrypt.org) для веб-сервера.

Ожидаемые результаты:

1. У вас есть доступ к личному кабинету на сайте регистратора. +


**Зарегестрировал доменное имя на reg.ru**

![image](https://user-images.githubusercontent.com/44027303/173893004-0a1d13b1-f202-4ef5-b5cd-2651a9df8377.png)

3. Вы зарезистрировали домен и можете им управлять (редактировать dns записи в рамках этого домена). +

### Создание инфраструктуры

Для начала необходимо подготовить инфраструктуру в YC при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
- Следует использовать последнюю стабильную версию [Terraform](https://www.terraform.io/).

Предварительная подготовка:

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя +
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:
3. 
   а. Рекомендуемый вариант: [Terraform Cloud](https://app.terraform.io/)  +
   
   б. Альтернативный вариант: S3 bucket в созданном YC аккаунте.
3. Настройте [workspaces](https://www.terraform.io/docs/language/state/workspaces.html)
   а. Рекомендуемый вариант: создайте два workspace: *stage* и *prod*. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.  +
   
   б. Альтернативный вариант: используйте один workspace, назвав его *stage*. Пожалуйста, не используйте workspace, создаваемый Terraform-ом по-умолчанию (*default*).
   
4. Создайте VPC с подсетями в разных зонах доступности. +



**Создал несколько сетей**

![image](https://user-images.githubusercontent.com/44027303/175792356-0aa98079-a62d-44c0-80da-f6165ef0a4b6.png)


6. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.



**terraform apply**
![image](https://user-images.githubusercontent.com/44027303/175792371-fc60d086-1735-4364-87e2-290d0e903dca.png)



**terraform destroy**
![image](https://user-images.githubusercontent.com/44027303/175792363-0e466ce5-dc61-48b6-bd51-b3552435a5e1.png)


8. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.


**web-интерфейс Terraform cloud.**
![image](https://user-images.githubusercontent.com/44027303/176266932-5a1fa9d1-ebbe-4123-84e5-8f1e38d3d3db.png)



Цель:

1. Повсеместно применять IaaC подход при организации (эксплуатации) инфраструктуры.
2. Иметь возможность быстро создавать (а также удалять) виртуальные машины и сети. С целью экономии денег на вашем аккаунте в YandexCloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

**Результат: Мной зарегестрировано доменное имя и написаны манифесты терраформа для создания инфраструктуры. Создание всей инфраструктуры занимает 2-3 минуты. Для создания инфраструктуры использую Terraform Cloud**


---
### Установка Nginx и LetsEncrypt

Необходимо разработать Ansible роль для установки Nginx и LetsEncrypt.

**Для получения LetsEncrypt сертификатов во время тестов своего кода пользуйтесь [тестовыми сертификатами](https://letsencrypt.org/docs/staging-environment/), так как количество запросов к боевым серверам LetsEncrypt [лимитировано](https://letsencrypt.org/docs/rate-limits/).**

Рекомендации:
  - Имя сервера: `you.domain`
  - Характеристики: 2vCPU, 2 RAM, External address (Public) и Internal address.
  


## Комментарий
- https://cloud.yandex.com/en/docs/vpc/operations/set-static-ip - для постоянной публичной статики
Сделал статику -51.250.9.24


Цель:

1. Создать reverse proxy с поддержкой TLS для обеспечения безопасного доступа к веб-сервисам по HTTPS. +

**NGINX установился**
![image](https://user-images.githubusercontent.com/44027303/177428230-7cc5b0c9-5ecb-415d-9574-00c729bd8811.png)


Ожидаемые результаты:

1. В вашей доменной зоне настроены все A-записи на внешний адрес этого сервера:
    - `https://www.you.domain` (WordPress) +
    - `https://gitlab.you.domain` (Gitlab) +
    - `https://grafana.you.domain` (Grafana) +
    - `https://prometheus.you.domain` (Prometheus) +
    - `https://alertmanager.you.domain` (Alert Manager) +

2. Настроены все upstream для выше указанных URL, куда они сейчас ведут на этом шаге не важно, позже вы их отредактируете и укажите верные значения.
2. В браузере можно открыть любой из этих URL и увидеть ответ сервера (502 Bad Gateway). На текущем этапе выполнение задания это нормально!


**Ошибка 502**
![image](https://user-images.githubusercontent.com/44027303/178355839-f3fe0b13-bd2d-4263-b3fe-25609ed342a9.png)


**Результат: Написана ансибл роль для nginx letsencrypt proxy. Выполняется командой ansible-playbook  --private-key=/home/vagrant/cloud-terraform/id_rsa  -i hosts front.yml. В процессе нескольких редеплоев забыл внести ключ  --test-cert, поэтому в дальнейшем на скриншотах периодически встречаются неодобренные сертификаты**


___
### Установка кластера MySQL

Необходимо разработать Ansible роль для установки кластера MySQL.

Рекомендации:
  - Имена серверов: `db01.you.domain` и `db02.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:

1. Получить отказоустойчивый кластер баз данных MySQL. +

Ожидаемые результаты:

1. MySQL работает в режиме репликации Master/Slave.
2. В кластере автоматически создаётся база данных c именем `wordpress`.
3. В кластере автоматически создаётся пользователь `wordpress` с полными правами на базу `wordpress` и паролем `wordpress`.

**Вы должны понимать, что в рамках обучения это допустимые значения, но в боевой среде использование подобных значений не приемлимо! Считается хорошей практикой использовать логины и пароли повышенного уровня сложности. В которых будут содержаться буквы верхнего и нижнего регистров, цифры, а также специальные символы!**


**Успешный деплой mysql**
![image](https://user-images.githubusercontent.com/44027303/177631624-6ebd79d3-659f-462f-b736-7c96ab691ee5.png)


**Проверка мастер-слейва mqsql**
![image](https://user-images.githubusercontent.com/44027303/177822403-4e34b3f6-47d5-4640-a8f3-936a031994bc.png)


**Результат: Выполнено. Подключение Ансибо  реализовал через джамп хост при прыжке через ssh в инвентори файле. Команда для выполнения: ansible-playbook  --private-key=/home/vagrant/cloud-terraform/id_rsa  -i hosts MySQL.yml**

___
### Установка WordPress

Необходимо разработать Ansible роль для установки WordPress.

Рекомендации:
  - Имя сервера: `app.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:

1. Установить [WordPress](https://wordpress.org/download/). Это система управления содержимым сайта ([CMS](https://ru.wikipedia.org/wiki/Система_управления_содержимым)) с открытым исходным кодом.


По данным W3techs, WordPress используют 64,7% всех веб-сайтов, которые сделаны на CMS. Это 41,1% всех существующих в мире сайтов. Эту платформу для своих блогов используют The New York Times и Forbes. Такую популярность WordPress получил за удобство интерфейса и большие возможности.

Ожидаемые результаты:

1. Виртуальная машина на которой установлен WordPress и Nginx/Apache (на ваше усмотрение). +
2. В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy:
    - `https://www.you.domain` (WordPress)
3. На сервере `you.domain` отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину на которой установлен WordPress.
4. В браузере можно открыть URL `https://www.you.domain` и увидеть главную страницу WordPress.

**Успешный деплой wordpress**
![image](https://user-images.githubusercontent.com/44027303/177813204-ebfdcea0-c1b1-4f59-9503-7a712efcea16.png)


**Заглавная страница wordpress**
![image](https://user-images.githubusercontent.com/44027303/177786575-995cc77d-3133-460d-b208-63b1c2e0a91a.png)



**Результат: Выполнено. Подключение Ансибла к хосту реализовал через джамп хост при прыжке через ssh в инвентори файле**



```
[MySQL:vars]
ansible_ssh_common_args = '-o  ProxyCommand="ssh -W %h:%p -q -i /home/vagrant/cloud-terraform/id_rsa anclave-777@anclave-777.ru"'
```



**Команда для выполнения: ansible-playbook  --private-key=/home/vagrant/cloud-terraform/id_rsa  -i hosts wordpress.yml**

---
### Установка Gitlab CE и Gitlab Runner

## Комментарий

**Несколько дней неудавалось поставить гитлаб из ансибл роли из-за ошибки:**
![erro_gitlab](https://user-images.githubusercontent.com/44027303/178323354-7534efd3-561c-4726-97a8-4314be3e61be.png)

**Проблема была в нехватке места на прокси сервере(добавил диск побольше), после в зависании таски с рекнфигурацией gitlab. Собрал свой образ packerом:**

***Успешная сборка*
![image](https://user-images.githubusercontent.com/44027303/178323105-65523ca5-6e75-4b83-94d1-a7dc4d63bff3.png)

**Код образа приложу к решению. Пароль сбрасывается на сервере командой `sudo gitlab-rake "gitlab:password:reset[root]"`**



Необходимо настроить CI/CD систему для автоматического развертывания приложения при изменении кода.

Рекомендации:
  - Имена серверов: `gitlab.you.domain` и `runner.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:
1. Построить pipeline доставки кода в среду эксплуатации, то есть настроить автоматический деплой на сервер `app.you.domain` при коммите в репозиторий с WordPress.

Подробнее об [Gitlab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/)

Ожидаемый результат:

1. Интерфейс Gitlab доступен по https.
2. В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy:
    - `https://gitlab.you.domain` (Gitlab)
3. На сервере `you.domain` отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину на которой установлен Gitlab.
3. При любом коммите в репозиторий с WordPress и создании тега (например, v1.0.0) происходит деплой на виртуальную машину.



**успешно запущенный сервер**
![image](https://user-images.githubusercontent.com/44027303/178355434-ab8c1b18-97f4-4a72-96ed-44c412b35eb9.png)


**Зарегестрированный раннер**
![image](https://user-images.githubusercontent.com/44027303/178934106-4387b7ce-21b3-4678-94a2-0297033e5395.png)

**При любом коммите в репозиторий с WordPress происходит деплой на виртуальную машину.**
![image](https://user-images.githubusercontent.com/44027303/179519355-a04aa55e-821b-47bc-8c93-9d63d182c7c6.png)

![image](https://user-images.githubusercontent.com/44027303/179521547-17a9184f-0c8e-4a27-91c5-a60f62632910.png)



**Результат. Выполнено, роль раннера отыгрывается командами:**
**ansible-playbook  --private-key=/home/vagrant/cloud-terraform/id_rsa  -i hosts gitlab.yml**
**ansible-playbook  --private-key=/home/vagrant/cloud-terraform/id_rsa  -i hosts gitlab_runner.yml**

**Выполнение джобов на gitlab в сторону wordpress успешно**
___
### Установка Prometheus, Alert Manager, Node Exporter и Grafana

Необходимо разработать Ansible роль для установки Prometheus, Alert Manager и Grafana.

Рекомендации:
  - Имя сервера: `monitoring.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:

1. Получение метрик со всей инфраструктуры.


**Успешный деплой**
![image](https://user-images.githubusercontent.com/44027303/178446871-52c321f4-e36f-4e5d-9d0b-5cad47a7ac83.png)

**Прометей**
![image](https://user-images.githubusercontent.com/44027303/178942387-4439992d-defd-471e-b228-50e8ec99f4ec.png)

![image](https://user-images.githubusercontent.com/44027303/179457963-decf02d1-5fc3-4a32-b17f-557011883b1d.png)


**Графана**
![image](https://user-images.githubusercontent.com/44027303/178942485-9f313e64-379e-48d7-9cbf-c86f1f169956.png)

**Графана с импортированными метриками прометея**

![image](https://user-images.githubusercontent.com/44027303/179463095-cecc56eb-f6b6-43d5-9209-7b2c990b5806.png)


**Алерт менеджер c отключенным сервером Mysql**

![image](https://user-images.githubusercontent.com/44027303/179473661-edabd20b-6ed1-4657-8b17-d8b37c79e84e.png)




Ожидаемые результаты:

1. Интерфейсы Prometheus, Alert Manager и Grafana доступены по https.
2. В вашей доменной зоне настроены A-записи на внешний адрес reverse proxy:
  - `https://grafana.you.domain` (Grafana) +
  - `https://prometheus.you.domain` (Prometheus) +
  - `https://alertmanager.you.domain` (Alert Manager) +
3. На сервере `you.domain` отредактированы upstreams для выше указанных URL и они смотрят на виртуальную машину на которой установлены Prometheus, Alert Manager и Grafana.
4. На всех серверах установлен Node Exporter и его метрики доступны Prometheus.
5. У Alert Manager есть необходимый [набор правил](https://awesome-prometheus-alerts.grep.to/rules.html) для создания алертов.
2. В Grafana есть дашборд отображающий метрики из Node Exporter по всем серверам.
3. В Grafana есть дашборд отображающий метрики из MySQL (*).
4. В Grafana есть дашборд отображающий метрики из WordPress (*).

*Примечание: дашборды со звёздочкой являются опциональными заданиями повышенной сложности их выполнение желательно, но не обязательно.*

**Результат.**
**Все указанные в задаче сервисы устанавливаются командой ansible-playbook  --private-key=/home/vagrant/cloud-terraform/id_rsa  -i hosts monitoring.yml**
**Данные из прометея успешно импортирются в grafana и alertmanager осуществляет  мониторинг хостов **
---
## Что необходимо для сдачи задания?

1. Репозиторий со всеми Terraform манифестами и готовность продемонстрировать создание всех ресурсов с нуля.
2. Репозиторий со всеми Ansible ролями и готовность продемонстрировать установку всех сервисов с нуля.
3. Скриншоты веб-интерфейсов всех сервисов работающих по HTTPS на вашем доменном имени.
  - `https://www.you.domain` (WordPress)
  - `https://gitlab.you.domain` (Gitlab)
  - `https://grafana.you.domain` (Grafana)
  - `https://prometheus.you.domain` (Prometheus)
  - `https://alertmanager.you.domain` (Alert Manager)

  
4. Все репозитории рекомендуется хранить на одном из ресурсов ([github.com](https://github.com) или [gitlab.com](https://gitlab.com)).

---
## Как правильно задавать вопросы дипломному руководителю?

**Что поможет решить большинство частых проблем:**

1. Попробовать найти ответ сначала самостоятельно в интернете или в
  материалах курса и ДЗ и только после этого спрашивать у дипломного
  руководителя. Навык поиска ответов пригодится вам в профессиональной
  деятельности.
2. Если вопросов больше одного, то присылайте их в виде нумерованного
  списка. Так дипломному руководителю будет проще отвечать на каждый из
  них.
3. При необходимости прикрепите к вопросу скриншоты и стрелочкой
  покажите, где не получается.

**Что может стать источником проблем:**

1. Вопросы вида «Ничего не работает. Не запускается. Всё сломалось». Дипломный руководитель не сможет ответить на такой вопрос без дополнительных уточнений. Цените своё время и время других.
2. Откладывание выполнения курсового проекта на последний момент.
3. Ожидание моментального ответа на свой вопрос. Дипломные руководители работающие разработчики, которые занимаются, кроме преподавания, своими проектами. Их время ограничено, поэтому постарайтесь задавать правильные вопросы, чтобы получать быстрые ответы :)
