# app/models/concerns/string_normalizer.rb
require 'nkf'
require 'natto'

module TextNormalizer
  extend ActiveSupport::Concern

  MECAB = Natto::MeCab.new

  NUMBER_MAP = {
    '0' => 'ぜろ', '1' => 'いち', '2' => 'に', '3' => 'さん', '4' => 'よん',
    '5' => 'ご',   '6' => 'ろく', '7' => 'なな', '8' => 'はち', '9' => 'きゅう',
    '０' => 'ぜろ', '１' => 'いち', '２' => 'に', '３' => 'さん', '４' => 'よん',
    '５' => 'ご',   '６' => 'ろく', '７' => 'なな', '８' => 'はち', '９' => 'きゅう'
  }.freeze



  module_helper = Module.new do
    def convert_to_hiragana(text)
      return "" if text.blank?
      NKF.nkf('-w -W -h1', text)
    end

    def convert_to_searchkey(text)
      return "" if text.blank?

      katakana_reading = ""
      MECAB.parse(text.to_s) do |node|
        features = node.feature.split(',')
        reading = features[7]

        if reading && reading != "*"
          katakana_reading << reading
        else
          katakana_reading << node.surface
        end
      end

      NKF.nkf('-w -W -h1', katakana_reading).gsub(/[0-9０-９]/, NUMBER_MAP)
    end

  end

  extend module_helper
  include module_helper
end