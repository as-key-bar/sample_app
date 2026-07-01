class Block < ApplicationRecord
  belongs_to :blocking, class_name: "User"
  belongs_to :blocked, class_name: "User"
end
