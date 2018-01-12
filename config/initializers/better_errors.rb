if Rails.env.development?
  BetterErrors.maximum_variable_inspect_size = 100_000
  BetterErrors.editor='atm://open?url=file://%{file}&line=%{line}' if defined? BetterErrors
  BetterErrors::Middleware.allow_ip! '192.168.11.20'
end
