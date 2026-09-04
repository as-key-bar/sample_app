require 'rails_helper'

RSpec.describe "Relationships", type: :request do
  fixtures :users, :relationships

  let(:user) { users(:michael) }
  let(:other_user) { users(:archer) }

  let(:model_class) { Relationship }
  let(:create_path) { relationships_path }
  let(:create_param_key) { :followed_id }
  let(:active_association) { :active_relationships }
  let(:target_fk) { :followed_id }
  let(:member_path) { ->(record) { relationship_path(record) } }
  let(:trigger_precondition_failure) do
    ->(user, other_user) { other_user.active_blocks.create!(blocked_id: user.id) }
  end

  include_examples "unified relationship toggle controller"
end
