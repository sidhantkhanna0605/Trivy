FROM ubuntu
RUN ["apt-get", "update"]
ENTRYPOINT ["tail","-f","/dev/null"]
