require 'spec_helper'
require 'sinatra'
require 'sinatra/url_for'
require 'rack/test'

get "/" do
  content_type "text/plain"
  <<"EOD"
#{url_for("/")}
#{url_for("/foo")}
#{url_for("/foo", :full)}
EOD
end

describe Sinatra::UrlForHelper do
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end
  
  it "should return absolute paths and full URLs" do
    get "/"
    last_response.should be_ok
    last_response.body.should == <<EOD
/
/foo
http://example.org/foo
EOD
  end
end
