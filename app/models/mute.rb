class Mute < ApplicationRecord
  belongs_to :muteing, class_name: "User"
  belongs_to :muted, class_name: "User"
end
