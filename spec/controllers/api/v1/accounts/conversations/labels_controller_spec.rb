require 'rails_helper'

RSpec.describe 'Conversation Label API', type: :request do
  let(:account) { create(:account) }

  describe 'GET /api/v1/accounts/{account.id}/conversations/<id>/labels' do
    let(:conversation) { create(:conversation, account: account) }

    before do
      conversation.update_labels('label1, label2')
    end

    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        get api_v1_account_conversation_labels_url(account_id: account.id, conversation_id: conversation.display_id)
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user with access to the conversation' do
      let(:agent) { create(:user, account: account, role: :agent) }

      before do
        create(:inbox_member, inbox: conversation.inbox, user: agent)
      end

      it 'returns all the labels for the conversation' do
        get api_v1_account_conversation_labels_url(account_id: account.id, conversation_id: conversation.display_id),
            headers: agent.create_new_auth_token,
            as: :json

        expect(response).to have_http_status(:success)
        expect(response.body).to include('label1')
        expect(response.body).to include('label2')
      end
    end
  end

  describe 'POST /api/v1/accounts/{account.id}/conversations/<id>/labels' do
    let(:conversation) { create(:conversation, account: account) }

    before do
      conversation.update_labels('label1, label2')
    end

    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        post api_v1_account_conversation_labels_url(account_id: account.id, conversation_id: conversation.display_id),
             params: { labels: %w[label3 label4] },
             as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user with access to the conversation' do
      let(:agent) { create(:user, account: account, role: :agent) }

      before do
        conversation.update_labels('label1, label2')
        create(:inbox_member, inbox: conversation.inbox, user: agent)
      end

      it 'creates labels for the conversation' do
        post api_v1_account_conversation_labels_url(account_id: account.id, conversation_id: conversation.display_id),
             params: { labels: %w[label3 label4] },
             headers: agent.create_new_auth_token,
             as: :json

        expect(response).to have_http_status(:success)
        expect(response.body).to include('label3')
        expect(response.body).to include('label4')
      end
    end
  end

  describe 'POST /api/v1/accounts/{account.id}/conversations/<id>/labels/add' do
    let(:conversation) { create(:conversation, account: account) }
    let(:add_url) { "/api/v1/accounts/#{account.id}/conversations/#{conversation.display_id}/labels/add" }

    before do
      conversation.update_labels('label1, label2')
    end

    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        post add_url, params: { labels: %w[label3] }, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user with access to the conversation' do
      let(:agent) { create(:user, account: account, role: :agent) }

      before do
        create(:inbox_member, inbox: conversation.inbox, user: agent)
      end

      it 'adds the labels and keeps the existing ones' do
        post add_url, params: { labels: %w[label3] }, headers: agent.create_new_auth_token, as: :json

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['payload']).to contain_exactly('label1', 'label2', 'label3')
        expect(conversation.reload.label_list).to contain_exactly('label1', 'label2', 'label3')
      end
    end
  end

  describe 'POST /api/v1/accounts/{account.id}/conversations/<id>/labels/remove' do
    let(:conversation) { create(:conversation, account: account) }
    let(:remove_url) { "/api/v1/accounts/#{account.id}/conversations/#{conversation.display_id}/labels/remove" }

    before do
      conversation.update_labels('label1, label2, label3')
    end

    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        post remove_url, params: { labels: %w[label1] }, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user with access to the conversation' do
      let(:agent) { create(:user, account: account, role: :agent) }

      before do
        create(:inbox_member, inbox: conversation.inbox, user: agent)
      end

      it 'removes only the given labels' do
        post remove_url, params: { labels: %w[label1 label3] }, headers: agent.create_new_auth_token, as: :json

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['payload']).to eq(['label2'])
        expect(conversation.reload.label_list).to eq(['label2'])
      end

      it 'ignores labels the conversation does not have' do
        post remove_url, params: { labels: %w[unknown] }, headers: agent.create_new_auth_token, as: :json

        expect(response).to have_http_status(:success)
        expect(conversation.reload.label_list).to contain_exactly('label1', 'label2', 'label3')
      end
    end
  end
end
