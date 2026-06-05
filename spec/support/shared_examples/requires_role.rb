# frozen_string_literal: true

RSpec.shared_examples 'requires role' do |required_role|
  context "when user does not have #{required_role} role" do
    let(:unauthorized_user) { create(:eby_user) }

    before do
      session[:user_id] = unauthorized_user.id
    end

    it 'redirects to root path' do
      subject
      expect(response).to redirect_to(root_path)
    end

    it 'sets an error flash message' do
      subject
      expect(flash[:error]).to match(/not authorized|permission/i)
    end
  end
end
