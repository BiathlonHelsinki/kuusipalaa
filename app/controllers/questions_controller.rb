class QuestionsController < ApplicationController

  before_action :authenticate_user!
  
  def contribute_translation
    @question = Question.friendly.find(params[:id])
  end

  def update
    @question = Question.friendly.find(params[:id])
    if @question.update_attributes(question_params)
      flash[:notice] = 'Question details updated.'
      redirect_to @question.page
    else
      flash[:error] = 'Error updating question: ' + @question.errors.messages.join(', ')
      render template: 'questions/contribute_translation'
    end
  end

  
  private
  
  def question_params
    params.require(:question).permit(:slug, :era_id, :page_id, translations_attributes: [:question, :id, :locale, :_destroy],
          answers_attributes: [:id,
                                translations_attributes: [:body, :id, :locale, :contributor_type, :contributor_id, :_destroy]
                              ])
  end

end