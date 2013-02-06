web: bundle exec rails server thin -p $PORT -e $RACK_ENV
email: bundle exec rake resque:work QUEUE=email
video: bundle exec rake resque:work QUEUE=video
