FROM koalaman/shellcheck-alpine:v0.8.0 as verify-sh
WORKDIR /src
COPY ./*.sh ./
RUN shellcheck -e SC1091,SC1090 ./*.sh

FROM node:16.18.0 AS restore
WORKDIR /src
COPY package.json yarn.lock ./
RUN yarn
COPY . .

FROM restore AS verify-format
ENV CI=true
RUN yarn verify-format

FROM restore AS lint
ENV CI=true
RUN yarn lint

FROM restore AS test
ENV CI=true
RUN yarn test:ci

FROM restore AS build
WORKDIR /src
COPY . .
RUN yarn build

# FROM node:16.18.0 AS production-restore
# WORKDIR /src
# COPY package.json yarn.lock ./
# RUN yarn --production --ignore-scripts

FROM gcr.io/distroless/nodejs:16 as final
USER nobody
# Potential optimization
# COPY --chown=nobody --from=production-restore /src/node_modules /app/node_modules
# COPY --chown=nobody --from=build /src/dist /app/dist
#
# COPY --chown=nobody --from=build /src/dist /src/node_modules /app
# sha256:c1a4dc435233a3222823df518097243c89344dca8d051eff37a31e9b96625113
#
COPY --chown=nobody --from=build /src /app
WORKDIR /app
EXPOSE 8080
ARG NODE_ENV=production
ENV NODE_ENV $NODE_ENV
ARG version=unknown
# TODO
# RUN echo $version > /app/wwwroot/version.txt
LABEL name="doppler-emms-socket" version="$version"
# TODO: remove?
ENV PATH /app/node_modules/.bin:$PATH
CMD ["dist/main.js"]
