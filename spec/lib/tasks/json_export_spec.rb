# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'dict:json_export rake task' do
  let(:task_name) { 'dict:json_export' }
  let(:output_dir) { Rails.root.join('tmp', 'test_json_export') }

  before(:all) do
    Rails.application.load_tasks
  end

  before(:each) do
    Rake::Task[task_name].reenable
    FileUtils.rm_rf(output_dir)
    # Redirect output directory via stub
    allow(Rails.root).to receive(:join).and_call_original
    allow(Rails.root).to receive(:join).with('public', 'json_export').and_return(output_dir)
  end

  after(:each) do
    FileUtils.rm_rf(output_dir)
    ENV.delete('ALL')
  end

  def run_task
    Rake::Task[task_name].invoke
  end

  def load_json(vol)
    path = output_dir.join("volume_#{vol}.json")
    JSON.parse(File.read(path))
  end

  context 'with published and unpublished defs across volumes' do
    let!(:pub1a) { create(:eby_def, :published, volume: 1, ordinal: 1, defhead: 'אלף', footnotes: 'fn1') }
    let!(:pub1b) { create(:eby_def, :published, volume: 1, ordinal: 2, defhead: 'בית') }
    let!(:unpub) { create(:eby_def, :need_typing, volume: 1, ordinal: 3, defhead: 'גמל') }
    let!(:pub2)  { create(:eby_def, :published, volume: 2, ordinal: 1, defhead: 'דלת') }

    it 'creates one JSON file per volume' do
      run_task
      expect(File.exist?(output_dir.join('volume_1.json'))).to be true
      expect(File.exist?(output_dir.join('volume_2.json'))).to be true
    end

    it 'only includes Published defs' do
      run_task
      entries = load_json(1)
      headwords = entries.map { |e| e['defhead'] }
      expect(headwords).to include('אלף', 'בית')
      expect(headwords).not_to include('גמל')
    end

    it 'outputs defs in ordinal order' do
      run_task
      entries = load_json(1)
      expect(entries.map { |e| e['defhead'] }).to eq(['אלף', 'בית'])
    end

    it 'includes required fields for each entry' do
      run_task
      entry = load_json(1).first
      expect(entry.keys).to include('defhead', 'deftext', 'footnotes', 'updated_at', 'aliases')
    end

    it 'includes footnotes' do
      run_task
      entry = load_json(1).find { |e| e['defhead'] == 'אלף' }
      expect(entry['footnotes']).to eq('fn1')
    end

    it 'includes alias strings' do
      create(:eby_alias, eby_def: pub1a, alias: 'alef')
      create(:eby_alias, eby_def: pub1a, alias: 'aleph')
      run_task
      entry = load_json(1).find { |e| e['defhead'] == 'אלף' }
      expect(entry['aliases']).to contain_exactly('alef', 'aleph')
    end

    it 'includes empty aliases array when no aliases' do
      run_task
      entry = load_json(1).find { |e| e['defhead'] == 'בית' }
      expect(entry['aliases']).to eq([])
    end
  end

  context 'default limit of 50' do
    before do
      55.times { |i| create(:eby_def, :published, volume: 1, ordinal: i + 1) }
    end

    it 'outputs at most 50 defs by default' do
      run_task
      expect(load_json(1).size).to eq(50)
    end

    it 'outputs all defs when ALL=1' do
      ENV['ALL'] = '1'
      run_task
      expect(load_json(1).size).to eq(55)
    end
  end

  context 'empty volume' do
    let!(:pub2) { create(:eby_def, :published, volume: 2, ordinal: 1, defhead: 'דלת') }

    it 'creates an empty JSON array for a volume with no published defs' do
      run_task
      entries = load_json(1)
      expect(entries).to eq([])
    end
  end
end
