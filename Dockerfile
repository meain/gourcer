# Using a dockerfile since it was kinda tricky to get it working in Github
# Actions without some very specific dependencies.
FROM ubuntu:14.04

RUN apt-get update -y && apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:kirillshkrogalev/ffmpeg-next
RUN apt-get update -y && apt-get install -y git mercurial xvfb xfonts-base xfonts-75dpi xfonts-100dpi xfonts-cyrillic gource ffmpeg screen wget pv bc jq

RUN wget 'https://github.com/porjo/youtubeuploader/releases/download/21.04/youtubeuploader_linux_amd64.tar.gz'
RUN tar -xvzf youtubeuploader_linux_amd64.tar.gz

ADD ./gourcer /tmp/gourcer
ADD ./create-video /tmp/create-video

VOLUME ["/repo", "/avatars", "/results"]
WORKDIR /repo
CMD bash /tmp/gourcer
