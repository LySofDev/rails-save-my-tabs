FROM ruby:2.5.1-alpine3.7
RUN apk update && apk add build-base postgresql-dev && gem install bundler
RUN mkdir /save-my-tabs
WORKDIR /save-my-tabs
COPY Gemfile* /save-my-tabs/
RUN bundle install
COPY . /save-my-tabs
# Development Server
CMD ["bin/test"]
# Testing Server
# CMD ["bin/test"]
