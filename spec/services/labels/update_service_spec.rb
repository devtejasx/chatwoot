require 'rails_helper'

describe Labels::UpdateService do
  let(:account) { create(:account) }
  let(:conversation) { create(:conversation, account: account) }
  let(:label) { create(:label, account: account) }
  let(:contact) { conversation.contact }

  before do
    conversation.label_list.add(label.title)
    conversation.save!

    contact.label_list.add(label.title)
    contact.save!
  end

  describe '#perform' do
    it 'updates associated conversations/contacts labels' do
      expect(conversation.label_list).to eq([label.title])
      expect(contact.label_list).to eq([label.title])

      described_class.new(
        new_label_title: 'updated-label-title',
        old_label_title: label.title,
        account_id: account.id
      ).perform

      expect(conversation.reload.label_list).to eq(['updated-label-title'])
      expect(contact.reload.label_list).to eq(['updated-label-title'])
    end

    it 'keeps the other labels on the conversation' do
      conversation.update!(label_list: [label.title, 'billing'])

      described_class.new(
        new_label_title: 'updated-label-title',
        old_label_title: label.title,
        account_id: account.id
      ).perform

      expect(conversation.reload.label_list).to contain_exactly('billing', 'updated-label-title')
    end

    it 'dispatches a conversation updated event with the label change' do
      allow(Rails.configuration.dispatcher).to receive(:dispatch)

      described_class.new(
        new_label_title: 'updated-label-title',
        old_label_title: label.title,
        account_id: account.id
      ).perform

      expect(Rails.configuration.dispatcher).to have_received(:dispatch).with(
        Conversation::CONVERSATION_UPDATED, kind_of(Time),
        hash_including(conversation: conversation, changed_attributes: hash_including('label_list' => [[label.title], ['updated-label-title']]))
      )
    end
  end
end
