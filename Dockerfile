FROM elixir:1.16.1 as builder

WORKDIR /app

RUN mix local.hex --force && \
  mix local.rebar --force

ENV MIX_ENV="prod"
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY mix.exs mix.lock ./
COPY apps/core/mix.exs apps/core/
COPY apps/web/mix.exs apps/web/

RUN mix deps.get --only $MIX_ENV
RUN mkdir config

COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY apps apps

RUN mix compile

COPY config/runtime.exs config/

COPY rel rel
RUN mix release

WORKDIR /app

EXPOSE 4000
EXPOSE 4001

CMD ["mix", "phx.server"]
