FROM koalaman/shellcheck-alpine:v0.11.0 as verify-sh
WORKDIR /src
COPY ./*.sh ./
RUN shellcheck -e SC1091,SC1090 ./*.sh

FROM node:22.14.0 AS restore
WORKDIR /src
COPY package.json yarn.lock ./
RUN yarn --frozen-lockfile
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
RUN yarn build && npm prune --production

FROM gcr.io/distroless/nodejs:16 as final
USER nobody
WORKDIR /app
COPY --chown=nobody --from=build /src/package.json .
COPY --chown=nobody --from=build /src/dist ./dist
COPY --chown=nobody --from=build /src/node_modules ./node_modules
EXPOSE 3000
ARG NODE_ENV=production
ENV NODE_ENV $NODE_ENV
ARG version=unknown
# TODO
# RUN echo $version > /app/wwwroot/version.txt
LABEL name="doppler-emms-socket" version="$version"
# TODO: remove?
ENV PATH /app/node_modules/.bin:$PATH
CMD ["dist/main.js"]
