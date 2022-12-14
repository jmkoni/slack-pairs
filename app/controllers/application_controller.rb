class ApplicationController < ActionController::Base
  def index
    render inline: "<p>Are you looking for <a href='https://jmkoni.github.io/slack-pairs/'>the docs</a>?</p>"
  end
end
