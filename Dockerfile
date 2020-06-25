FROM utensils/envisaged

ENV GIT_URL='https://github.com/meain/ppl.git'
ENV GOURCE_TITLE='meain/ppl'

COPY entrypoint.sh entry

CMD sh entry
