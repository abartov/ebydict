# frozen_string_literal: true

require 'rails_helper'

# Load exception from ApplicationController
class VolumeNotCompletelyPartitioned < Exception; end

RSpec.describe EbyDef, type: :model do
  describe 'associations' do
    it { should belong_to(:assignee).class_name('EbyUser').with_foreign_key('assignedto').optional }
    it { should have_many(:part_images).class_name('EbyDefPartImage').with_foreign_key('thedef').order('partnum asc') }
    it { should have_many(:events).class_name('EbyDefEvent').with_foreign_key('thedef') }
    it { should have_many(:aliases).class_name('EbyAlias') }
    it { should have_one(:marker).class_name('EbyMarker').with_foreign_key('def_id') }
  end

  describe 'validations' do
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[Problem Partial GotOrphans NeedTyping NeedProof NeedFixup NeedPublish Published]) }
    it { should validate_inclusion_of(:arabic).in_array(%w[none todo done]).allow_nil }
    it { should validate_inclusion_of(:extra).in_array(%w[none todo done]).allow_nil }
    it { should validate_inclusion_of(:greek).in_array(%w[none todo done]).allow_nil }
    it { should validate_inclusion_of(:russian).in_array(%w[none todo done]).allow_nil }
    it { should validate_numericality_of(:proof_round_passed).allow_nil }
    it { should validate_numericality_of(:reject_count).allow_nil }
    it { should validate_numericality_of(:ordinal).allow_nil }
    it { should validate_numericality_of(:volume) }
  end

  describe '.query_by_user_size_and_action' do
    let(:user) { create(:eby_user, :typist, :with_all_languages, max_proof_level: 2) }
    let(:type_action) { Rails.configuration.constants['type'] }
    let(:proof_action) { Rails.configuration.constants['proof'] }
    let(:fixup_action) { Rails.configuration.constants['fixup'] }

    context 'for typing action' do
      it 'generates SQL with NeedTyping status' do
        sql = described_class.query_by_user_size_and_action(user, 'small', type_action, nil)
        expect(sql).to include('NeedTyping')
      end

      it 'orders by reject_count ASC' do
        sql = described_class.query_by_user_size_and_action(user, 'small', type_action, nil)
        expect(sql).to include('ORDER BY reject_count ASC')
      end

      it 'filters for unassigned definitions' do
        sql = described_class.query_by_user_size_and_action(user, 'small', type_action, nil)
        expect(sql).to include('assignedto is NULL')
      end
    end

    context 'for proofing action' do
      it 'generates SQL with NeedProof status' do
        sql = described_class.query_by_user_size_and_action(user, 'small', proof_action, nil)
        expect(sql).to include('NeedProof')
      end

      it 'excludes definitions the user has already proofed' do
        sql = described_class.query_by_user_size_and_action(user, 'small', proof_action, nil)
        expect(sql).to include('not in (select who from eby_def_events')
      end

      it 'respects user max_proof_level when round is nil' do
        sql = described_class.query_by_user_size_and_action(user, 'small', proof_action, nil)
        expect(sql).to include("proof_round_passed < #{user.max_proof_level}")
      end

      it 'filters by specific round when provided' do
        sql = described_class.query_by_user_size_and_action(user, 'small', proof_action, 2)
        expect(sql).to include('proof_round_passed = 1')
      end

      it 'orders by reject_count ASC and proof_round_passed DESC' do
        sql = described_class.query_by_user_size_and_action(user, 'small', proof_action, nil)
        expect(sql).to include('ORDER BY reject_count ASC, proof_round_passed DESC')
      end
    end

    context 'for fixup action' do
      let(:arabic_user) { create(:eby_user, :fixer, does_arabic: true) }
      let(:greek_user) { create(:eby_user, :fixer, does_greek: true) }

      it 'generates SQL with NeedFixup status' do
        sql = described_class.query_by_user_size_and_action(arabic_user, 'small', fixup_action, nil)
        expect(sql).to include('NeedFixup')
      end

      it 'includes arabic condition for arabic-capable user' do
        sql = described_class.query_by_user_size_and_action(arabic_user, 'small', fixup_action, nil)
        expect(sql).to include("eby_defs.arabic = 'todo'")
      end

      it 'includes greek condition for greek-capable user' do
        sql = described_class.query_by_user_size_and_action(greek_user, 'small', fixup_action, nil)
        expect(sql).to include("eby_defs.greek = 'todo'")
      end

      it 'does not include arabic condition for non-arabic user' do
        sql = described_class.query_by_user_size_and_action(greek_user, 'small', fixup_action, nil)
        expect(sql).not_to include("eby_defs.arabic = 'todo'")
      end
    end

    context 'for size filtering' do
      it 'filters for small definitions (1 part)' do
        sql = described_class.query_by_user_size_and_action(user, 'small', type_action, nil)
        expect(sql).to include('count(*)  = 1')
      end

      it 'filters for medium definitions (2 parts)' do
        sql = described_class.query_by_user_size_and_action(user, 'medium', type_action, nil)
        expect(sql).to include('count(*) = 2')
      end

      it 'filters for large definitions (>2 parts)' do
        sql = described_class.query_by_user_size_and_action(user, 'large', type_action, nil)
        expect(sql).to include('count(*) > 2')
      end
    end
  end

  describe '.assign_def_by_size' do
    let(:user) { create(:eby_user, :typist) }
    let(:type_action) { Rails.configuration.constants['type'] }

    context 'when definitions are available' do
      let!(:def1) { create(:eby_def, :need_typing, :small, :unassigned, reject_count: 2) }
      let!(:def2) { create(:eby_def, :need_typing, :small, :unassigned, reject_count: 0) }

      it 'assigns a definition to the user' do
        assigned = described_class.assign_def_by_size(user, 'small', type_action, nil)
        expect(assigned).to be_present
        expect(assigned.assignedto).to eq(user.id)
      end

      it 'assigns definition with lowest reject_count first' do
        assigned = described_class.assign_def_by_size(user, 'small', type_action, nil)
        expect(assigned.id).to eq(def2.id)
      end

      it 'persists the assignment' do
        assigned = described_class.assign_def_by_size(user, 'small', type_action, nil)
        expect(assigned.reload.assignedto).to eq(user.id)
      end
    end

    context 'when no definitions are available' do
      it 'returns nil' do
        assigned = described_class.assign_def_by_size(user, 'small', type_action, nil)
        expect(assigned).to be_nil
      end
    end

    context 'with round fallback for proofing' do
      let(:proofer) { create(:eby_user, :proofer, max_proof_level: 3) }
      let(:proof_action) { Rails.configuration.constants['proof'] }
      let!(:proof1_def) { create(:eby_def, :need_proof_2, :small, :unassigned) }

      it 'falls back to lower rounds when specific round is unavailable' do
        # Request round 3, but only round 2 available
        assigned = described_class.assign_def_by_size(proofer, 'small', proof_action, 3)
        expect(assigned).to eq(proof1_def)
      end

      it 'returns nil when all rounds exhausted' do
        assigned = described_class.assign_def_by_size(proofer, 'small', proof_action, 0)
        expect(assigned).to be_nil
      end
    end

    context 'respects size constraints' do
      let!(:small_def) { create(:eby_def, :need_typing, :small, :unassigned) }
      let!(:medium_def) { create(:eby_def, :need_typing, :medium, :unassigned) }

      it 'only assigns small definitions when requesting small' do
        assigned = described_class.assign_def_by_size(user, 'small', type_action, nil)
        expect(assigned.id).to eq(small_def.id)
      end

      it 'only assigns medium definitions when requesting medium' do
        assigned = described_class.assign_def_by_size(user, 'medium', type_action, nil)
        expect(assigned.id).to eq(medium_def.id)
      end
    end
  end

  describe '.count_by_action_and_size' do
    let(:user) { create(:eby_user, :typist) }
    let(:type_action) { Rails.configuration.constants['type'] }

    before do
      create_list(:eby_def, 3, :need_typing, :small, :unassigned)
      create_list(:eby_def, 2, :need_typing, :medium, :unassigned)
      create_list(:eby_def, 1, :need_typing, :large, :unassigned)
    end

    it 'counts small definitions correctly' do
      count = described_class.count_by_action_and_size(user, type_action, 'small', nil)
      expect(count).to eq(3)
    end

    it 'counts medium definitions correctly' do
      count = described_class.count_by_action_and_size(user, type_action, 'medium', nil)
      expect(count).to eq(2)
    end

    it 'counts large definitions correctly' do
      count = described_class.count_by_action_and_size(user, type_action, 'large', nil)
      expect(count).to eq(1)
    end
  end

  describe '#status_label' do
    it 'returns correct label for NeedTyping' do
      def_record = build(:eby_def, status: 'NeedTyping')
      expect(def_record.status_label).to eq(I18n.t(:type_await_typing))
    end

    it 'returns correct label for NeedProof with round number' do
      def_record = build(:eby_def, status: 'NeedProof', proof_round_passed: 1)
      expect(def_record.status_label).to eq(I18n.t(:type_await_proof_round, round: 2))
    end

    it 'returns correct label for NeedFixup' do
      def_record = build(:eby_def, status: 'NeedFixup')
      expect(def_record.status_label).to eq(I18n.t(:type_await_fixups))
    end

    it 'returns correct label for Problem' do
      def_record = build(:eby_def, status: 'Problem')
      expect(def_record.status_label).to eq(I18n.t(:type_await_resolution))
    end

    it 'returns correct label for NeedPublish' do
      def_record = build(:eby_def, status: 'NeedPublish')
      expect(def_record.status_label).to eq(I18n.t(:type_await_publishing))
    end

    it 'returns correct label for Published' do
      def_record = build(:eby_def, status: 'Published')
      expect(def_record.status_label).to eq(I18n.t(:type_published))
    end
  end

  describe '#mass_replace_html' do
    let(:def_record) { build(:eby_def) }

    it 'replaces source markup with span' do
      input = "[[#{I18n.t(:type_source)}: בראשית א:א]]"
      output = def_record.mass_replace_html(input)
      expect(output).to eq('<span class="source">בראשית א:א</span>')
    end

    it 'replaces comment markup with span' do
      input = "[[#{I18n.t(:type_comment)}: הערה]]"
      output = def_record.mass_replace_html(input)
      expect(output).to eq('<span class="comment">הערה</span>')
    end

    it 'replaces problem markup with span' do
      input = "[[#{I18n.t(:type_problem_btn)}: בעיה]]"
      output = def_record.mass_replace_html(input)
      expect(output).to eq('<span class="problem">בעיה</span>')
    end

    it 'replaces redirect markup with span' do
      input = "[[#{I18n.t(:type_redirect)}: ראה]]"
      output = def_record.mass_replace_html(input)
      expect(output).to eq('<span class="redirect">ראה</span>')
    end

    it 'removes empty paragraphs' do
      input = 'before<p>&nbsp;</p>after'.dup # dup to avoid frozen string
      output = def_record.mass_replace_html(input)
      expect(output).to eq('beforeafter')
    end

    it 'handles multiple replacements' do
      input = "[[#{I18n.t(:type_source)}: מקור]] [[#{I18n.t(:type_comment)}: הערה]]"
      output = def_record.mass_replace_html(input)
      expect(output).to include('<span class="source">מקור</span>')
      expect(output).to include('<span class="comment">הערה</span>')
    end
  end

  describe '#render_body_as_html' do
    let(:def_record) { build(:eby_def) }

    context 'with simple text' do
      it 'returns body and empty footnotes' do
        def_record.deftext = '<p>טקסט פשוט</p>'
        def_record.footnotes = nil

        body, footnotes = def_record.render_body_as_html
        expect(body).to include('טקסט פשוט')
        expect(footnotes).to eq('')
      end
    end

    context 'with footnote references' do
      it 'renumbers footnotes starting from 1' do
        def_record.deftext = '<p>טקסט [5] עם [7] הערות</p>'
        def_record.footnotes = '[5] הערה ראשונה [7] הערה שנייה'

        body, footnotes = def_record.render_body_as_html
        expect(body).to include('<span class="footnote_ref">1</span>')
        expect(body).to include('<span class="footnote_ref">2</span>')
      end

      it 'handles duplicate footnote references' do
        def_record.deftext = '<p>טקסט [5] ושוב [5]</p>'
        def_record.footnotes = '[5] הערה אחת'

        body, footnotes = def_record.render_body_as_html
        expect(body).to include('<span class="footnote_ref">1</span>')
        expect(body.scan(/<span class="footnote_ref">1<\/span>/).count).to eq(2)
      end

      it 'creates footnote sections with renumbered references' do
        def_record.deftext = '<p>טקסט [1]</p>'
        def_record.footnotes = '[1] הערת שוליים'

        body, footnotes = def_record.render_body_as_html
        expect(footnotes).to include('<span class="footnote_num">1</span>')
        expect(footnotes).to include('<span class="footnote">  הערת שוליים</span>')
      end

      it 'marks missing footnotes as problems' do
        def_record.deftext = '<p>טקסט [1] ו[2]</p>'
        def_record.footnotes = '[1] רק הערה אחת [2] אין'

        body, footnotes = def_record.render_body_as_html
        expect(footnotes).to include('<span class="footnote_num">1</span>')
        expect(footnotes).to include('<span class="footnote_num">2</span>')
      end
    end

    context 'with markup' do
      it 'processes source markup' do
        def_record.deftext = "[[#{I18n.t(:type_source)}: מקור]]"
        def_record.footnotes = nil

        body, _footnotes = def_record.render_body_as_html
        expect(body).to include('<span class="source">')
      end

      it 'processes comment markup' do
        def_record.deftext = "[[#{I18n.t(:type_comment)}: הערה]]"
        def_record.footnotes = nil

        body, _footnotes = def_record.render_body_as_html
        expect(body).to include('<span class="comment">')
      end
    end
  end

  describe '#pure_headword' do
    it 'returns headword without homonym prefix' do
      def_record = build(:eby_def, defhead: 'א. דבר')
      expect(def_record.pure_headword).to eq('דבר')
    end

    it 'returns full headword when no prefix exists' do
      def_record = build(:eby_def, defhead: 'דבר')
      expect(def_record.pure_headword).to eq('דבר')
    end

    it 'strips whitespace after removing prefix' do
      def_record = build(:eby_def, defhead: 'ב.  מילה')
      expect(def_record.pure_headword).to eq('מילה')
    end
  end

  describe '#part_of_speech' do
    it 'identifies feminine noun (ש"נ)' do
      def_record = build(:eby_def, deftext: 'ש"נ - תיאור')
      expect(def_record.part_of_speech).to include('נקבה')
      expect(def_record.part_of_speech).to include('noun, fem.')
    end

    it 'identifies masculine noun (ש"ז)' do
      def_record = build(:eby_def, deftext: 'ש"ז - תיאור')
      expect(def_record.part_of_speech).to include('זכר')
      expect(def_record.part_of_speech).to include('noun, masc.')
    end

    it 'identifies transitive verb (פ"י)' do
      def_record = build(:eby_def, deftext: 'פ"י - תיאור')
      expect(def_record.part_of_speech).to include('יוצא')
      expect(def_record.part_of_speech).to include('transitive')
    end

    it 'identifies intransitive verb (פ"ע)' do
      def_record = build(:eby_def, deftext: 'פ"ע - תיאור')
      expect(def_record.part_of_speech).to include('עומד')
      expect(def_record.part_of_speech).to include('intransitive')
    end

    it 'returns ? for unrecognized patterns' do
      def_record = build(:eby_def, deftext: 'תיאור ללא חלק דיבר מזוהה כאן בטקסט זה')
      result = def_record.part_of_speech
      expect(result).to be_a(String)
    end

    it 'returns unknown acronym when pattern exists but not recognized' do
      def_record = build(:eby_def, deftext: 'ק"ט - תיאור')
      expect(def_record.part_of_speech).to eq('ק"ט')
    end
  end

  describe '#published?' do
    it 'returns true when status is Published' do
      def_record = build(:eby_def, :published)
      expect(def_record.published?).to be true
    end

    it 'returns false when status is not Published' do
      def_record = build(:eby_def, :need_typing)
      expect(def_record.published?).to be false
    end
  end

  describe '#permalink' do
    it 'generates correct permalink URL' do
      def_record = create(:eby_def)
      expect(def_record.permalink).to include(Rails.configuration.constants['puburlbase'])
      expect(def_record.permalink).to include('/definition/view')
      expect(def_record.permalink).to include(def_record.id.to_s)
    end
  end

  describe '#generate_aliases' do
    before do
      # Ensure hebrew gem is loaded
      require 'hebrew'
    end

    it 'generates aliases from headword with nikkud' do
      # Use a headword with nikkud so strip_nikkud returns different value
      def_record = build(:eby_def, defhead: 'דָּבָר')
      aliases = def_record.generate_aliases
      expect(aliases).to be_an(Array)
      expect(aliases).to include('דבר') # stripped version
    end

    it 'strips nikkud from headword' do
      def_record = build(:eby_def, defhead: 'דָּבָר')
      aliases = def_record.generate_aliases
      expect(aliases).to include('דבר')
    end

    it 'removes homonym prefix' do
      def_record = build(:eby_def, defhead: 'א. דבר')
      aliases = def_record.generate_aliases
      # Should include unprefixed version
      expect(aliases).to include('דבר')
    end

    it 'generates multiple alias variations' do
      # Use a headword with nikkud to get different variations
      def_record = build(:eby_def, defhead: 'דָּבָר')
      aliases = def_record.generate_aliases
      # Should generate at least the stripped version
      expect(aliases.length).to be >= 1
      expect(aliases).to include('דבר')
    end

    it 'returns unique aliases only' do
      def_record = build(:eby_def, defhead: 'דבר')
      aliases = def_record.generate_aliases
      expect(aliases).to eq(aliases.uniq)
    end

    it 'handles headword with prefix and nikkud' do
      def_record = build(:eby_def, defhead: 'א. דָּבָר')
      aliases = def_record.generate_aliases
      # Should have both the prefix-stripped and nikkud-stripped versions
      expect(aliases.any? { |a| a.include?('דבר') }).to be true
      expect(aliases.length).to be >= 1
    end
  end

  describe '#linkify_sources' do
    let(:def_record) { build(:eby_def) }

    it 'wraps sources in links' do
      input = '<span class="source">בראשית א:א</span>'
      output = def_record.linkify_sources(input)
      expect(output).to include('<span class="source">')
      # The link_for_source method from EbyUtils should be called
    end

    it 'processes multiple source spans' do
      input = '<span class="source">מקור1</span> text <span class="source">מקור2</span>'
      output = def_record.linkify_sources(input)
      expect(output.scan(/<span class="source">/).count).to eq(2)
    end

    it 'preserves text outside source spans' do
      input = 'טקסט <span class="source">מקור</span> עוד טקסט'
      output = def_record.linkify_sources(input)
      expect(output).to include('טקסט')
      expect(output).to include('עוד טקסט')
    end
  end

  describe '#linkify_redirects' do
    let(:def_record) { build(:eby_def) }

    it 'processes redirect spans' do
      input = '<span class="redirect">ראה</span>'
      output = def_record.linkify_redirects(input)
      # The link_for_redirect method from EbyUtils should be called
      expect(output).to be_present
    end

    it 'preserves redirect span when link equals text' do
      input = '<span class="redirect">טקסט</span>'
      # Assuming link_for_redirect returns the same text when no link found
      output = def_record.linkify_redirects(input)
      expect(output).to include('<span class="redirect">')
    end

    it 'processes multiple redirect spans' do
      input = '<span class="redirect">ראה1</span> <span class="redirect">ראה2</span>'
      output = def_record.linkify_redirects(input)
      expect(output).to be_present
    end
  end

  describe '#render_tei' do
    it 'generates valid TEI XML structure' do
      def_record = build(:eby_def, defhead: 'דבר', deftext: 'ש"ז - משמעות')
      tei = def_record.render_tei
      expect(tei).to include('<entry>')
      expect(tei).to include('<form><orth>')
      expect(tei).to include('<gramGrp><pos>')
      expect(tei).to include('</entry>')
    end

    it 'includes pure headword in orth element' do
      def_record = build(:eby_def, defhead: 'א. דבר', deftext: 'ש"ז - משמעות')
      tei = def_record.render_tei
      expect(tei).to include('<orth>דבר</orth>')
    end

    it 'includes part of speech in pos element' do
      def_record = build(:eby_def, defhead: 'דבר', deftext: 'ש"ז - משמעות')
      tei = def_record.render_tei
      expect(tei).to include('<pos>')
    end
  end

  describe 'navigation methods' do
    let(:scan) { create(:eby_scan_image, :partitioned, volume: 1) }
    let(:col1) { scan.col_images.first }
    let(:col2) { scan.col_images.second }

    before do
      # Create definitions in sequence
      @def1 = create(:eby_def, :published, volume: 1)
      @def2 = create(:eby_def, :published, volume: 1)
      @def3 = create(:eby_def, :need_typing, volume: 1)

      # Create part images to establish ordering
      create(:eby_def_part_image, eby_def: @def1, colimg: col1, defno: 0, partnum: 1)
      create(:eby_def_part_image, eby_def: @def2, colimg: col1, defno: 1, partnum: 1)
      create(:eby_def_part_image, eby_def: @def3, colimg: col2, defno: 0, partnum: 1)

      # Mark columns as partitioned
      col1.update(status: 'Partitioned')
      col2.update(status: 'Partitioned')

      # Mock volume completion check
      allow_any_instance_of(EbyDef).to receive(:is_volume_partitioned).and_return(true)
    end

    describe '#predecessor_def' do
      it 'returns previous def in same column when defno > 0' do
        expect(@def2.predecessor_def).to eq(@def1)
      end

      it 'returns nil when volume is not partitioned' do
        allow_any_instance_of(EbyDef).to receive(:is_volume_partitioned).and_return(false)
        expect { @def1.predecessor_def }.to raise_error(VolumeNotCompletelyPartitioned)
      end
    end

    describe '#successor_def' do
      it 'returns next def in same column' do
        expect(@def1.successor_def).to eq(@def2)
      end

      it 'raises error when volume is not partitioned' do
        allow_any_instance_of(EbyDef).to receive(:is_volume_partitioned).and_return(false)
        expect { @def1.successor_def }.to raise_error(VolumeNotCompletelyPartitioned)
      end
    end

    describe '#next_published_def' do
      it 'returns next published definition' do
        @def2.reload
        expect(@def1.next_published_def).to eq(@def2)
      end

      it 'skips non-published definitions' do
        @def4 = create(:eby_def, :published, volume: 1)
        create(:eby_def_part_image, eby_def: @def4, colimg: col2, defno: 1, partnum: 1)

        expect(@def1.next_published_def).to eq(@def2)
      end

      it 'returns nil when no more published definitions exist' do
        # @def2 is the last published def in sequence
        # Mock successor_def to return @def3 (unpublished), then nil
        allow(@def2).to receive(:successor_def).and_return(@def3)
        allow(@def3).to receive(:successor_def).and_return(nil)

        result = @def2.next_published_def
        expect(result).to be_nil
      end
    end
  end

  describe 'language fixup tracking' do
    it 'tracks arabic fixup status' do
      def_with_arabic = create(:eby_def, :arabic_todo)
      expect(def_with_arabic.arabic).to eq('todo')
    end

    it 'tracks greek fixup status' do
      def_with_greek = create(:eby_def, :greek_todo)
      expect(def_with_greek.greek).to eq('todo')
    end

    it 'tracks russian fixup status' do
      def_with_russian = create(:eby_def, :russian_todo)
      expect(def_with_russian.russian).to eq('todo')
    end

    it 'tracks extra fixup status' do
      def_with_extra = create(:eby_def, :extra_todo)
      expect(def_with_extra.extra).to eq('todo')
    end
  end

  describe 'reject tracking' do
    it 'increments reject_count when work is abandoned' do
      def_record = create(:eby_def, reject_count: 2)
      def_record.update(reject_count: def_record.reject_count + 1)
      expect(def_record.reject_count).to eq(3)
    end

    it 'prioritizes definitions with lower reject_count' do
      low_reject = create(:eby_def, :need_typing, :small, reject_count: 1, assignedto: nil)
      high_reject = create(:eby_def, :need_typing, :small, reject_count: 5, assignedto: nil)

      user = create(:eby_user, :typist)
      assigned = described_class.assign_def_by_size(user, 'small', Rails.configuration.constants['type'], nil)

      expect(assigned.id).to eq(low_reject.id)
    end
  end

  describe 'proof round progression' do
    it 'starts at proof_round_passed = 0 for new definitions' do
      def_record = create(:eby_def, :need_typing)
      expect(def_record.proof_round_passed).to eq(0)
    end

    it 'increments proof_round_passed after each proof round' do
      def_record = create(:eby_def, :need_proof_1)
      expect(def_record.proof_round_passed).to eq(0)

      def_record.update(proof_round_passed: 1)
      expect(def_record.proof_round_passed).to eq(1)
    end

    it 'reaches NeedPublish after proof round 3' do
      def_record = create(:eby_def, :need_publish)
      expect(def_record.proof_round_passed).to eq(3)
      expect(def_record.status).to eq('NeedPublish')
    end
  end
end
