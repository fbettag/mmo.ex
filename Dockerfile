FROM bitwalker/alpine-elixir-phoenix as builder
ARG APP_NAME=mmo
ARG APP_VSN=0.1.0

ENV APP_VSN=${APP_VSN} APP_NAME=${APP_NAME}

# Update node and npm
RUN apk upgrade --no-cache

WORKDIR /opt/app
COPY . .

ENV MIX_ENV=prod

RUN mix deps.get --only prod
RUN mix compile
#RUN npm install --prefix assets
#RUN npm run deploy --prefix assets
RUN mix phx.digest

RUN \
  mkdir -p /opt/built && \
  mix distillery.release --verbose --env=prod && \
  tar -vxzf _build/prod/rel/${APP_NAME}/releases/${APP_VSN}/${APP_NAME}.tar.gz -C /opt/built

# Runtime
FROM bitwalker/alpine-elixir

# We need bash and openssl for Phoenix
RUN apk upgrade --no-cache
RUN apk add --no-cache git wget bash openssl postgresql-client

ENV MIX_ENV=prod SHELL=/bin/bash REPLACE_OS_VARS=true

WORKDIR /opt/app
COPY --from=builder /opt/built .
COPY docker-entrypoint.sh /

CMD /docker-entrypoint.sh
