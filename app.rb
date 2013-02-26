require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' #if development?



before do
  add_cross_origin_headers!
end

# Responds to all the OPTIONS "preflight requests" of cross-origin calls.
options '/*' do
  200
end

get '/' do
  logger.info request.query_string
  set_ce_html_content_type!
  erb :index , :locals => {:@platform_string => platformString}
end


get '/changelog' do
  markdown_text = File.new(settings.root + '/changelog.md').read
  markdown markdown_text
end

get '/readme' do
  markdown_text = File.new(settings.root + '/README.md').read
  markdown markdown_text
end

set :redirect_url, 'http://'
get '/redirect' do
  erb :redirect
end

post  '/redirect' do
  set :redirect_url, params[:url]
  erb :redirect
end

get '/set_redirect' do
  erb :set_redirect
end


helpers do

  def platformString
    if request.params['platform']
      request.params['platform'].upcase
    elsif request.user_agent =~ /LG/i
      "LG"
    elsif request.user_agent =~ /Philips/i or request.user_agent =~ /Nettv/i
      "PHILIPS"
    elsif request.user_agent =~ /Maple/i
      "SAMSUNG"
    else
      #"OTHER"
      request.user_agent
    end
  end


  ######################
  # Cross-origin helpers
  #

  # Add all the 'Access-Control-Allow-*' CORS magic to cross-origin requests.
  def add_cross_origin_headers!
    origin = env['HTTP_ORIGIN']
    return unless origin

    #if allowed_origin? origin
      request_method  = env['HTTP_ACCESS_CONTROL_REQUEST_METHOD']
      request_headers = env['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']
      response['Access-Control-Allow-Origin']      = origin
      response['Access-Control-Allow-Methods']     = request_method if request_method
      response['Access-Control-Allow-Headers']     = request_headers if request_headers
      response['Access-Control-Allow-Credentials'] = 'true'
    #else
    #  logger.info "Not allowed origin #{origin}"
    #end
  end

  #def allowed_origin?(origin)
  #  allowed_origins = [
  #      %r{^http://localhost}, # Localhost
  #      %r{^http://192\.168}, # LAN
  #  ]
  #  allowed_origins.any? { |pat| pat.match origin }
  #  Rack::Request
  #end

  ##############
  # Page helpers
  #


  def set_ce_html_content_type!
    logger.info request.user_agent

    if request.user_agent =~ /Opera\//
      # Opera and NetTV devices recognize CE-HTML mime type.
      content_type 'application/ce-html+xml;charset="UTF-8"'
    else #if request.user_agent =~ /Maple/i
      content_type 'text/html;charset="UTF-8"'
    #else
    #  # Other browsers don't, but they can render XHTML.
    #  content_type 'application/xhtml+xml;charset="UTF-8"'
    end
  end
end
