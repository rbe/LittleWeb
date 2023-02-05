# frozen_string_literal: true

# Authenticated, authorized HTTP request
module AARequest
  def [](key)
    @extra[key]
  end

  def []=(key, value)
    @extra[key] = value
  end

  def authenticate(token, hash)
    @extra[:token] = token
    @extra[:hash] = hash
  end

  def unauthenticate
    @extra.delete :token
    @extra.delete :hash
  end

  def authenticated?
    @extra.key?(:token) && @extra.key?(:hash)
  end

  def authorize
    @extra[:authorized] = true
  end

  def unauthorize
    @extra.delete :authorized
  end

  def authorized?
    @extra.key? :authorized
  end
end
