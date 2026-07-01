class Mute < ApplicationRecord
  belongs_to :muteing, class_name: "User", foreign_key: "muter_id"
  belongs_to :muted, class_name: "User", foreign_key: "muted_id"
end
