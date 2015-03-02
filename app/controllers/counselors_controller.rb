class CounselorsController < ApplicationController
  respond_to :html

  def show
    @counselor = Counselor.not_hidden_and_available.find_by_url(params[:id])
    @prev_counselor = @counselor.prev_counselor
    @next_counselor = @counselor.next_counselor
  end

  def index
    @categories = HelpingCategory.ordered_by_priority
    @languages = Language.all

    if !params[:commit] && !params[:language]
    	session[:chosen_categories] = []
      session[:chosen_languages] = []
		else
			category = HelpingCategory.where(name: params[:commit]).first
      language = Language.where(name: params[:language]).first

			if category
				if session[:chosen_categories].include? category.id
					session[:chosen_categories].delete(category.id)
				else
					session[:chosen_categories] << category.id
				end
			end

      if language
        if session[:chosen_languages].include? language.id
          session[:chosen_languages].delete(language.id)
        else
          session[:chosen_languages] << language.id
        end
      end

		end

    @filtered_counselors = Counselor.filter(session[:chosen_categories])
    @filtered_by_language = Counselor.filter_by_language(session[:chosen_languages])

    @filtered_counselors = @filtered_counselors & @filtered_by_language 
    
    @counselors = Counselor.not_hidden_and_available
    @rest_of_counselors = @counselors - @filtered_counselors
  end
end
