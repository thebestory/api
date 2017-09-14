FROM elixir:1.5

ENV DEBIAN_FRONTEND=noninteractive

ENV PHOENIX_VERSION="1.3.0"
ENV PHOENIX_REPO="https://github.com/phoenixframework/archives/raw/master" \
    PHOENIX_FILE="phx_new-${PHOENIX_VERSION}.ez"

WORKDIR /
RUN mkdir /docker

RUN apt-get update

RUN mix archive.install --force $PHOENIX_REPO/$PHOENIX_FILE && \
    mix local.hex --force && \
    mix local.rebar --force

RUN mkdir /docker/code
WORKDIR /docker/code

ADD mix.exs mix.lock ./
RUN mix deps.get && \
    mix deps.compile

ADD . .
RUN mix deps.get && \
    mix compile
