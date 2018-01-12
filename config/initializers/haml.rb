ActiveSupport.on_load(:action_view) do
  Haml::Template.options[:encoding] = 'utf-8'
end