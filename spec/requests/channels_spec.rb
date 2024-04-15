require "rails_helper"

RSpec.describe ChannelsController, type: :request do
  # before do
  #   WebMock.stub_request(:post, 'https://slack.com/api/auth.test').to_return(status: 200)
  # end
  # describe "POST channels#create" do
  #   it "should should call slack" do
  #     allow(controller).to receive(:verify_webhook_signature).and_return(true)
  #     channel_params = {
  #       user_id: '12345',
  #       channel_id: '6789',
  #       channel_name: 'fun-times',
  #       current_channel_name: 'general'
  #     }
  #     post '/channels', params: channel_params.to_json, headers: { "Content-Type": "application/json" }
  #     request = double
  #     # request.stub!(:verify!).and_return(true)
  #     allow(::Slack::Events::Request).to_receive(:new).and_return(request)
  #     allow(request).to receive(:verify!).and_return(true)
  #     binding.pry
  #     expect(response).to have_http_status(:forbidden)
  #   end
  # end
end
