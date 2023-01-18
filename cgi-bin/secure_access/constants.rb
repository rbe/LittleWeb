# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # Configuration
  class Constants
    # URL prefix
    URL_PREFIX = '/Gallimaufry'
    # Where to find resources?
    BASE_DIR = '/data'
    # File with list of users having access to resources
    SECURE_LINK_TXT = 'secure_link.txt'
    # 2 hours in seconds
    EXPIRE_IN_SECONDS = 2 * 60 * 60
    # E-Mail
    EMAIL_HOST_FQDN = 'mailhog'
    EMAIL_HOST_PORT = 1025
    EMAIL_FROM = 'ralf@bensmann.com'
  end
end
