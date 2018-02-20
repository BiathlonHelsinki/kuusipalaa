class AddKuusiPalaaEvent < ActiveRecord::Migration[5.1]
  def change
    @event = Event.new(idea: nil, place_id: 2, primary_sponsor: Group.find(1), cost_euros: 0, start_at: Season.first.start_at.midnight, 
          end_at: Season.first.end_at.end_of_day,
         cost_bb: 0, translations: [Event::Translation.new(locale: I18n.locale, name: 'Kuusi Palaa', description: 'Kuusi Palaa general description here')])
    @event.instances << Instance.new(start_at: Season.first.start_at.midnight, event: @event,
          end_at: Season.first.end_at.end_of_day, price_public: 0, price_stakeholders: 0, 
          room_needed: 3, published: true, spent_biathlon: true, allow_multiple_entry: true,  
            custom_bb_fee: 0, allow_others: true, place_id: 2, translations: [Instance::Translation.new(locale: I18n.locale,
             name: 'Kuusi Palaa season 1', description: 'Kuusi Palaa season 1 info here')] )
    @event.save!

  end
end
