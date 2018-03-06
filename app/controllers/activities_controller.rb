class ActivitiesController < ApplicationController
  
  def index
    @filters = {"description" => ['pledged', 'spent', 'joined', 'linked an ID card', 'edited pledge', 'edited proposal', 'registered/RSVPd', 'withdrew a pledge', 'proposed', 'attended', 'booked the back room', 'commented'].sort}
    if params[:user_id]
      @user = User.friendly.find(params[:user_id])
      @activities = Activity.by_user(@user.id).order(created_at: :desc).page(params[:page]).per(40)
    else
      if !params[:by_string].blank?
        stringsearch = PgSearch.multisearch(params[:by_string])
        @activities = Kaminari.paginate_array(stringsearch.to_a.delete_if{|x| !x.searchable.respond_to?(:activities)}.map{|x| x.searchable.activities}.flatten.uniq.sort_by(&:created_at).reverse).page(params[:page]).per(40)
        # @activities = Activity.search_activity_feed(params[:by_string]).page(params[:page]).per(40)
      else
        @activities = Activity.all.includes(:user, :onetimer, :ethtransaction).order(created_at: :desc).page(params[:page]).per(40)
      end
    end
    set_meta_tags title: t(:activities)
  end
  
end