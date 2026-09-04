class MutesController < ApplicationController
  include RelationshipToggleable

  def create
    toggle_relationship(param_key: :muted_id, action: :mute,
                         failure_message: "This user could not be muted.")
  end

  def destroy
    untoggle_relationship(active_association: :active_mutes,
                           target_association: :muted, undo: :unmute)
  end
end
