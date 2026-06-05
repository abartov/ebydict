# frozen_string_literal: true

RSpec.shared_examples 'creates audit event' do |event_type, from_status: nil, to_status: nil|
  it "creates an EbyDefEvent with type #{event_type}" do
    expect { subject }.to change(EbyDefEvent, :count).by(1)

    event = EbyDefEvent.last
    expect(event.eventtype).to eq(event_type)
    expect(event.from_status).to eq(from_status) if from_status
    expect(event.to_status).to eq(to_status) if to_status
  end
end

RSpec.shared_examples 'does not create audit event' do
  it 'does not create an EbyDefEvent' do
    expect { subject }.not_to change(EbyDefEvent, :count)
  end
end
