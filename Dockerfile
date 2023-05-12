FROM ubuntu:20.04
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update && \
    apt install -y wget make coreutils openjdk-11-jdk \
    python3 python3-pip
RUN python3 -m pip install stardist tensorflow csbdeep tifffile
ENV M2_HOME='/opt/apache-maven-3.9.1'
ENV PATH="/opt/apache-maven-3.9.1/bin:$PATH"
RUN java -version && \
    wget https://dlcdn.apache.org/maven/maven-3/3.9.1/binaries/apache-maven-3.9.1-bin.tar.gz && \
    tar -xzvf apache-maven-3.9.1-bin.tar.gz && \
    mv apache-maven-3.9.1 /opt/ && \
    mvn -version
RUN mkdir /usr/local/multiplexprocessor && \
    cd /usr/local/multiplexprocessor && \
    wget --quiet https://gitlab.in2p3.fr/micropicell/multiplexprocessor/-/archive/master/multiplexprocessor-master.tar.gz && \
    tar xzvf multiplexprocessor-master.tar.gz
RUN cd /usr/local/multiplexprocessor/multiplexprocessor-master && \
    sed -i  's/copy/cp/' core/Makefile && \
    sed -i  's/T-SNE-Java/tsne/' core/pom.xml && \
    sed -i  's/com.github.lejon/com.github.lejon.T-SNE-Java/' core/pom.xml && \
    sed -i  's/content\/repositories\/releases/content\/repositories\/public/' core/pom.xml && \
    sed -i '/gui/d' Makefile && \
    mvn install:install-file -Dfile=./gui/CSV2FCS/jar/csv2fcs.jar -DgroupId=net.sf.flowcyt -DartifactId=csv2fcs -Dversion=0.0.0 -Dpackaging=jar && \
    make
RUN mkdir -p /usr/local/fftw && \
    cd /usr/local/fftw && \
    wget --quiet https://www.fftw.org/fftw-3.3.10.tar.gz && \
    tar xzvf fftw-3.3.10.tar.gz && \
    cd fftw-3.3.10 && \
    ./configure --enable-shared && \
    make && \
    make install && \
    ./configure --enable-float --enable-shared && \
    make && \
    make install
