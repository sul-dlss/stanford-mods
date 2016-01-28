# encoding: utf-8
require 'spec_helper'

describe Stanford::Mods::Coordinate do
  describe '#valid' do
    it 'is valid for well-formed coordinates' do
      expect(described_class.new('W 123°23ʹ16ʺ--W 122°31ʹ22ʺ/N 39°23ʹ57ʺ--N 38°17ʹ53ʺ')).to be_valid
    end

    it 'rejects out-of-bounds coordinates' do
      expect(described_class.new('W80°--E100°/N487°--S42°')).not_to be_valid
    end

    it 'rejects coordinates without degree symbols' do
      expect(described_class.new('W 650--W 100/N 700--N 550')).not_to be_valid
    end

    it 'rejects malformed coordinates' do
      expect(described_class.new('(E29°--E35/°S12°--S16°).')).not_to be_valid
    end
  end

  describe '#as_bbox' do
    it 'is nil for invalid data' do
      expect(described_class.new('x').as_bbox).to eq nil
    end
  end

  describe '#as_envelope' do
    it 'is nil for invalid data' do
      expect(described_class.new('x').as_envelope).to eq nil
    end
  end

  context '#as_bbox' do
    {
      %((W 123°23ʹ16ʺ--W 122°31ʹ22ʺ/N 39°23ʹ57ʺ--N 38°17ʹ53ʺ)) =>
        '-123.38777777777779 38.29805555555556 -122.52277777777778 39.399166666666666',
      %(E 10°03'00"--E 12°58'00"/N 45°00'00"--N 41°46'00") =>
        '10.05 41.766666666666666 12.966666666666667 45.0',
      %(E 8°41'-E 12°21'/N 46°04'-N 44°23') =>
        '8.683333333333334 44.38333333333333 12.35 46.06666666666667',
      %((E17°--E11°/N14°--N18°).) =>
        '11.0 14.0 17.0 18.0', # coordinates need to be reordered
      %((W 170⁰--E 55⁰/N 40⁰--S 36⁰).) =>
        '-170.0 -36.0 55.0 40.0', # superscript 0 is almost a degree character..
      %((W 0°-W 0°/S 90°---S 90°)) =>
        '-0.0 -90.0 -0.0 -90.0' # one dash, two dashes, three dashes.. what's the difference?
    }.each do |value, expected|
      describe 'parsing' do
        let(:subject) { described_class.new(value) }

        it 'transforms into the right bbox' do
          expect(subject.as_bbox).to eq expected
        end
      end
    end
  end

  context '#as_envelope' do
    {
      %((W 123°23ʹ16ʺ--W 122°31ʹ22ʺ/N 39°23ʹ57ʺ--N 38°17ʹ53ʺ)) =>
        'ENVELOPE(-123.38777777777779, -122.52277777777778, 39.399166666666666, 38.29805555555556)',
      %(E 10°03'00"--E 12°58'00"/N 45°00'00"--N 41°46'00") =>
        'ENVELOPE(10.05, 12.966666666666667, 45.0, 41.766666666666666)',
      %(E 8°41'-E 12°21'/N 46°04'-N 44°23') =>
        'ENVELOPE(8.683333333333334, 12.35, 46.06666666666667, 44.38333333333333)',
      %((E17°--E11°/N14°--N18°).) =>
        'ENVELOPE(11.0, 17.0, 18.0, 14.0)', # coordinates need to be reordered
      %((W 170⁰--E 55⁰/N 40⁰--S 36⁰).) =>
        'ENVELOPE(-170.0, 55.0, 40.0, -36.0)', # superscript 0 is almost a degree character..
      %((W 0°-W 0°/S 90°---S 90°)) =>
        'ENVELOPE(-0.0, -0.0, -90.0, -90.0)' # one dash, two dashes, three dashes.. what's the difference?
    }.each do |value, expected|
      describe 'parsing' do
        let(:subject) { described_class.new(value) }

        it 'transforms into the right envelope' do
          expect(subject.as_envelope).to eq expected
        end
      end
    end
  end
end
