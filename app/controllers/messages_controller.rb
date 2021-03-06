class MessagesController < ApplicationController
	before_action :set_conversation

	def index
		@messages = @conversation.messages
		if @messages.length > 10
			@over_ten = true
			@messages = @messages[-10..-1]
		end
		if params[:m]
			@over_ten = false
			@messages = @conversation.messages
		end
		if @messages.last
			if @messages.last.user_id != current_user.id
				@messages.last.read = true
			end
		end
		@message = @conversation.messages.new
	end

	def new
		@message = @conversation.messages.new
	end
 
	def create
		@message = @conversation.messages.new(message_params)
		if @message.save
			create_notification @conversation, @message
			redirect_to conversation_messages_path(@conversation)
		end
	end

	private
		def set_conversation
			@conversation = Conversation.find(params[:conversation_id])
		end

		def message_params
			params.require(:message).permit(:body, :user_id)
		end

		def create_notification(conversation, message)
			if conversation.recipient_id == current_user.id 
				sender = conversation.recipient_id
				recipient = conversation.sender_id
			else
				sender = conversation.sender_id
				recipient = conversation.recipient_id
			end					
			Notification.create(user_id: recipient,
													sender_id: sender,
													conversation_id: conversation.id,
													identifier: message.id,
													n_type: "message")
		end
end