require 'mailgun'
require 'csv'

KEY = 'key-2g0kzoi319ny0w8sp2q16yocebedta13'
DOMAIN = 'delightio.mailgun.org'
MAILING_LIST = "users@#{DOMAIN}"

mailgun = Mailgun(api_key: KEY, domain: DOMAIN)
members = (mailgun.list_members MAILING_LIST).list(limit:1000)
addresses = members.map {|m| m["address"]}
puts "Got #{addresses.count} email addresses from #{MAILING_LIST}"
CSV.open(ARGV.shift, "w") do |csv|
	addresses.each do |address|
		csv << [address]
	end
end