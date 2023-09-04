# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "rails", github: "rails/rails", branch: "main"
  # gem "rails", '=7.0.4.3'
  gem "rack", "~> 2.0"
  # gem "debug", platforms: %i[ mri mingw x64_mingw ]
  # gem "pry"
end

require "action_controller/railtie"

class TestApp < Rails::Application
  config.root = __dir__
  config.hosts << "example.org"
  secrets.secret_key_base = "secret_key_base"
  config.server_timing = true

  config.logger = Logger.new($stdout)
  Rails.logger  = config.logger

  routes.draw do
    get "/nested" => "test#nested"
    get "/not_nested" => "test#not_nested"

  end
end

class TestController < ActionController::Base
  include Rails.application.routes.url_helpers

  def nested
    self.append_view_path('./views')
    @nesting = true
    render 'index'
  end

  def not_nested
    self.append_view_path('./views')
    @nesting = false
    render 'index'
  end
end

require "minitest/autorun"
require "rack/test"

class ServerTimingBugTest < Minitest::Test
  include Rack::Test::Methods

  def test_nested_response_ok
    get "/nested"
    assert last_response.ok?
  end

  def test_nested_partial_timing_less_than_total_controller
    get "/nested"
    assert_operator render_partial_timing_dur, :<, process_action_timing_dur, "partial rendering should be less than total action time"
  end

  def test_not_nested_response_ok
    get "/not_nested"
    assert last_response.ok?
  end

  def test_not_nested_partial_timing_less_than_total_controller
    get "/not_nested"
    assert_operator render_partial_timing_dur, :<, process_action_timing_dur, "partial rendering should be less than total action time"
  end

  private
    def app
      Rails.application
    end

    def reported_server_timings
      last_response.headers["Server-Timing"]
    end

    def reported_timing_durations
      timings = {}
      reported_server_timings.split(',').each do |entry|
        k, almost_v = entry.strip.split(';')
        timings[k.strip] = almost_v.delete('dur=').to_f
      end
      timings
    end

    def render_partial_timing_dur
      reported_timing_durations['render_partial.action_view']
    end

    def process_action_timing_dur
      reported_timing_durations['process_action.action_controller']
    end
end
