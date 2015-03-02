class BookingRequestsController < ApplicationController
  before_filter :load_counselor
  layout :no_layout_for_xhr

  def new
    @message = Message.new
  end

  def create
    @message = BookingRequest.make(current_user, @counselor, message_params)
    if @message.persisted?
      back = URI.parse(request.env['HTTP_REFERER'])
      back.fragment = 'booking-request-sent'
      redirect_to(back.to_s)
    else
      render :new
    end
  end

  protected

  def message_params
    params.permit(message: [:content, :trial])[:message]
  end

  def load_counselor
    binding.pry
    @counselor = Counselor.where(url: params[:counselor_id]).first!
  end

  def no_layout_for_xhr
    !request.xhr?
  end
end
