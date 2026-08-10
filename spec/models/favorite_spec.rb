require 'rails_helper'

RSpec.describe Favorite, type: :model do
  fixtures :users, :microposts

  let(:favorite) do
    Favorite.new(
      favoriter_id: users(:michael).id,
      favorited_id: microposts(:orange).id
    )
  end

  context "Favorite Model Spec" do
    it "validが通るかどうか" do
      expect(favorite).to be_valid
    end

    it "ユーザーが空の時を弾くかどうか" do
      favorite.favoriter_id = nil
      expect(favorite).not_to be_valid
    end

    it "お気に入りの投稿が空の時を弾くかどうか" do
      favorite.favorited_id = nil
      expect(favorite).not_to be_valid
    end
  end
end
