# Start by building the application.
FROM golang:1.19-alpine as build

ENV USER=appuser
ENV UID=10001

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

WORKDIR $GOPATH/src/app/

COPY ["src/go.mod", "src/go.sum", "./"]
RUN go mod download

ADD ["src/cmd", "cmd"]
ADD ["src/svc", "svc"]
RUN CGO_ENABLED=0 go build -o /app.bin cmd/main.go


FROM scratch

COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /etc/group /etc/group
COPY --from=build /app.bin  /app.bin

USER $USER:$USER
EXPOSE 9999
VOLUME uploads

ENTRYPOINT ["/app.bin"]