FROM fedora:42

ARG TERRAFORM_VERSION=1.11.4
ARG NOMAD_VERSION=1.10.5

RUN dnf install -y ca-certificates curl unzip bash git \
    && dnf clean all \
    && rm -rf /var/cache/dnf

RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o /tmp/terraform.zip \
    && unzip -oq /tmp/terraform.zip terraform -d /usr/local/bin \
    && rm /tmp/terraform.zip

RUN curl -fsSL "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip" -o /tmp/nomad.zip \
    && unzip -oq /tmp/nomad.zip nomad -d /usr/local/bin \
    && rm /tmp/nomad.zip

WORKDIR /workspace

COPY docker/entrypoint.sh /usr/local/bin/tf-provider-testing-entrypoint
RUN chmod +x /usr/local/bin/tf-provider-testing-entrypoint

ENTRYPOINT ["tf-provider-testing-entrypoint"]
CMD ["sh"]
