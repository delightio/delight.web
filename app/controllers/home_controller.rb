class HomeController < ApplicationController
  before_filter :allow_only_html_requests

  def index
    if user_signed_in?
      redirect_to apps_path
    end
  end

  def features
    respond_to do |format|
      format.html
    end
  end

  def pricing
    respond_to do |format|
      format.html
    end
  end

  def faq
    respond_to do |format|
      format.html
    end
  end

  def docs
    respond_to do |format|
      format.html
    end
  end

  def blog
    respond_to do |format|
      format.html
    end
  end

  def phonegap
    respond_to do |format|
      format.html
    end
  end

  def cocos2d
    respond_to do |format|
      format.html
    end
  end  

  def opengles
    respond_to do |format|
      format.html
    end
  end

  def unity
    respond_to do |format|
      format.html
    end
  end  
end
