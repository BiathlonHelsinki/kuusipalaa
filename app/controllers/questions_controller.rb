class QuestionsController < ApplicationController

  before_action :authenticate_user!
  
  def contribute_translation
    @question = Question.friendly.find(params[:id])
  end

  def create
    @page = Page.friendly.find(params[:page_id])
    @question = Question.new(question_params)
    @page.questions << @question
    if @question.save
      flash[:notice] = t(:your_question_has_been_asked)
    else
      flash[:error] =  @question.errors.messages.join(', ')
    end
    redirect_to @page
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
    params.require(:question).permit(:slug, :era_id, :contributor_type, :contributor_id, :page_id, translations_attributes: [:question, :id, :locale, :_destroy],
          answers_attributes: [:id,
                                translations_attributes: [:body, :id, :locale, :contributor_type, :contributor_id, :_destroy]
                              ])
  end

end