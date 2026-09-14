class AuthTokenService
  ACCESS_TOKEN_EXPIRY = 15.minutes
  REFRESH_TOKEN_EXPIRY = 30.days

  def issue_tokens(user)
    refresh_token = SecureRandom.hex(32)
    user.refresh_tokens.create!(token_digest: RefreshToken.digest(refresh_token), expires_at: REFRESH_TOKEN_EXPIRY.from_now)

    { access_token: access_token_for(user), refresh_token: refresh_token }
  end

  def refresh(raw_refresh_token)
    token_record = RefreshToken.active.find_by(token_digest: RefreshToken.digest(raw_refresh_token))
    raise ActiveRecord::RecordNotFound unless token_record

    token_record.revoke!
    issue_tokens(token_record.user)
  end

  private

  def access_token_for(user)
    JsonWebToken.encode({ user_id: user.id }, expires_in: ACCESS_TOKEN_EXPIRY)
  end
end
