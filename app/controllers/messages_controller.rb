require 'json'

class MessagesController < AuthenticatedController
  def create
    @conversation = (current_counselor || current_user).conversations.find(params[:conversation_id])
    message = ConversationMessageService.send_message(@conversation, current_user, params[:message], params[:session_price], suggestion_list_params)
    if message.persisted?
      redirect_to conversation_path(@conversation)
    else
      render 'conversations/show'
    end
  end

  protected

  def suggestion_list_params
    return nil if !params[:session_invitation_list]
    params.permit(session_invitation_list: [])[:session_invitation_list]
      .select {|suggestion| !suggestion.empty? }
      .map do |suggestion|
        JSON.parse(suggestion)
      end
  end
end
