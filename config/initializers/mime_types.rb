# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone

# register MIME type with Rails
Mime::Type.register "application/x-plist", :plist

# register MIME type with MIME::Type gem
MIME::Types.add(MIME::Type.from_array("application/x-plist", %(plist)))