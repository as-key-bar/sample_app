require 'rails_helper'

RSpec.describe "Blocks", type: :request do
  fixtures :users, :relationships

  let(:user) { users(:michael) }
  let(:other_user) { users(:archer) }

  let(:model_class) { Block }
  let(:create_path) { blocks_path }
  let(:create_param_key) { :blocked_id }
  let(:active_association) { :active_blocks }
  let(:target_fk) { :blocked_id }
  let(:member_path) { ->(record) { block_path(record) } }
  let(:trigger_precondition_failure) do
    ->(user, other_user) { user.block(other_user) }
  end

  include_examples "unified relationship toggle controller"

  describe "POST create" do
    context "ログインしている場合" do
      before { log_in_as(user) }

      it "ブロックするとフォロー関係が解除されること" do
        expect {
          post blocks_path, params: { blocked_id: other_user.id }
        }.to change(Block, :count).by(1)

        expect(user.following?(other_user)).to be_falsey
        expect(other_user.following?(user)).to be_falsey
      end
    end
  end
end
