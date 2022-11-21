# For hosting helm local repo
FROM ubuntu
RUN ["apt-get", "update"]
RUN ["apt-get", "install", "-y", "python3.6", "python3-pip", "python3-apt", "python3-distutils"]
RUN mkdir chartsrepo
COPY ./test.sh /test.sh
RUN ["apt-get", "install","-y","curl"]
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh
RUN helm repo index chartsrepo/
RUN helm create firstchart
RUN helm package firstchart -d chartsrepo/
RUN helm repo index chartsrepo/
RUN cd chartsrepo
ENTRYPOINT ["./test.sh"]
