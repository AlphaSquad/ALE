FROM debian:stable
MAINTAINER Adrian Fritz, Adrian.Fritz@Helmholtz-HZI.de

ENV PACKAGES wget git gcc make unzip build-essential zlib1g-dev libbz2-dev libncurses5-dev python seqtk

RUN apt-get update
RUN apt-get install -y -q ${PACKAGES}

# install bowtie2 
RUN wget http://downloads.sourceforge.net/project/bowtie-bio/bowtie2/2.2.2/bowtie2-2.2.2-linux-x86_64.zip;\
    unzip bowtie2-2.2.2-linux-x86_64.zip && rm -rf bowtie2-2.2.2-linux-x86_64.zip;\
    ln -s `pwd`/bowtie*/bowtie* /usr/local/bin

# Clone ALE repository
RUN git clone https://github.com/sc932/ALE.git
RUN cd ALE/src && make && ln -f -s `pwd`/bin/* /usr/local/bin/

# need samtools for pipeline
RUN wget https://github.com/samtools/samtools/releases/download/1.2/samtools-1.2.tar.bz2;\
    tar -xaf samtools-1.2.tar.bz2 && rm -rf samtools-1.2.tar.bz2 ;\
    cd samtools-1.2;\
    make && ln -f -s `pwd`/* /usr/local/bin/

ENV CONVERT https://github.com/bronze1man/yaml2json/raw/master/builds/linux_386/yaml2json
# download yaml2json and make it executable
RUN cd /usr/local/bin && wget --quiet ${CONVERT} && chmod 700 yaml2json

ENV JQ http://stedolan.github.io/jq/download/linux64/jq
# download jq and make it executable
RUN cd /usr/local/bin && wget --quiet ${JQ} && chmod 700 jq

# Locations for biobox file validator
ENV VALIDATOR /bbx/validator/
ENV BASE_URL https://s3-us-west-1.amazonaws.com/bioboxes-tools/validate-biobox-file
ENV VERSION  0.x.y
RUN mkdir -p ${VALIDATOR}

# download the validate-biobox-file binary and extract it to the directory $VALIDATOR
RUN wget \
      --quiet \
      --output-document -\
      ${BASE_URL}/${VERSION}/validate-biobox-file.tar.xz \
    | tar xJf - \
      --directory ${VALIDATOR} \
      --strip-components=1

ENV PATH ${PATH}:${VALIDATOR}

VOLUME ["/output"]

# Add Taskfile to /
ADD Taskfile /

ADD validate /usr/local/bin/

ADD schema.yaml /

ADD unshuffle.pl /

ENTRYPOINT ["validate"]
