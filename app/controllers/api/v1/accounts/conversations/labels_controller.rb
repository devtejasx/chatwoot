class Api::V1::Accounts::Conversations::LabelsController < Api::V1::Accounts::Conversations::BaseController
  include LabelConcern

  # add and remove change only the given labels. The row lock reloads the
  # conversation, so the change applies to the stored list and does not drop
  # labels another writer added since this request loaded the conversation.
  def add
    @conversation.with_lock { @conversation.add_labels(permitted_params[:labels]) }
    @labels = @conversation.label_list
  end

  def remove
    @conversation.with_lock { @conversation.remove_labels(permitted_params[:labels]) }
    @labels = @conversation.label_list
  end

  private

  def model
    @model ||= @conversation
  end

  def permitted_params
    params.permit(:conversation_id, labels: [])
  end
end
