module AppsHelper
  def truncate_name name, n=20
    return name if name.length < n
    truncated = name[0..n-1]
    truncated[-3..-1] = "..."
    truncated
  end
end
