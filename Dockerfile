# For hosting helm local repo
FROM ubuntu:14.04
RUN ["apt-get", "update"]
ENTRYPOINT ["tail","-f","/dev/null"]
