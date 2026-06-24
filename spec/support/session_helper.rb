# spec/support/session_helpers.rb
module SessionHelpers
  # チュートリアルのMinitestにあったログインメソッドをRSpec用に移植
  def log_in_as(user, password: 'password', remember_me: '1')
    post login_path, params: { session: { email: user.email,
                                          password: password,
                                          remember_me: remember_me } }
  end
end
