FROM debian:latest

MAINTAINER @palle version:2

RUN apt-get update

# Installation des paquet perl depuis le dépot DEBIAN, et quelques utilitaires
RUN apt-get -y install \
    apache2 \
    apache2-doc \
    apt-utils \
    php5 \
    php5-gd \
    php5-mysql \
    php5-cgi \
    php5-imap \
    libapache2-mod-php5 \
    php5-ldap \
    php5-curl \
    htop \
    wget \
    tar \
    unzip \
    nano \
    make


#Set time zone Europe/Paris
RUN cp /usr/share/zoneinfo/Europe/Paris /etc/localtime

# Activation des modules
RUN /usr/sbin/a2dissite 000-default
RUN /usr/sbin/a2enmod rewrite
RUN /usr/sbin/a2enmod ssl

# DL OCSserver & Ocsreports
RUN wget https://github.com/glpi-project/glpi/releases/download/9.1/glpi-9.1.tar.gz 

RUN tar -xvzf glpi-9.1.tar.gz -C /var/www/
RUN chown -R www-data /var/www/glpi

# Configure les variable d'environement
ENV APACHE_RUN_USER     www-data
ENV APACHE_RUN_GROUP    www-data
ENV APACHE_LOG_DIR      /var/log/apache2
ENV APACHE_PID_FILE     /var/run/apache2.pid
ENV APACHE_RUN_DIR      /var/run/apache2f
ENV APACHE_LOCK_DIR     /var/lock/apache2
ENV APACHE_LOG_DIR      /var/log/apache2

ADD glpi.conf /etc/apache2/sites-available/

RUN ln -s /etc/apache2/sites-available/glpi.conf /etc/apache2/sites-enabled/glpi.conf

# Exposition des ports
EXPOSE 80
EXPOSE 443
EXPOSE 3306

# Démare Apache2 au lancement du container
ENTRYPOINT [ "/usr/sbin/apache2", "-D", "FOREGROUND" ]
