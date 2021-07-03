FROM debian:latest
SHELL ["/bin/bash", "-c"]
RUN apt update \
&& apt upgrade \
&& apt-get install -y apt-utils php apache2 \
&& rm /var/www/html/index.html \
&& chmod 777 -R /var/www/

ADD https://raw.githubusercontent.com/serggarant/puppet_conf/production/files/index.php /var/www/html/index.php
RUN chmod 777 /var/www/html/index.php
ENTRYPOINT ["apache2ctl", "-D", "FOREGROUND"]
