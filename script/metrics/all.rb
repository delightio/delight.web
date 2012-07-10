require File.expand_path('config/environment.rb')

LaunchDate = Time.utc(2012,4,28,2,00)
module Scopes
  def after_launch
    where 'created_at >= ?', LaunchDate
  end
  def latest
    order 'created_at DESC'
  end
end

App.extend Scopes
Account.extend Scopes
AppSession.extend Scopes


module AgeFormatter
  def age from=Time.now
    diff = from - self
    return "Just now" if diff==0
    ago_later = if diff > 0 then "ago" else "later" end

    str = ""
    [:weeks, :days, :hours, :minutes, :seconds].each do |time_unit|
      period = 1.send time_unit
      n = Integer diff / period
      str += "#{n.abs}#{time_unit[0]} " if n.abs > 0
      diff -= n * period
    end
    str += ago_later

    str
  end
end
Time.send :include, AgeFormatter

puts 'Signups:'
7.times do |n|
  range = (n+1).days.ago..n.days.ago
  puts "  #{n} days ago: (#{Account.where(:created_at => range).count})"
  Account.where(:created_at => range).each_with_index do |account, index|
    print "#{index.to_s.rjust(3)}.  #{account.name}, #{account.administrator.email}: "
    out = account.apps.map do |app|
      "#{app.name} (#{app.app_sessions.count})"
    end
    puts out.join(", ")
  end
  puts
end
puts

puts 'Most active Apps:'
last_session_ages = {}
now = Time.now
App.after_launch.latest.find_each do |app|
  unless app.app_sessions.recorded.count==0
    last_session = app.app_sessions.recorded.latest.first
    last_session_ages[app.id.to_s] = (now-last_session.created_at).to_i
  end
end
sorted = last_session_ages.sort { |x,y| x.last <=> y.last }
sorted.each do |app_id, age|
  app = App.find app_id
  last_session = app.app_sessions.latest.first
  last_recorded_session = app.app_sessions.recorded.latest.first
  puts "  #{app.name}, App[#{app.id}] #{app.app_sessions.recorded.count} / #{app.app_sessions.count} sessions "+\
       "( #{app.app_sessions.recorded.where(:created_at=>(24.hours.ago..Time.now)).count} / #{app.app_sessions.where(:created_at=>(24.hours.ago..Time.now)).count} in < 24h), "+\
       "avg #{app.app_sessions.recorded.average(:duration).to_i} / #{app.app_sessions.average(:duration).to_i} s, "+\
       "last session: #{last_recorded_session.created_at.age} / #{last_session.created_at.age}"
end
puts

puts "Summary (since launched #{LaunchDate.age}):"
puts "  Accounts: #{Account.after_launch.count}"
puts "  Apps: #{sorted.count}/#{App.after_launch.count}"
puts "  App Sessions: #{AppSession.after_launch.recorded.count} / #{AppSession.after_launch.count}"