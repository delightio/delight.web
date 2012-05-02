require File.expand_path('config/environment.rb')

LaunchDate = Time.utc(2012,4,30,2,00).in_time_zone('Hong Kong')
module Scopes
  def after_launch
    where 'created_at >= ?', LaunchDate
  end
  def latest
    order 'created_at DESC'
  end
end
App.extend Scopes

puts "Signups:"
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

puts "Most active Apps:"
sessions_count = {}
App.after_launch.latest.find_each do |app|
  sessions_count[app.id.to_s] = app.app_sessions.count
end
sorted = sessions_count.sort { |x,y| y.last <=> x.last }
no_sessions, sorted = sorted.partition { |a| a.last==0 }
sorted.each do |app_id, count|
  app = App.find app_id
  last_session = app.app_sessions.latest.first
  puts "  #{app.name}, App[#{app.id}] #{count} sessions, "+\
       "last session: #{last_session.created_at}, "+\
       "avg #{app.app_sessions.average(:duration)} s, "+\
       "#{app.app_sessions.recorded.count} recorded, "+\
       "avg #{app.app_sessions.recorded.average(:duration)} s."
end
puts

puts "#{no_sessions.count} apps have no sessions: "
puts no_sessions.map {|s| App.find(s.first).name }.join ', '
