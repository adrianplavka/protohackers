FROM elixir:1.14-otp-24 AS builder

ENV MIX_ENV="prod"

RUN apt-get update -y && apt-get install -y build-essential git \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

WORKDIR /app

RUN mix do local.hex --force, local.rebar --force

COPY mix.exs ./
RUN mix do deps.get --only ${MIX_ENV}, deps.compile

COPY config config
COPY lib lib
RUN mix compile

COPY rel rel
RUN mix release

FROM debian:bullseye-20221219-slim AS runner

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /app

COPY --from=builder /app/_build/prod/rel ./

CMD /app/protohackers/bin/protohackers start
