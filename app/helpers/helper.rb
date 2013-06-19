def get_access_token
  access_token = request_token.get_access_token(
    :oauth_verifier => params[:oauth_verifier])
  session[:token] = access_token.token
  session[:secret] = access_token.secret
  session.delete(:request_token)
end