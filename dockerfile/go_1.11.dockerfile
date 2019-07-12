FROM golang:1.11.5

# set
ENV GOBIN="${GOPATH}/bin"
ENV PATH="${PATH}:${GOBIN}"

# install govendor & gin
RUN go get github.com/kardianos/govendor && go get github.com/codegangsta/gin