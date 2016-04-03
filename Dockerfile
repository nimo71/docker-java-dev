FROM ubuntu:14.04
ARG GITHUB_PAT
MAINTAINER Nick Monk <nick@monk.software>
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update -y 

# Git
RUN apt-get install -y ca-certificates git-core ssh
RUN apt-get install -y git

# Java 8
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java8-installer

# Emacs
RUN apt-get install -y emacs24-nox
RUN apt-get install -y rlwrap

# Fixes empty home
ENV HOME /root

# Ant
RUN apt-get install -y ant

# Eclipse (headless)
RUN apt-get install -y xvfb
RUN apt-get install -y build-essential
RUN wget http://www.mirrorservice.org/sites/download.eclipse.org/eclipseMirror/technology/epp/downloads/release/mars/2/eclipse-jee-mars-2-linux-gtk-x86_64.tar.gz
RUN tar -zxf eclipse-jee-mars-2-linux-gtk-x86_64.tar.gz
RUN mv eclipse /opt

# Eclim

RUN wget http://www.mirrorservice.org/sites/download.sourceforge.net/pub/sourceforge/e/ec/eclim/eclim/2.5.0/eclim_2.5.0.jar

RUN useradd -ms /bin/bash eclim
RUN chown eclim eclim_2.5.0.jar
RUN mv eclim_2.5.0.jar /home/eclim

USER eclim
ENV HOME /home/eclim
RUN /opt/eclipse/eclipse -initialize

WORKDIR $HOME
RUN Xvfb :1 -screen 0 1024x768x24 & 
RUN DISPLAY=:1 /opt/eclipse/eclipse -nosplash -consolelog -debug -application org.eclipse.equinox.p2.director -repository http://download.eclipse.org/releases/mars -installIU org.eclipse.wst.web_ui.feature.feature.group

RUN java -Dvim.skip=true -Declipse.home=/opt/eclipse -Declipse.local=$HOME/.eclipse/org.eclipse.platform_4.5.2_1473617060_linux_gtk_x86_64 -jar eclim_2.5.0.jar install

RUN git clone https://$GITHUB_PAT@github.com/nimo71/java.emacs.d.git
RUN mv java.emacs.d .emacs.d 
WORKDIR $HOME/.emacs.d
RUN git submodule init
RUN git submodule update
WORKDIR $HOME

RUN DISPLAY=:1 .eclipse/org.eclipse.platform_4.5.2_1473617060_linux_gtk_x86_64/eclimd -b

# TODO:
# - additional eclipse features as described on http://eclim.org/install.html#install-headless ???
# - add eclim configuration
# - instead of downloading eclim and eclipse get them from git?? Tags for upgrade ?? 
# - java environment variables
# - move versions into env (or docker?) variables
# - gradle 
# - gradle environment variables
# - gradle integration with emacs
# - git integration with emacs
# - shortcuts


