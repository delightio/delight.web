class Float
  def to_time_format
    if self < 1.hours
      Duration.new(self).format("%M:%S")
    else
      Duration.new(self).format("%H:%M:%S")
    end
  end
end
