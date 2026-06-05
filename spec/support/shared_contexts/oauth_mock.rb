# frozen_string_literal: true

RSpec.shared_context 'oauth mock', shared_context: :metadata do
  before do
    OmniAuth.config.test_mode = true

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: 'google_oauth2',
      uid: '123456789',
      info: {
        name: 'Test User',
        email: 'testuser@example.com',
        first_name: 'Test',
        last_name: 'User',
        image: 'https://example.com/avatar.jpg'
      },
      credentials: {
        token: 'mock_token',
        refresh_token: 'mock_refresh_token',
        expires_at: Time.now.to_i + 3600
      }
    })
  end

  after do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.test_mode = false
  end
end
