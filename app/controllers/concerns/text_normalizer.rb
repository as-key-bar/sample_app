# app/models/concerns/string_normalizer.rb
require 'nkf'
require 'natto'
require 'humanize'


module TextNormalizer
  extend ActiveSupport::Concern

  MECAB = Natto::MeCab.new
  NUMBER_REGEX = /[0-9０-９]+/


  def convert_number_to_kanji(text)
    return "" if text.blank?

    text.gsub(NUMBER_REGEX) do |matched_number|
      half_width_str = NKF.nkf('-w -W -m0Z1', matched_number)
      int_value = half_width_str.to_i
      int_value.humanize(locale: :jp)
    end
  end

  def convert_to_searchkey(text)
    return "" if text.blank?

    katakana_reading = ""
    MECAB.parse(convert_number_to_kanji(text)) do |node|
      features = node.feature.split(',')
      reading = features[7]

      if reading && reading != "*"
        katakana_reading << reading
      else
        katakana_reading << node.surface
      end
    end

    NKF.nkf('-w -W -h1', katakana_reading)
  end
end