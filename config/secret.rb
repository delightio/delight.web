ENV["REDISTOGO_URL"] = 'redis://localhost:6379/3'
if Rails.env.test?
  ENV["REDISTOGO_URL"] = 'redis://localhost:6379/5'
end
ENV['WORKING_DIRECTORY'] = File.join Rails.root, 'tmp'
ENV['TWITTER_KEY'] = 'wVm8kLOClLLMY1v5c4uHow'
ENV['TWITTER_SECRET'] = 'np2UjNQjvLTqs07w86H6HwsEnDGEHB1FjWzpTL2KQ'
ENV['AWS_ACCESS_KEY_ID'] = 'AKIAJ7DMQLDQBHPOEH2A'
ENV['AWS_SECRET_ACCESS_KEY'] = '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'
ENV['S3_UPLOAD_BUCKET'] = 'delight_upload_tpun'
ENV['MAILGUN_USERNAME'] = 'api'
ENV['MAILGUN_PASSWORD'] = 'key-2g0kzoi319ny0w8sp2q16yocebedta13'
ENV['ACTION_MAILER_DEFAULT_URL_HOST'] = 'localhost'
ENV['STRIPE_PUBLISHABLE_KEY'] = 'pk_mGcggKRI2K6MYCDLpRiCzlEzoag8i'
ENV['STRIPE_SECRET_KEY'] = 'vlBIWPoWUbZDRAb9UCtzWPZn4es3nHVA'