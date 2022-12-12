FROM bitnami/kubectl:1.24 as kubectl
FROM ubuntu:18.04
RUN apt-get update && apt-get install -y jq
COPY ./performance.sh /performance.sh
COPY ./zadara_test.yaml /zadara_test.yaml
COPY ./zadara_complete.yaml /zadara_complete.yaml
RUN mkdir -p /kubeconfig
RUN mkdir /results
COPY --from=kubectl /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/
ENTRYPOINT ["./performance.sh"]
