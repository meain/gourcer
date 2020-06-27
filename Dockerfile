FROM ubuntu:14.04

RUN apt-get update -y && apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:kirillshkrogalev/ffmpeg-next
RUN apt-get update -y && apt-get install -y git mercurial xvfb xfonts-base xfonts-75dpi xfonts-100dpi xfonts-cyrillic gource ffmpeg screen

ADD ./gourcer /tmp/gourcer
ADD ./qg /tmp/qg

ENV TITLE "Example title"

VOLUME ["/repo", "/avatars", "/results"]
WORKDIR /repo
CMD bash /tmp/gourcer
