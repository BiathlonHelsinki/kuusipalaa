class ActivitiesController < ApplicationController
  caches_page :index, :chronological

  def load_filters
    @filters = { "description" => Activity.distinct.pluck(:description).sort }
  end

  def index
    load_filters
    page = if params[:page] =~ /^\d+/
      params[:page]
    else
      1
    end
    a = Activity.includes(:user, :onetimer, :ethtransaction).order(created_at: :desc).offset((100 * page.to_i) - 100).limit(100)
    array = a.group_by(&:description)
    activities = array.each { |y| array[y.first] = y.last.group_by(&:item) }

    hash_activities = {}
    activities.each do |description|
      activities[description.first].each_with_index do |instance, _index|
        next if instance.first.class == NilClass
        hash_activities[instance.last.sort_by(&:created_at).last.created_at.to_i] = { "description" => description.first,
                                                                                      "activities" => instance.last }
      end
    end
    aaa =  Hash[hash_activities.sort_by { |k, _v| k.to_i }.reverse]
    keys = aaa.keys
    aaa.each_with_index do |_timestamped, i|
      next if i == 0
      d = aaa[keys[i]]['description']
      counter = i - 1
      next unless aaa[keys[counter]]['description'] == d
      while aaa[keys[counter]]['description'] == d
        unless aaa[keys[counter]]['deleted']
          aaa[keys[counter]]['activities'].push(aaa[keys[i]]['activities'])
          begin
            aaa[keys[counter]]['activities'].flatten!
          rescue StandardError
            next
          end
          aaa[keys[counter]]['activities'].sort! { |x, y| y.created_at <=> x.created_at }.uniq!
        end
        counter -= 1
      end
      aaa[keys[i]]['deleted'] = 'deleted'
      # aaa.delete(keys[i])  # delete self
    end
    # @activities = aaa.delete_if{|key, value| value['deleted'] }
    @activities = Kaminari.paginate_array([aaa.delete_if { |_key, value| value['deleted'] }], total_count: Activity.count / 100).page(params[:page]).per(1)
    respond_to do |format|
      format.html
      format.json { render(json: @activities) }
    end
    # @activities = a #Kaminari.paginate_array([a]).page(params[:page]).per(100)
  end

  def chronological
    load_filters
    if params[:user_id]
      @user = User.friendly.find(params[:user_id])
      @activities = Activity.by_user(@user.id).order(created_at: :desc).page(params[:page]).per(40)
    elsif params[:by_string].present?
      stringsearch = PgSearch.multisearch(params[:by_string])
      @activities = Kaminari.paginate_array(stringsearch.to_a.delete_if { |x| !x.searchable.respond_to?(:activities) }.map { |x| x.searchable.activities }.flatten.uniq.sort_by(&:created_at).reverse).page(params[:page]).per(40)
        # @activities = Activity.search_activity_feed(params[:by_string]).page(params[:page]).per(40)
    elsif params[:by_description].present?
      descriptionsearch = Activity.where(description: params[:by_description]).order(created_at: :desc)
      @activities = Kaminari.paginate_array(descriptionsearch).page(params[:page]).per(40)
    else
      @activities = Activity.includes(:user, :onetimer, :ethtransaction).order(created_at: :desc).page(params[:page]).per(40)
    end
    set_meta_tags(title: t(:activities))
  end
end
