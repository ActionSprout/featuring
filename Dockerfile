FROM ruby:2.4-alpine

RUN apk add --no-cache \
  build-base \
  bash \
  curl \
  git \
  libffi-dev \
  postgresql-dev \
  && mkdir /usr/src/gem

WORKDIR /usr/src/gem

COPY . ./

RUN gem install bundler
RUN bundle install

ENTRYPOINT ["/bin/bash", "-l", "-c"]
