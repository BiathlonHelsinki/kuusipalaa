class Admin::QuestionsController < Admin::BaseController
 def create
    @question = Question.new(question_params)
    if @question.save
      flash[:notice] = 'Question saved.'
      redirect_to admin_questions_path
    else
      flash[:error] = "Error saving question: " + @question.errors.full_messages.join(', ')
 

      render template: 'admin/questions/new'
    end
  end
  
  def edit
    @question = Question.friendly.find(params[:id])

  end
  
  def new

    @question = Question.new
    @question.page = Page.friendly.find('questions-and-answers')

  end
  
  def update
    @question = Question.friendly.find(params[:id])
    if @question.update_attributes(question_params)
      flash[:notice] = 'Question details updated.'
      redirect_to admin_questions_path
    else
      flash[:error] = 'Error updating question'
    end
  end
  
  def index
    @questions = Question.all
  end
  
  private
  
  def question_params
    params.require(:question).permit(:slug, :era_id, :user_id, :page_id, translations_attributes: [:question, :id, :locale, :_destroy],
          answers_attributes: [:id,
                                translations_attributes: [:body, :id, :locale, :contributor_type, :contributor_id, :_destroy]
                              ])
  end
  
end