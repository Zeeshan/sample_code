class CoursesController < ApplicationController
  def index
  	@products = []
    @products << Course.showable
    @products << Workshop.alone.are_not_draft
    @products.flatten!
    @products.sort! { |product1,product2| product2.start_time <=> product1.start_time }
  end

  def show
    @course = Course.find(params[:id])
    raise ActiveRecord::RecordNotFound if @course.draft || @course.are_workshops_draft?
    @workshops = @course.not_draft_workshops
  end
end