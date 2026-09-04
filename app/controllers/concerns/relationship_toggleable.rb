module RelationshipToggleable
  extend ActiveSupport::Concern

  included do
    before_action :logged_in_user
  end

  private

    # 相手ユーザーに対する操作(フォロー/ミュート/ブロック)を行う
    def toggle_relationship(param_key:, action:, failure_message:)
      @user = User.find_by(id: params[param_key])

      if @user.nil? || !current_user.public_send(action, @user)
        respond_to do |format|
          format.html do
            flash[:warning] = failure_message
            redirect_back(fallback_location: root_path)
          end
          format.turbo_stream { head :unprocessable_entity }
        end
        return
      end

      respond_to do |format|
        format.html { redirect_to @user }
        format.turbo_stream
      end
    end

    # 相手ユーザーに対する操作を取り消す(フォロー解除/ミュート解除/ブロック解除)
    def untoggle_relationship(active_association:, target_association:, undo:)
      record = current_user.public_send(active_association).find_by(id: params[:id])

      if record
        @user = record.public_send(target_association)
        current_user.public_send(undo, @user)
        respond_to do |format|
          format.html { redirect_to @user, status: :see_other }
          format.turbo_stream
        end
      else
        respond_to do |format|
          format.html { redirect_back(fallback_location: root_path) }
          format.turbo_stream { head :ok }
        end
      end
    end
end
