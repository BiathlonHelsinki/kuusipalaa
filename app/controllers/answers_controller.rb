class AnswersController < ApplicationController


  def create
    @page = Page.friendly.find(params[:page_id])
    @question = @page.questions.find_by(slug: params[:question_id])
    @answer = Answer.new(answer_params)
    @answer.question = @question
    if @answer.save
      flash[:notice] = t(:your_answer_has_been_submitted)
    else
      flash[:error] = @answer.errors.messages.join(', ')
    end
    redirect_to @page
  end

  private

  def answer_params
    params.require(:answer).permit(:id,
                                translations_attributes: [:body, :id, :locale, :contributor_type, :contributor_id, :_destroy]
                              )  
  end

end