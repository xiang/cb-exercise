FROM golang:alpine

WORKDIR $GOPATH/src/api
COPY . $GOPATH/src/api

RUN go get 
RUN go install 

CMD ["api"]

EXPOSE 8080/tcp
