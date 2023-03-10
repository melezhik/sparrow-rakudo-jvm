FROM alpine:latest
ENV PATH="/home/worker/.raku/bin:/var/rakudo/rakudo-2022.12/install/bin/:${PATH}"
ENV SP6_DUMP_TASK_CODE=1
ENV SP6_FORMAT_COLOR=1
RUN apk update && apk add openssl bash curl wget perl openssl-dev sudo git
RUN apk add --no-cache bash g++ make
RUN mkdir -p /var/rakudo/ && cd /var/rakudo/ && curl -sLf https://rakudo.org/dl/rakudo/rakudo-2022.12.tar.gz -o rakudo-2022.12.tar.gz
RUN apk add openjdk9 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
RUN echo OK
RUN cd /var/rakudo/ && tar -xzf rakudo-2022.12.tar.gz && cd rakudo-2022.12 && \
perl Configure.pl --gen-nqp --backends=jvm
RUN cd /var/rakudo/rakudo-2022.12 && make
RUN cd /var/rakudo/rakudo-2022.12 && make install
RUN adduser -D -h /home/worker -s /bin/bash -G wheel worker
RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN addgroup worker wheel
RUN sudo echo
USER worker
RUN find /var/rakudo/rakudo-2022.12/install/bin/ 
RUN sudo ln -s /var/rakudo/rakudo-2022.12/install/bin/rakudo /var/rakudo/rakudo-2022.12/install/bin/raku
RUN cd /tmp/ && git clone https://github.com/hythm7/Pakku.git && \
cd /tmp/Pakku && raku -I. bin/pakku add noprecomp notest to home .
RUN zef update
RUN zef install --/test JSON::Fast --install-to=home
RUN sudo apk add build-base
RUN echo OK1 && zef install --/test https://github.com/melezhik/Sparrow6.git --install-to=home
RUN echo OK2 && zef install --/test https://github.com/melezhik/Tomtit.git --install-to=home
RUN echo OK3 && zef install --/test https://github.com/melezhik/Tomty.git --install-to=home
RUN echo OK4 && zef install --/test --force-install https://github.com/melezhik/sparky-job-api.git --install-to=home
RUN sudo apk add go --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
