class Labels::UpdateService
  pattr_initialize [:new_label_title!, :old_label_title!, :account_id!]

  def perform
    tagged_conversations.find_in_batches do |conversation_batch|
      conversation_batch.each do |conversation|
        conversation.update_labels(renamed_labels(conversation))
      end
    end

    tagged_contacts.find_in_batches do |contact_batch|
      contact_batch.each do |contact|
        contact.update_labels(renamed_labels(contact))
      end
    end
  end

  private

  # Assign the list through the setter: editing label_list in place saves the
  # taggings but does not mark label_list as changed, so no update is broadcast
  # and open dashboards drop the label until they reload.
  def renamed_labels(taggable)
    (taggable.label_list - [old_label_title]) | [new_label_title]
  end

  def tagged_conversations
    account.conversations.tagged_with(old_label_title)
  end

  def tagged_contacts
    account.contacts.tagged_with(old_label_title)
  end

  def account
    @account ||= Account.find(account_id)
  end
end
