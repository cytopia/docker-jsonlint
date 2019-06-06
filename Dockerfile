FROM alpine:latest as builder

# Install dependencies
RUN set -x \
	&& apk add --no-cache \
		nodejs-current \
		npm \
		git
RUN set -x \
	&& mkdir -p /tmp \
	&& git clone https://github.com/zaach/jsonlint /tmp/jsonlint \
	&& cd /tmp/jsonlint \
	&& npm install


FROM alpine:latest
RUN set -x \
	&& apk add --no-cache nodejs-current bash \
	&& ln -s /node_modules/.bin/jsonlint /usr/bin/jsonlint
COPY --from=builder /tmp/jsonlint/node_modules/ /node_modules/
COPY ./data/docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /data
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["--help"]
