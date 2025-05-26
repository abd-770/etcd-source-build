# golang as base image
FROM golang:1.24.2

# apt-get update -> updates the list of available versions for each package
# apt-get upgrade-> actually installs newer versions of the packages
# always need to update before upgrade 
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git

# Clone the etcd repo of version v3.5.21 into etcd/
# --depth=1 -> just latest commit of the given tag, skip downloading all the history up to that revision
ARG ETCD_VERSION_TAG=v3.5.21 
RUN git clone --depth 1 --branch ${ETCD_VERSION_TAG} https://github.com/etcd-io/etcd.git 

# Set the working directory of the container to etcd/server
# ./server points to the package (in the etcd repo) that compiles the etcd server binary
WORKDIR /go/etcd/server
RUN go build -o /go/bin/etcd

# Set the working directory of the container to etcd/etcdctl
# ./etcdctl points to the package (in the etcd repo) that compiles the etcd etcdctl binary
WORKDIR /go/etcd/etcdctl
RUN go build -o /go/bin/etcdctl

# Set the working directory back to /go, so that the container starts here
WORKDIR /go




