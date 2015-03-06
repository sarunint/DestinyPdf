class PdfGeneratorController < ApplicationController
  before_action :validate_key
  def application
    @applicant = {}
    @applicant = params
    render
  end

  private
  def validate_key
    if ApiKey.find_by(key: params[:api_key]).nil?
      @message = 'No API key found, the access is denied.'
      render 'fail'
      return false
    end
  end
end
