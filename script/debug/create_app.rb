require File.expand_path('config/environment.rb')

account_name = ARGV.shift
app_name = ARGV.shift

account = Account.find_or_create_by_name account_name
app = App.find_or_create_by_name app_name, account: account

if app.account != account
  puts "*** There are two accounts with name: #{accoutn_name}"
  puts "*** account:     #{account}"
  puts "*** app.account: #{account}"
end

puts "Current accounts:"
Account.find_each {|a| puts a.inspect }

puts
puts "Current apps:"
App.find_each { |a| puts a.inspect }
