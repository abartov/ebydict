# frozen_string_literal: true

RSpec.shared_context 'authenticated user', shared_context: :metadata do
  let(:user) { create(:eby_user) }

  before do
    session[:user_id] = user.id
  end
end

RSpec.shared_context 'authenticated partitioner', shared_context: :metadata do
  let(:partitioner) { create(:eby_user, :partitioner) }

  before do
    session[:user_id] = partitioner.id
  end
end

RSpec.shared_context 'authenticated typist', shared_context: :metadata do
  let(:typist) { create(:eby_user, :typist) }

  before do
    session[:user_id] = typist.id
  end
end

RSpec.shared_context 'authenticated proofer', shared_context: :metadata do
  let(:proofer) { create(:eby_user, :proofer, :proof_level_2) }

  before do
    session[:user_id] = proofer.id
  end
end

RSpec.shared_context 'authenticated fixer', shared_context: :metadata do
  let(:fixer) { create(:eby_user, :fixer) }

  before do
    session[:user_id] = fixer.id
  end
end

RSpec.shared_context 'authenticated publisher', shared_context: :metadata do
  let(:publisher) { create(:eby_user, :publisher) }

  before do
    session[:user_id] = publisher.id
  end
end

RSpec.shared_context 'authenticated admin', shared_context: :metadata do
  let(:admin) { create(:eby_user, :admin) }

  before do
    session[:user_id] = admin.id
  end
end
