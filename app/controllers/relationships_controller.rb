class RelationshipsController < ApplicationController
  include RelationshipToggleable

  def create
    toggle_relationship(param_key: :followed_id, action: :follow,
                         failure_message: "This user could not be followed.")
  end

  def destroy
    untoggle_relationship(active_association: :active_relationships,
                           target_association: :followed, undo: :unfollow)
  end
end
