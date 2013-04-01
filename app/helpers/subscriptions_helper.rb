module SubscriptionsHelper
  def call_to_action(subscription)
    # Depending on the subscription, output different call to action wordings
    "Upgrade to record more user sessions." if subscription.plan != SubscriptionPlans.last
  end

  def upgrade_action(original_plan, new_plan)
    if original_plan > new_plan
      return "Downgrade", "btn btn-warning"
    elsif original_plan < new_plan
      return "Upgrade", "btn btn-success"
    else
      return "Subscribed", nil
    end
  end

  def single_quoted(item)
    "'#{item}'"
  end
end
