class IdeaMailer < ActionMailer::Base
  default from: "info@kuusipalaa.fi"
  
  def proposal_for_review(idea)
    @idea = idea
    if @idea.proposer_type == 'Group'
      @idea.proposer.members.each do |user|
        mail(to: user.email,  subject: "#{@idea.name} is ready to be scheduled!")
      end
    else
      mail(to: @idea.proposer.email,  subject: "#{@idea.name} is ready to be scheduled!")
    end
    
  end


end
