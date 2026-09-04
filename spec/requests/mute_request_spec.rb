require 'rails_helper'

RSpec.describe "Mutes", type: :request do
  fixtures :users, :relationships

  let(:user) { users(:michael) }
  let(:other_user) { users(:archer) }

  let(:model_class) { Mute }
  let(:create_path) { mutes_path }
  let(:create_param_key) { :muted_id }
  let(:active_association) { :active_mutes }
  let(:target_fk) { :muted_id }
  let(:member_path) { ->(record) { mute_path(record) } }
  let(:trigger_precondition_failure) do
    ->(user, other_user) { user.mute(other_user) }
  end

  include_examples "unified relationship toggle controller"
end
