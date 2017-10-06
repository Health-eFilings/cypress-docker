FROM projectcypress/cypress:release-v3.0.1

RUN mkdir -p /rails/cypress/temp && \
    mkdir -p /rails/cypress/data && \
    mkdir -p /rails/cypress/public/data

RUN rm /rails/cypress/config/cypress.yml
COPY config/cypress.yml /rails/cypress/config/cypress.yml
