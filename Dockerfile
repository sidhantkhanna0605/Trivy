# For hosting helm local repo
FROM ubuntu
RUN ["apt-get", "update"]
ENTRYPOINT ["tail","-f","/dev/null"]
