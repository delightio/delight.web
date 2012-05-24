require File.expand_path('config/environment.rb')

ios_dir = File.join Rails.root, '..', 'delight.ios'
puts "cd #{ios_dir}"
FileUtils.cd ios_dir

puts "Running 'appledoc .'"
`appledoc .`

src_html = '/tmp/appledoc/delight.ios/html/'
dst = File.join Rails.root, 'public', 'api'
puts "Copying from #{src_html} to #{dst}"
`cp -r "#{src_html}" "#{dst}"`