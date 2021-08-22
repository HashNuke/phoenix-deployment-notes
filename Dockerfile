ARG ELIXIR_VERSION=1.12.2

FROM elixir:${ELIXIR_VERSION}

ARG DATABASE_URL=""
ARG SECRET_KEY_BASE=""
ARG NODE_VERSION=14.17.5

RUN apt update \
    && apt install -y \
        curl \
        wget \
        ca-certificates \
    && update-ca-certificates

RUN apt install -y \
        build-essential \
        libssl-dev \
        curl \
        graphicsmagick \
        imagemagick --fix-missing

RUN mkdir -p /tools/nodejs \
    && wget https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz \
    && tar xvf node-v${NODE_VERSION}-linux-x64.tar.xz \
        -C /tools/nodejs \
        --strip-components 1 \
    && rm node-v${NODE_VERSION}-linux-x64.tar.xz

ENV PATH="$PATH:/tools/nodejs/bin"
ENV PATH="$PATH:/app/assets/node_modules/.bin"

RUN mkdir -p /app/assets
WORKDIR /app

COPY mix.exs /app/mix.exs
COPY mix.lock /app/mix.lock

RUN mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get --only prod

COPY assets/package.json /app/assets/package.json
RUN npm install --prefix ./assets

COPY . /app

# App env vars
ENV MIX_ENV=prod
ENV PORT=4001
EXPOSE 4001

RUN mix deps.compile
RUN mix compile \
    && npm run deploy --prefix ./assets \
    && mix phx.digest

CMD ["mix" "phx.server"]
