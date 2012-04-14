unless File.exists? "config/aws.yml"
  AWS.config({
    :access_key_id => ENV['access_key_id'],
    :secret_access_key => ENV['secret_access_key']
  })
end