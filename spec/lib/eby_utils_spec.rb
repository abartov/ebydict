# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EbyUtils do
  # Include the module to test its methods
  include EbyUtils

  describe 'Bible reference detection' do
    describe '#is_bible' do
      it 'recognizes full book names' do
        expect(is_bible('בראשית א ב')).to be true
        expect(is_bible('שמות יב ג')).to be true
        expect(is_bible('תהילים כג א')).to be true
        expect(is_bible('תהלים כג א')).to be true # alternative spelling
        expect(is_bible('משלי ה ט')).to be true
      end

      it 'recognizes abbreviated book names' do
        expect(is_bible('ברא\' א ב')).to be true
        expect(is_bible('שמ\' יב ג')).to be true
        expect(is_bible('תה\' כג א')).to be true
        expect(is_bible('ש"א יז מה')).to be true
        expect(is_bible('ש"ב ח ב')).to be true
      end

      it 'returns false for non-bible text' do
        expect(is_bible('רש"י')).to be false
        expect(is_bible('תוספות')).to be false
        expect(is_bible('רמב"ם')).to be false
        expect(is_bible('random text')).to be false
      end

      it 'handles text with extra whitespace' do
        expect(is_bible('בראשית  א  ב')).to be true
        expect(is_bible('  שמות יב ג  ')).to be true
      end
    end

    describe '#bible_link' do
      it 'generates correct link for Genesis' do
        link = bible_link('בראשית א ב')
        expect(link).to include('wikisource.org')
        # URL is encoded, so check for category tag instead
        expect(link).to match(/קטגוריה|%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94/)
        expect(link).to end_with('א_ב')
      end

      it 'generates correct link for Psalms' do
        link = bible_link('תהילים כג א')
        expect(link).to include('wikisource.org')
        # URL is encoded, so just verify basic structure
        expect(link).to match(/קטגוריה|%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94/)
        expect(link).to end_with('כג_א')
      end

      it 'handles verse ranges by using start verse' do
        link = bible_link('שמות יב ג-ה')
        expect(link).to end_with('יב_ג')

        link2 = bible_link('בראשית א א=ה')  # = is sometimes used for -
        expect(link2).to end_with('א_א')
      end

      it 'handles abbreviated book names' do
        link = bible_link('ברא\' א ב')
        expect(link).to include('wikisource.org')
        expect(link).to end_with('א_ב')
      end

      it 'converts special chapter numbering (יה → טו, יו → טז)' do
        link = bible_link('שמות יה ב')
        expect(link).to include('טו_')  # יה becomes טו

        link2 = bible_link('במדבר יו ג')
        expect(link2).to include('טז_')  # יו becomes טז
      end

      it 'returns empty string for missing book' do
        link = bible_link('invalid book name')
        expect(link).to eq('')
      end

      it 'returns empty string for incomplete reference' do
        link = bible_link('בראשית')  # Missing chapter and verse
        expect(link).to eq('')
      end
    end
  end

  describe 'Talmud reference detection' do
    describe '#is_talmud' do
      it 'returns false (not yet implemented)' do
        expect(is_talmud('ברכות ב א')).to be false
        expect(is_talmud('שבת כא ב')).to be false
      end
    end
  end

  describe '#link_for_source' do
    it 'generates bible link for bible sources' do
      result = link_for_source('בראשית א ב')
      expect(result).to include('<a href=')
      expect(result).to include('בראשית')
      expect(result).to include('wikisource.org')
    end

    it 'strips parentheses from source' do
      result = link_for_source(')בראשית א ב(')
      expect(result).to include('בראשית א ב')
      expect(result).not_to include(')')
      expect(result).not_to include('(')
    end

    it 'returns text as-is for "שם" (ibid)' do
      result = link_for_source('שם ב')
      expect(result).to eq('שם ב')
      expect(result).not_to include('<a')
    end

    it 'returns text as-is for non-bible non-talmud sources' do
      result = link_for_source('רש"י')
      expect(result).to eq('רש"י')
      expect(result).not_to include('<a')
    end
  end

  describe '#link_for_redirect' do
    let!(:published_def) do
      create(:eby_def, :published, :small, defhead: 'מילון')
    end

    it 'creates link for published definition' do
      result = link_for_redirect('מילון')
      expect(result).to include('<a href=')
      expect(result).to include('מילון')
      expect(result).to include('/definition/view/')
    end

    it 'returns text as-is if definition not found' do
      result = link_for_redirect('לא קיים')
      expect(result).to eq('לא קיים')
      expect(result).not_to include('<a')
    end

    it 'returns text as-is if definition not published' do
      unpublished_def = create(:eby_def, :need_typing, :small, defhead: 'טיוטה')
      result = link_for_redirect('טיוטה')
      expect(result).to eq('טיוטה')
      expect(result).not_to include('<a')
    end
  end

  describe '#cleanup_parens' do
    it 'moves parentheses outside source tags' do
      input = '[[מקור: (בראשית א ב)]]'.dup  # dup to avoid frozen string error
      result = cleanup_parens(input)
      expect(result).to eq('([[מקור: בראשית א ב]])')
    end

    it 'handles multiple source tags' do
      input = 'text [[מקור: (שמות ג ד)]] more [[מקור: (דברים ה ו)]]'.dup
      result = cleanup_parens(input)
      expect(result).to include('([[מקור: שמות ג ד]])')
      expect(result).to include('([[מקור: דברים ה ו]])')
    end

    it 'handles extra whitespace in tags' do
      input = '[[מקור:  (במדבר ז ח)]]'.dup
      result = cleanup_parens(input)
      expect(result).to eq('([[מקור: במדבר ז ח]])')
    end

    it 'returns unchanged text if no parentheses in source tags' do
      input = '[[מקור: בראשית א ב]]'
      result = cleanup_parens(input)
      expect(result).to eq('[[מקור: בראשית א ב]]')
    end
  end

  describe '#html_entities_coder' do
    it 'returns an HTMLEntities instance' do
      expect(html_entities_coder).to be_a(HTMLEntities)
    end

    it 'memoizes the instance' do
      first_call = html_entities_coder
      second_call = html_entities_coder
      expect(first_call.object_id).to eq(second_call.object_id)
    end
  end

  describe 'Constants' do
    it 'defines BIBLE_BOOKS hash with book names and numbers' do
      expect(EbyUtils::BIBLE_BOOKS).to be_a(Hash)
      expect(EbyUtils::BIBLE_BOOKS['בראשית']).to eq(1)
      expect(EbyUtils::BIBLE_BOOKS['שמות']).to eq(2)
      expect(EbyUtils::BIBLE_BOOKS['תהילים']).to eq(27)
      expect(EbyUtils::BIBLE_BOOKS['תהלים']).to eq(27)  # alternative
    end

    it 'defines BIBLE_BOOKS with abbreviations' do
      expect(EbyUtils::BIBLE_BOOKS['ברא\'']).to eq(1)
      expect(EbyUtils::BIBLE_BOOKS['שמ\'']).to eq(2)
      expect(EbyUtils::BIBLE_BOOKS['ש"א']).to eq(8)
      expect(EbyUtils::BIBLE_BOOKS['ש"ב']).to eq(9)
    end

    it 'defines BIBLE_LINKS hash with wikisource URLs' do
      expect(EbyUtils::BIBLE_LINKS).to be_a(Hash)
      expect(EbyUtils::BIBLE_LINKS[1]).to include('wikisource.org')
      # URLs are encoded, so just check they're valid URLs
      expect(EbyUtils::BIBLE_LINKS[1]).to match(/https:\/\/he\.wikisource\.org/)
      expect(EbyUtils::BIBLE_LINKS[27]).to match(/https:\/\/he\.wikisource\.org/)
    end

    it 'has matching entries in BIBLE_BOOKS and BIBLE_LINKS' do
      book_numbers = EbyUtils::BIBLE_BOOKS.values.uniq.sort
      link_keys = EbyUtils::BIBLE_LINKS.keys.sort
      expect(book_numbers).to eq(link_keys)
    end

    it 'defines navigation constants' do
      expect(EbyUtils::NEXT).to eq(1)
      expect(EbyUtils::PREV).to eq(-1)
    end
  end

  describe 'Volume methods', :skip => 'Requires complex setup with volumes' do
    # These tests would require extensive setup with volumes, scans, columns, etc.
    # Skipping for now as they're more integration-test level
    # describe '#is_volume_partitioned'
    # describe '#col_from_col'
    # describe '#first_def_for_vol'
    # describe '#last_def_for_vol'
    # describe '#first_def'
    # describe '#makedef'
  end

  describe '#enumerate_vol' do
    # Use a volume number unlikely to collide with other test data.
    # secondpagenum=1000 ensures col_from_col finds no "next scan" when it
    # increments col.pagenum (1) by 1, so the traversal correctly terminates.
    let(:vol) { 999 }
    let(:scan) do
      create(:eby_scan_image, volume: vol, firstpagenum: 1, secondpagenum: 1000, status: 'Partitioned')
    end
    let(:col) do
      create(:eby_column_image, scan: scan, volume: vol, colnum: 1, pagenum: 1, status: 'Partitioned')
    end

    before { col } # triggers lazy scan → col creation before any defs

    def make_def(defhead, defno)
      d = create(:eby_def, volume: vol, defhead: defhead)
      create(:eby_def_part_image, eby_def: d, colimg: col, defno: defno, partnum: 1)
      d
    end

    it 'assigns sequential ordinals to a chain of defs in one column' do
      d1 = make_def('אבג', 0)
      d2 = make_def('בגד', 1)
      d3 = make_def('גדה', 2)

      enumerate_vol(vol)

      expect(d1.reload.ordinal).to eq(1)
      expect(d2.reload.ordinal).to eq(2)
      expect(d3.reload.ordinal).to eq(3)
    end

    context 'when two defs share the same (column, defno)' do
      # def_part_by_defno uses .first, so the lower-id def becomes the canonical
      # and the higher-id def is the orphan that enumerate_vol must place.

      it 'inserts an alphabetically-later orphan immediately after its sibling' do
        d1     = make_def('אבג', 0)
        d2     = make_def('בגד', 1)  # canonical (lower id)
        d_twin = make_def('גגד', 1)  # orphan; 'ג' > 'ב' → sorts after d2
        d3     = make_def('דהו', 2)

        enumerate_vol(vol)

        expect(d1.reload.ordinal).to eq(1)
        expect(d2.reload.ordinal).to eq(2)
        expect(d_twin.reload.ordinal).to eq(3)
        expect(d3.reload.ordinal).to eq(4)
      end

      it 'inserts an alphabetically-earlier orphan immediately before its sibling' do
        d1     = make_def('בבג', 0)
        d2     = make_def('בגד', 1)  # canonical (lower id)
        d_twin = make_def('אגד', 1)  # orphan; 'א' < 'ב' → sorts before d2
        d3     = make_def('גדה', 2)

        enumerate_vol(vol)

        expect(d1.reload.ordinal).to eq(1)
        expect(d_twin.reload.ordinal).to eq(2)
        expect(d2.reload.ordinal).to eq(3)
        expect(d3.reload.ordinal).to eq(4)
      end
    end
  end
end
