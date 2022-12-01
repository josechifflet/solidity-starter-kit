FROM node:16-alpine as base
# Create the user up front to save a little time on rebuilds.
RUN adduser --gecos '' --disabled-password --no-create-home user
ENV NODE_OPTIONS=--max-old-space-size=4096
# Create app directory
RUN mkdir -p /usr/src/backend
WORKDIR /usr/src/backend
# Copy deps files
COPY package.json /usr/src/backend/package.json
COPY yarn.lock /usr/src/backend/yarn.lock

# BUILD DEPS
FROM base as build-deps
RUN yarn
COPY . /usr/src/backend
WORKDIR /usr/src/backend
RUN yarn build

# START API
FROM base as prod-stage
COPY --from=build-deps /usr/src/backend/dist ./dist
RUN yarn --production
CMD ["yarn", "start"]


