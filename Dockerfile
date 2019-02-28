FROM phusion/passenger-ruby24:latest

RUN apt-get update \
    && apt-get upgrade -y -o Dpkg::Options::="--force-confold" \
    && apt-get install -y nodejs tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install ruby 2.6.0 in order to match what we are developing against.
RUN bash -lc 'rvm install ruby-2.4.5'
RUN bash -lc 'rvm --default use ruby-2.4.5'
RUN gem install bundler

ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES 1
ENV SECRET_KEY_BASE 25c111009b55154d7570898ef7c33699a2886fa4e1a8ba034099bc33be67d21157a91d24932deaf5940132728482b5a42ffb1c7d87dd5e7978a1a21c525182a9

# Will be created by git clone
# RUN mkdir /home/app/cypress

# Clone repo
RUN git clone https://github.com/projectcypress/cypress.git /home/app/cypress

WORKDIR /home/app/cypress

RUN git checkout -b v4.0.2 v4.0.2

RUN chown -R app:app .

RUN su app -c 'bundle install --without development test'

# If the tmp directory doesn't exist then the app will not be able to run.
# By creating it here it will get chowned correctly by the next declaration.
RUN mkdir -p temp tmp/cache tmp/bundles tmp/delayed_pids data public/data/upload

# This line is a duplicate however it is done to significantly speed up testing. With this line twice
# we are able to do the bundle install earlier on which means it is cached more often.
RUN chown -R app:app .

# Rewrite initializer to avoid accessing database
ADD defaults/initializers/smtp.rb /home/app/cypress/config/initializers/smtp.rb

# Precompile assets
RUN rake assets:precompile RAILS_ENV=production

# Remove logs
RUN rm log/*.log

RUN mkdir /etc/service/unicorn
RUN cp docker_unicorn_start.sh /etc/service/unicorn/run
RUN chmod 755 /etc/service/unicorn/run

RUN mkdir /etc/service/cypress_delayed_job_1
RUN cp docker_delayed_job.sh /etc/service/cypress_delayed_job_1/run
RUN chmod 755 /etc/service/cypress_delayed_job_1/run

# Setup other workers based on first worker. This makes it where tweaking the number of workers
# just requires changing this WORKER_COUNT. Unfortunately does not allow tweaking after build is completed.
ARG WORKER_COUNT=4
RUN if [ $WORKER_COUNT -gt 1 ]; then \
      for i in $(seq 2 1 $WORKER_COUNT); do \
        cp -R /etc/service/cypress_delayed_job_1 /etc/service/cypress_delayed_job_$i; \
      done; \
    fi

EXPOSE 3000
