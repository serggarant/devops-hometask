# dockerfile
FROM debian:buster
COPY /jenkins.yaml /tmp/jenkins/jenkins.yaml
COPY ./jenkins/ /jenkins/
RUN apt-get -y update && apt-get install -y ansible rsync\
&& ansible-galaxy install geerlingguy.jenkins geerlingguy.java && ansible-playbook /tmp/jenkins/jenkins.yaml
ENTRYPOINT service jenkins start && bash
