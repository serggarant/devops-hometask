FROM debian:buster
COPY /nexus.yaml /tmp/nexus.yaml
RUN apt-get -y update && apt-get install -y ansible rsync \
&& ansible-galaxy install ansible-thoteam.nexus3-oss geerlingguy.java && ansible-playbook /tmp/nexus.yaml
CMD /etc/init.d/nexus run
