# Using a dockerfile since it was kinda tricky to get it working in Github
# Actions without some very specific dependencies.
FROM ubuntu:24.04

RUN apt-get update -y && apt-get install -y software-properties-common
# RUN add-apt-repository -y ppa:kirillshkrogalev/ffmpeg-next
RUN apt-get update -y && apt-get install -y git mercurial \
    xvfb xfonts-base xfonts-75dpi xfonts-100dpi xfonts-cyrillic \
    gource ffmpeg screen wget pv bc jq curl

RUN curl -L 'https://github.com/porjo/youtubeuploader/releases/download/v1.25.5/youtubeuploader_1.25.5_Linux_amd64.tar.gz' | \
    tar xzvf - -C . youtubeuploader

ADD ./gourcer /tmp/gourcer
ADD ./create-video /tmp/create-video

VOLUME ["/repo", "/avatars", "/results"]
WORKDIR /repo
CMD ["bash", "/tmp/gourcer"]
