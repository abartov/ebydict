# frozen_string_literal: true

RSpec.shared_examples 'requires authentication' do
  context 'when user is not logged in' do
    before do
      session[:user_id] = nil
    end

    it 'redirects to login page' do
      subject
      expect(response).to redirect_to(login_path)
    end

    it 'sets a flash message' do
      subject
      expect(flash[:error]).to be_present
    end
  end
end
