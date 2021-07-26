FROM debian:buster
COPY /jenkins.yaml /tmp/jenkins/jenkins.yaml
COPY ./jenkins/ /jenkins/
RUN apt-get -y update && apt-get install -y ansible rsync && ansible-playbook /tmp/jenkins/jenkins.yaml
CMD /usr/bin/daemon -f --name=jenkins --inherit --env=JENKINS_HOME=/var/lib/jenkins --output=/var/log/jenkins/jenkins.log --pidfile=/var/run/jenkins/jenkins.pid -- /usr/bin/java -Djenkins.install.runSetupWizard=false -Dhudson.security.csrf.DefaultCrumbIssuer.EXCLUDE_SESSION_ID=true -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8 -jar /usr/share/jenkins/jenkins.war --webroot=/var/cache/jenkins/war --httpPort=8080
