class Ability
  include CanCan::Ability

  def initialize(user)
    # user ||= User.new
    can :read, Page, only_stakeholders: false
    can :read, Post, only_stakeholders: false
    cannot :read, Bankstatement
    return unless user.present?
    cannot :manage, Post
    cannot :read, Page, only_stakeholders: true
    cannot :read, Post, only_stakeholders: true
    can :read, Page, only_stakeholders: false
    can :read, Post, only_stakeholders: false
    can :manage, Idea, proposer_type: 'User', proposer_id: user.id
    can :manage, Idea, proposer_type: 'Group' if  user.members.where("access_level >= 10" ).map(&:source_id).include?(:proposer_id)
    can :manage, Event, idea: {proposer_type: 'User', proposer_id: user.id}
    can :manage, Nfc, user_id: user.id
    can :manage, Event do |event|
      event.idea.proposer_type == 'Group' &&
        user.members.where("access_level >= 10" ).map(&:source_id).include?(event.idea.proposer_id) 
    end
    can :manage, Instance do |instance|
      instance.responsible_people.include?(user)
    end
    can :read, Stake, bookedby_id: user.id
   # can :read, :all
    can :manage, User, id: user.id

    # cannot :manage, Credit

    # cannot :manage, Email
    # cannot :manage, Proposalstatus
    can :create, Comment
    # can :manage, Rsvp, user_id: user.id
    can :manage, Comment, :user_id => user.id
    if user.has_role? :stakeholder
      can :manage, Meeting
      can :manage, Post, only_stakeholders: true
      can :manage, User, id: user.id
      can :manage, Comment
      can :manage, Nfc, user_id: user.id
      can :read, Stake, bookedby_id: user.id
      can :read, Page
      can :read, Bankstatement
      can :manage, Emailannouncement  do |ea|
        ea.announcer_type == 'Group' &&
          user.members.where("access_level >= 10" ).map(&:source_id).include?(ea.announcer_id) 
      end
      can :manage, Emailannouncement, announcer_type: 'User', announcer_id: user.id
      can :manage, Page, only_stakeholders: true
    end 

    if user.has_role? :admin
      if user.is_a?(User)
        can :manage, Idea
        can :manage, Stake
        can :manage, Question
        can :manage, Answer
        can :manage, User, id: user.id 
        can :manage, Page
        can :manage, Post
        can :manage, Bankstatement
        # can :manage, Credit
        # can :manage, Email
        can :manage, Comment
        can :manage, Nfc
        can :manage, Event
        can :manage, Instance
        # can :manage, Proposalstatus
      end
    end

 
  end
end
