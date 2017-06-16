class WelcomeController < ApplicationController
  def index
    flash[:warning] = "morning！"
  end
end
