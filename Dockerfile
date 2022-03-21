# BUILD STAGE
FROM golang:1.16-alpine AS builder
WORKDIR /workspace
COPY ./ ./
ENV GO111MODULE "on"
ENV GOPROXY "https://goproxy.cn"
RUN go env -w GO111MODULE=on 
RUN go env -w GOPROXY=https://goproxy.cn,direct 

RUN go get -d -v ./...

# Build the API
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /usr/local/bin/golang-docker ./cmd/api/

# FINAL STAGE
FROM alpine:3.9
RUN apk add --no-cache ca-certificates
COPY --from=builder /usr/local/bin/golang-docker /usr/local/bin/
COPY --from=builder /workspace/pkg/db/migrations/ /db/migrations/

RUN chown -R nobody:nogroup /usr/local/bin/golang-docker
USER nobody
EXPOSE 8080
CMD [ "golang-docker" ]
