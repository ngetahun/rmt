require 'rails_helper'

RSpec.describe Api::Connect::V4::Subscriptions::ProductsController, type: :request do
  include_context 'version header', 4


  let(:auth_mech) { ActionController::HttpAuthentication::Token }
  let(:auth_header) { { 'HTTP_AUTHORIZATION' => auth_mech.encode_credentials(subscription.token) } }
  let(:headers) { auth_header.merge(version_header) }

  describe '#index' do
    let(:url) { connect_products_url(format: :json) }

    context 'when not authenticated' do
      before { get url, headers: version_header }
      subject { response }

      its(:code) { is_expected.to eq '401' }
    end

    context 'when authenticating with wrong token' do
      before { get url, headers: headers }
      subject { response }

      let(:auth_header) { { 'HTTP_AUTHORIZATION' => auth_mech.encode_credentials('bad_token') } }
      let(:error_reponse) { { type: 'error', error: 'Unknown Registration Code.', localized_error: 'Unknown Registration Code.' } }

      its(:code) { is_expected.to eq '401' }
      its(:body) { is_expected.to eq(error_reponse.to_json) }
    end

    context 'when authenticating with a not activated token' do
      before { get url, headers: headers }
      subject { response }

      let(:subscription) { FactoryGirl.create(:subscription, status: 'NOTACTIVATED') }
      let(:auth_header) { { 'HTTP_AUTHORIZATION' => auth_mech.encode_credentials(subscription.regcode) } }
      let(:error_reponse) do
        {
          type: 'error',
          error: 'Not yet activated Registration Code. Please visit https://scc.suse.com to activate it.',
          localized_error: 'Not yet activated Registration Code. Please visit https://scc.suse.com to activate it.'
        }
      end

      its(:code) { is_expected.to eq '401' }
      its(:body) { is_expected.to eq(error_reponse.to_json) }
    end

    context 'when authenticating with expired token' do
      before { get url, headers: headers }
      subject { response }

      let(:subscription) { FactoryGirl.create(:subscription, :expired) }
      let(:auth_header) { { 'HTTP_AUTHORIZATION' => auth_mech.encode_credentials(subscription.regcode) } }
      let(:error_reponse) do
        {
        }
      end

      pending
    end
  end
end
