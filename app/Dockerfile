FROM ruby:alpine

EXPOSE 9292
WORKDIR /usr/src/app

COPY Gemfile ./
RUN bundle install

COPY . .

# Rack likes to listen only on localhost. That's less than ideal in a container.
CMD ["rackup", "--host", "0.0.0.0"]