module Api
  module Users
    class SessionsController < BaseController
      # POST /api/users/auth/login
      def create
        user = User.find_by(email: params[:email])

        # unified Unauthorized message
        raise UnauthorizedError, "Invalid email or password" if user.nil? || !user.authenticate(params[:password])

        # check status
        raise ForbiddenError, "User account is not active" if user.status != "active"

        token = JsonWebToken.encode({ user_id: user.id })

        render_auth(token, user, :ok)
      end

      # POST /api/users/auth/logout
      def destroy
        # Stateless JWT: this just tells the client to drop the token.
        # TODO: Implement token blacklisting if needed.
        render_logout
      end
    end
  end
end
