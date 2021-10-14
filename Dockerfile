FROM adhoc/odoo-adhoc:13.0-enterprise
user root
# RUN dpkg -l | grep nss-myhostname
# RUN apt-get remove --purge libnss-myhostname
RUN apt-get update && apt-get install apt-utils -y
RUN apt-get install dnsutils iputils-ping net-tools iproute2 -y
RUN apt-get install libnss-myhostname
# RUN ifconfig lo down
# RUN ip addr add 172.20.0.1 dev lo
# RUN ifconfig lo 172.20.0.1 netmask 255.255.255.0
user odoo 
