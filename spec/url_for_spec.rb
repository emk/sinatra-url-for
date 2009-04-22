require 'spec_helper'
require 'sinatra'
require 'sinatra/test'
require 'sinatra/url_for'

get "/" do
  content_type "text/plain"
  <<"EOD"
#{url_for("/")}
#{url_for("/foo")}
#{url_for("/foo", :full)}
EOD
end

describe Sinatra::UrlForHelper do
  include Sinatra::Test
  it "should return absolute paths and full URLs" do
    get "/"
    response.should be_ok
    response.body.should == <<EOD
/
/foo
http://example.org/foo
EOD
  end
end
