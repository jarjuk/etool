 FROM ubuntu:18.04

 # Tools for installing packages
 RUN apt-get update && \
     apt-get install -y \
     curl \
     wget \
     git \
     gnupg2  gnupg

 # Common dev tools
 RUN apt-get install -y \
      build-essential \
      linux-headers-$(uname -r) \
      dkms 


 ENV LANG C.UTF-8

# End of common Dockerfile 


# Fix tzdata hangs (dependency of dependencies)
# https://grigorkh.medium.com/fix-tzdata-hangs-docker-image-build-cdb52cc3360d

ENV TZ=Europe/Helsinki
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get -y install \
    tzdata

# Fix error:  https://forum.linuxcnc.org/9-installing-linuxcnc/37254-libxenomai-dev-says-no
#
# Package libxenomai-dev exists, but information about its source
# package is not available.  This most likely means that you do not
# have the right deb-src lines in /etc/apt, or that you need to
# "apt-get update".
RUN \
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.orig \
    &&   sed -i -e'/bionic main restricted/s!# deb-src!deb-src!'       \
                -e'/bionic-updates main restricted/s!# deb-src!deb-src!' \
                -e'/bionic universe/s!# deb-src!deb-src!' \
                -e'/bionic-updates universe/s!# deb-src!deb-src!' \
                /etc/apt/sources.list \
    && apt-get update

# Install linuxcnc dependencies

RUN apt-get -y install \
   devscripts \
   build-essential  \
   dpkg-dev \
   debhelper \
   dh-python \
   libudev-dev \
   libxenomai-dev \
   tcl8.6-dev \
   tk8.6-dev \
   libreadline-gplv2-dev \
   asciidoc dblatex \
   docbook-xsl \
   dvipng \
   graphviz \
   groff \
   inkscape \
   python-lxml \
   source-highlight \
   w3c-linkchecker \
   xsltproc \
   texlive-extra-utils \
   texlive-font-utils \
   texlive-fonts-recommended texlive-lang-cyrillic texlive-lang-french texlive-lang-german texlive-lang-polish texlive-lang-spanish \
   texlive-latex-recommended asciidoc-dblatex python python-dev python-tk libxmu-dev \
   libglu1-mesa-dev libgl1-mesa-dev \
   libgtk2.0-dev intltool autoconf libboost-python-dev \
   libmodbus-dev \
   libusb-1.0-0-dev yapps2 \
   iptables netcat psmisc desktop-file-utils

# Clone linuxcnc repo && checkout correct version

RUN \
    git clone https://github.com/LinuxCNC/linuxcnc.git emc \
    && cd emc \
    && git checkout 2.8


RUN diff /etc/apt/sources.list /etc/apt/sources.list.orig 2>&1; echo $?

# Additional dependecies (missed by dpkg-checkbuilddeps)
RUN apt-get install -y \
             bwidget \
             libtk-img \
             tclx \
             python-gtk2

# Configure && check that depencies correctly installed
RUN \
   cd emc \
   && debian/configure uspace \
   && dpkg-checkbuilddeps \
   && cd src \
   && ./autogen.sh \
   && ./configure --with-realtime=uspace \
   && make 

# ------------------------------------------------------------------
# pcb2gcode - frozen on hash 'e53eae9b8d490f76be6d1716dcf3b6c0ff5aad92'

RUN \
     git clone  https://github.com/pcb2gcode/pcb2gcode \
     && cd pcb2gcode \
     && git checkout e53eae9b8d490f76be6d1716dcf3b6c0ff5aad92

RUn apt-get install -y \
             build-essential \
             automake \
             autoconf \
             autoconf-archive \
             libtool \
             libboost-program-options-dev \
             libgtkmm-2.4-dev \
             gerbv \
             librsvg2-dev

# compile and configure  pcb2gcode
RUN \
        cd /pcb2gcode \
     && autoreconf -fvi \
     && ./configure \
     &&  make \
     && make install

# ------------------------------------------------------------------
# pcbGcodeZprobing

# RUN git clone https://github.com/hase-berlin/pcbGcodeZprobing
# Use pathced 'pcbGcodeZprobing'
RUN mkdir /pcbGcodeZprobing
COPY pcbGcodeZprobing.py /pcbGcodeZprobing

# ------------------------------------------------------------------
# Examples and other resources

COPY resources/ /resources

# ------------------------------------------------------------------
# Configuration

# expect smthng like -v $HOME/etool:/etool on docker command
WORKDIR /etool

# linuxcnc uses $HOME/linuxcnc - map HOME to /etool
ENV HOME=/etool

# /etool-bin created and added to path
RUN mkdir /etool-bin
ENV PATH=/etool-bin:/emc/scripts:${PATH}

COPY etool.sh /etool-bin/
COPY RELEASES /etool-bin/
COPY axis_etool.ini /etool-bin/
COPY sim_mm.tbl /etool-bin/
COPY .linuxcncrc /etool-bin/
COPY pcb2gcode.ini /etool-bin/
COPY pcb2gcode-control.template /etool-bin/
COPY pcb2gcode-control.template /etool-bin/
COPY Dockerfile /etool-bin/

# entry only trough script - default output usage
ENTRYPOINT [ "etool.sh" ]
CMD [ "usage"]
