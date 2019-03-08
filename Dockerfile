FROM centos:latest

MAINTAINER  wangbo@threathunter.cn
ENV NEBULA_VERSION OpenNebula_v$version

RUN yum install kde-l10n-Chinese -y
RUN yum install glibc-common -y
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8
ENV LC_ALL zh_CN.UTF-8

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY ./nebula_apps/python_lib /home/threathunter/nebula/python_lib
COPY ./nebula_apps/nebula_compute /etc/cron.d/nebula_compute
COPY ./nebula_apps/openresty  /usr/local/openresty
COPY ./nebula_apps/java-web /home/threathunter/nebula/java-web
COPY ./nebula_apps/labrador /home/threathunter/nebula/labrador
COPY ./nebula_apps/nebula_db_writer /home/threathunter/nebula/nebula_db_writer
COPY ./nebula_apps/nebula_fe /home/threathunter/nebula/nebula_fe
COPY ./nebula_apps/nebula_offline_slot /home/threathunter/nebula/nebula_offline_slot
COPY ./nebula_apps/nebula-onlineserver /home/threathunter/nebula/nebula-onlineserver
COPY ./nebula_apps/nebula_query_web /home/threathunter/nebula/nebula_query_web
COPY ./nebula_apps/nebula_web /home/threathunter/nebula/nebula_web
COPY ./nebula_apps/nebula_nginx /home/threathunter/nebula/nebula_nginx
COPY ./3rd/MySQL-shared-compat-5.6.39-1.el7.x86_64.rpm /home/threathunter/nebula/MySQL-shared-compat-5.6.39-1.el7.x86_64.rpm
COPY ./3rd/mysql-community-devel-5.6.39-2.el7.x86_64.rpm /home/threathunter/nebula/mysql-community-devel-5.6.39-2.el7.x86_64.rpm
COPY ./3rd/mysql-community-libs-5.6.39-2.el7.x86_64.rpm /home/threathunter/nebula/mysql-community-libs-5.6.39-2.el7.x86_64.rpm
COPY ./3rd/mysql-community-common-5.6.39-2.el7.x86_64.rpm /home/threathunter/nebula/mysql-community-common-5.6.39-2.el7.x86_64.rpm

RUN rpm -ivh /home/threathunter/nebula/mysql-community-common-5.6.39-2.el7.x86_64.rpm
RUN rpm -ivh /home/threathunter/nebula/mysql-community-libs-5.6.39-2.el7.x86_64.rpm
RUN rpm -ivh /home/threathunter/nebula/MySQL-shared-compat-5.6.39-1.el7.x86_64.rpm
RUN rpm -ivh /home/threathunter/nebula/mysql-community-devel-5.6.39-2.el7.x86_64.rpm

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' > /etc/timezone
RUN yum clean all && yum -y install epel-release
RUN yum -y install net-tools libpcap libpcap-devel java redis supervisor crontabs gcc gcc-c++ make cmake openssl openssl-devel python-pip python-devel
RUN sed -i "s/required/sufficient/g" /etc/pam.d/crond

#安装Python依赖
RUN pip install pip -U --default-timeout=100
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

WORKDIR /home/threathunter/nebula/python_lib
RUN pip install -r requirements.txt
WORKDIR /home/threathunter/nebula/python_lib/babel_python
RUN python setup.py install 
WORKDIR /home/threathunter/nebula/python_lib/nebula_parser
RUN python setup.py install
WORKDIR /home/threathunter/nebula/python_lib/nebula_utils
RUN python setup.py install
WORKDIR /home/threathunter/nebula/python_lib/threathunter_common_python
RUN python setup.py install
WORKDIR /home/threathunter/nebula/python_lib/complexconfig_python
RUN python setup.py install
WORKDIR /home/threathunter/nebula/python_lib/nebula_meta
RUN python setup.py install
WORKDIR /home/threathunter/nebula/python_lib/nebula_strategy
RUN python setup.py install
WORKDIR /home/threathunter/nebula/python_lib/tornado_profile_gen
RUN python setup.py install

WORKDIR /home/threathunter/nebula/nebula_web
RUN pip install -r requirements.txt
WORKDIR /home/threathunter/nebula/nebula_db_writer
RUN pip install -r requirements.txt
WORKDIR /home/threathunter/nebula/nebula_query_web
RUN pip install -r requirements.txt

WORKDIR /
EXPOSE 9001
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/nebula/supervisor.conf"]
