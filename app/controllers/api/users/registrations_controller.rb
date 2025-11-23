module Api
  module Users
    class RegistrationsController < BaseController
      # POST /api/users/auth/register
      def create
        # ensure confirmation matches — raise RecordInvalid for consistency
        if params[:password] != params[:password_confirmation]
          raise ActiveRecord::RecordInvalid.new(User.new.tap { |u| u.errors.add(:password_confirmation, "does not match") })
        end

        user = User.new(user_params.merge(status: "active"))
        user.save! # will raise RecordInvalid and be caught by BaseController

        token = JsonWebToken.encode({ user_id: user.id })

        render_auth(token, user, :created)
      end

      private

      def user_params
        params.permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end
