web: bundle exec rails server thin -p $PORT -e $RACK_ENV
email: rake resque:work QUEUE='email'
video: rake reaque:work QUEUE='video'
