class BlocksController < ApplicationController
  include RelationshipToggleable

  def create
    toggle_relationship(param_key: :blocked_id, action: :block,
                         failure_message: "This user could not be blocked.")
  end

  def destroy
    untoggle_relationship(active_association: :active_blocks,
                           target_association: :blocked, undo: :unblock)
  end
end
