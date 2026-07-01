require 'rails_helper'

RSpec.describe Mute, type: :model do

  fixtures :users
  mute = Mute.new(muter_id: users(:michael).id, muted_id: users(:archer).id)

  it "should be valid" do
    expect(mute).to be_valid
  end

  it "should require a muter_id" do
    mute.muter_id = nil
    expect(mute).not_to be_valid
  end

  it "should require a muted_id" do
    mute.muted_id = nil
    expect(mute).not_to be_valid
  end

end
