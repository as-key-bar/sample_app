require 'rails_helper'

RSpec.describe Block, type: :model do

  fixtures :users
  let(:block) { Block.new(blocker_id: users(:michael).id, blocked_id: users(:archer).id) }

  it "should be valid" do
    expect(block).to be_valid
  end

  it "should require a blocker_id" do
    block.blocker_id = nil
    expect(block).not_to be_valid
  end

  it "should require a blocked_id" do
    block.blocked_id = nil
    expect(block).not_to be_valid
  end

end
