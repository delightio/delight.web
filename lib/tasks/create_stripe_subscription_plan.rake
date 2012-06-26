namespace :delight do
  desc "create a unlimited subscription plan in stripe"
  task :create_stripe_plan => :environment do
    puts "Creating Plan"
    puts "\tName: Unlimited Plan"
    puts "\tID: unlimited"
    puts "\tPrice: $500/month"


    require "stripe"
    Stripe.api_key = ENV['STRIPE_SECRET']
    response = Stripe::Plan.create(
      :amount => 500,
      :interval => 'month',
      :name => 'Unlimited Plan',
      :currency => 'usd',
      :id => 'unlimited'
    )

    if response.id = "unlimited"
      puts "DONE"
    else
      puts "Plan Create Failed."
      puts response
    end
  end
end