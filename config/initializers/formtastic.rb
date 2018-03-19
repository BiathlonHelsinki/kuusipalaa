require 'formtastic_autocomplete'
# -*- encoding : utf-8 -*-
Formtastic::FormBuilder.priority_countries = ["Finland"]
Formtastic::FormBuilder.action_class_finder = Formtastic::ActionClassFinder
Formtastic::FormBuilder.input_class_finder = Formtastic::InputClassFinder

module Formtastic
  module Inputs
    class RadioInput
      def choice_html(choice)        
        template.content_tag(:label,
          builder.radio_button(input_name, choice_value(choice), input_html_options.merge(choice_html_options(choice)).merge(:required => false)) << 
          choice_label(choice),
          label_html_options.merge(:for => choice_input_dom_id(choice), :class => "radio")
        )
      end
    end
  end
end