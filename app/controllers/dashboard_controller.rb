class DashboardController < ApplicationController
  before_action :require_client

  def main
    puts "CHECK CHECK I AM IN DashboardController#main. Can I access the client? #{client_connected?}"
  end
end
