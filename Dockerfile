# For hosting helm local repo
FROM nginx
RUN ["apt-get", "update"]
ENTRYPOINT ["tail","-f","/dev/null"]
