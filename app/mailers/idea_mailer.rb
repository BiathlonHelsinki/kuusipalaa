class IdeaMailer < ActionMailer::Base
  default from: "info@kuusipalaa.fi"
  default "Message-ID" => lambda {"<#{SecureRandom.uuid}@kuusipalaa.fi>"} 
  def proposal_for_review(email, idea)
    @idea = idea
    mail(to: email,  subject: "#{@idea.name} is ready to be scheduled!")
  end


end
