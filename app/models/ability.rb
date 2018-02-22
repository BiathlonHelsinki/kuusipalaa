class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.has_role? :admin
      if user.is_a?(User)
        can :manage, Idea
        can :manage, Stake
       can :manage, User, id: user.id 
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
      can :manage, User, id: user.id
      can :manage, Comment
      can :read, Stake, bookedby_id: user.id

    elsif user.is_a?(User)
      can :manage, Idea, proposer_type: 'User', proposer_id: user.id
      can :manage, Idea, proposer_type: 'Group' if  user.members.where("access_level >= 10" ).map(&:source_id).include?(:proposer_id)
 

      can :read, Stake, bookedby_id: user.id
     # can :read, :all
      can :manage, User, id: user.id
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
