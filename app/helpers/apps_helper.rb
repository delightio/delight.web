module AppsHelper
  def truncate_name name, n=20
    return name if name.length < n
    truncated = name[0..n-1]
    truncated[-3..-1] = "..."
    truncated
  end

  def progress_bar_class percentage
    if percentage < 70
      return 'bar'
    elsif percentage < 90
      return 'bar bar-warning'
    else
      return 'bar bar-danger'
    end
  end

  def subscription_call_to_action percentage
    percentage = [percentage, 100].min
    if percentage < 70
      "#{pluralize(@subscription.remaining_hours, 'hour')} for next #{pluralize(@subscription.days_till_expired, 'day')}"
    else percentage <= 100
      "#{100-percentage}% left. Upgrade now"
    end
  end
end
