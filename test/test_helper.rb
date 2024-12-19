require 'minitest/autorun'
require 'minitest/pride' unless ENV['RM_INFO']
require 'webmock/minitest'
require_relative '../lib/devto_publisher'

# Disable external network connections during tests
WebMock.disable_net_connect!
