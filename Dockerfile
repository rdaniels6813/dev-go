FROM golang:1.14.2

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
  && apt-get -y install git openssh-client less iproute2 procps lsb-release unzip zip clang-format bash-completion groff python3-distutils \
  && mkdir -p /tmp/gotools \
  && cd /tmp/gotools \
  && GO111MODULE=on go get -v golang.org/x/tools/gopls@latest 2>&1 \
  && GO111MODULE=on go get -v \
  honnef.co/go/tools/...@latest \
  golang.org/x/tools/cmd/gorename@latest \
  golang.org/x/tools/cmd/goimports@latest \
  golang.org/x/tools/cmd/guru@latest \
  golang.org/x/lint/golint@latest \
  github.com/mdempsky/gocode@latest \
  github.com/cweill/gotests/...@latest \
  github.com/haya14busa/goplay/cmd/goplay@latest \
  github.com/sqs/goreturns@latest \
  github.com/josharian/impl@latest \
  github.com/davidrjenni/reftools/cmd/fillstruct@latest \
  github.com/uudashr/gopkgs/v2/cmd/gopkgs@latest  \
  github.com/ramya-rao-a/go-outline@latest  \
  github.com/acroca/go-symbols@latest  \
  github.com/godoctor/godoctor@latest  \
  github.com/rogpeppe/godef@latest  \
  github.com/zmb3/gogetdoc@latest \
  github.com/fatih/gomodifytags@latest  \
  github.com/mgechev/revive@latest  \
  github.com/go-delve/delve/cmd/dlv@latest 2>&1 \
  && curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin 2>&1 \
  && chmod -R a+w /go/pkg \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* /go/src /tmp/gotools˝

RUN curl -o- https://bootstrap.pypa.io/get-pip.py | python3 \
  && pip install --no-cache-dir awscli-local

RUN echo "source /etc/profile.d/bash_completion.sh" >> ~/.bashrc
# Enable aws completion for awslocal
RUN echo "complete -C aws_completer awslocal" >> ~/.bashrc

# Install task.dev
ARG TASKFILE_VERSION=2.8.0
RUN cd /tmp \
  && curl -sSL "https://github.com/go-task/task/releases/download/v${TASKFILE_VERSION}/task_linux_amd64.tar.gz" -o task_linux_amd64.tar.gz \
  && tar xvzf task_linux_amd64.tar.gz \
  && mv task /usr/local/bin \
  && rm -rf /tmp/* \
  && curl -sSL "https://raw.githubusercontent.com/go-task/task/v${TASKFILE_VERSION}/completion/bash/task.bash" -o /etc/bash_completion.d/task.bash

# Install jq
ARG JQ_VERSION=1.6
RUN curl -sSL https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 -o /usr/local/bin/jq \
  && chmod +x /usr/local/bin/jq
# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
