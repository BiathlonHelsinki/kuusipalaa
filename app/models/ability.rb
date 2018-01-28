class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.has_role? :admin
      if user.is_a?(User)
        can :manage, :all
        can :manage, Page
        can :manage, Post
        # can :manage, Credit
        # can :manage, Email
        can :manage, Comment
        # can :manage, Proposalstatus
      end
    elsif user.has_role? :stakeholder
      can :manage, Meeting
      can :manage, Post
      can :manage, Comment
      can :read, Stake, bookedby_id: user.id
    else
      can :read, Stake, bookedby_id: user.id

      # can :read, :all
      can :manage, User, :id => user.id
      cannot :manage, Post
      # cannot :manage, Credit
      cannot :manage, Page
      # cannot :manage, Email
      # cannot :manage, Proposalstatus
      can :create, Comment
      # can :manage, Rsvp, user_id: user.id
      can :manage, Comment, :user_id => user.id
    end
  end
end
