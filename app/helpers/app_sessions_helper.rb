module AppSessionsHelper
  def session_time_in_words(time)
    if time < Time.now
      suffix = ' ago'
    else
      suffix = ''
    end
    return distance_of_time_in_words_to_now(time) + suffix
  end
end
