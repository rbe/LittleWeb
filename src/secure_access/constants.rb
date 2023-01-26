# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # Configuration
  class Constants
    # URL prefix
    URL_PREFIX = ENV['GM_URL_PREFIX'] || '/Gallimaufry'
    # Where to find resources?
    BASE_DIR = ENV['GM_BASE_DIR'] || '/data'
    # File with list of users having access to resources
    SECURE_LINK_TXT = ENV['GM_SECURE_LINK_TXT'] || 'db/secure_access.txt'
    # 2 hours in seconds
    EXPIRE_IN_SECONDS = 2 * 60 * 60
    # E-Mail
    EMAIL_HOST_FQDN = ENV['GM_EMAIL_HOST_FQDN'] || 'mailhog'
    EMAIL_HOST_PORT = (ENV['GM_EMAIL_HOST_PORT'] || '1025').to_i
    EMAIL_FROM = ENV['GM_EMAIL_FROM'] || 'gallimaufry@example.com'
  end
end
