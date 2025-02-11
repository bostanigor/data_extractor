FROM ruby:3.2-alpine3.20

RUN mkdir app/
COPY Gemfile ./app
COPY . app/
WORKDIR app/

ENV BUILD_PACKAGES bash curl curl-dev ruby-dev build-base yaml-dev
ENV RUBY_PACKAGES \
  ruby ruby-io-console ruby-irb \
  ruby-etc ruby-bigdecimal \
  libffi-dev zlib-dev poppler-utils imagemagick-dev imagemagick-libs
RUN apk add --no-cache $BUILD_PACKAGES $RUBY_PACKAGES
RUN bundle install

ENTRYPOINT ["bin/data_extractor"]
CMD ["--help"]