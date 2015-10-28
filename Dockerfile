FROM debian:stable
MAINTAINER Adrian Fritz, Adrian.Fritz@Helmholtz-HZI.de

# In case you're sitting behind a proxy
ENV http_proxy http://rzproxy.helmholtz-hzi.de:3128
ENV https_proxy http://rzproxy.helmholtz-hzi.de:3128

ENV PACKAGES wget git gcc make unzip build-essential zlib1g-dev python

RUN apt-get update
RUN apt-get install -y -q ${PACKAGES}

# install bowtie2 
RUN wget http://downloads.sourceforge.net/project/bowtie-bio/bowtie2/2.2.2/bowtie2-2.2.2-linux-x86_64.zip;\
    unzip bowtie2-2.2.2-linux-x86_64.zip && rm -rf bowtie2-2.2.2-linux-x86_64.zip;\
    ln -s `pwd`/bowtie*/bowtie* /usr/local/bin

# Clone ALE repository
RUN git clone https://github.com/sc932/ALE.git
RUN cd ALE/src && make && ln -f -s `pwd`/bin/* /usr/local/bin/ && cd ../

ENV CONVERT https://github.com/bronze1man/yaml2json/raw/master/builds/linux_386/yaml2json
# download yaml2json and make it executable
RUN cd /usr/local/bin && wget --quiet ${CONVERT} && chmod 700 yaml2json

ENV JQ http://stedolan.github.io/jq/download/linux64/jq
# download jq and make it executable
RUN cd /usr/local/bin && wget --quiet ${JQ} && chmod 700 jq

VOLUME ["/output"]

# Add Taskfile to /
ADD Taskfile /

RUN cd /

ADD validate /usr/local/bin/

ENTRYPOINT ["validate"]
