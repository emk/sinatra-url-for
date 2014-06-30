require 'spec_helper'
require 'sinatra'
require 'sinatra/url_for'
require 'rack/test'

# HTML exception pages in tests isn't useful; raise them to rspec so it can
# tell us about them
disable :show_exceptions
enable :raise_errors

get "/" do
  content_type "text/plain"
  url_for params[:url], params[:mode], params[:options]
end

get "/nomode" do
  content_type "text/plain"
  url_for params[:url], params[:options]
end

describe Sinatra::UrlForHelper do
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end
  
  it "should handle the root URL" do
    get "/", :url => "/"

    last_response.should be_ok
    last_response.body.should == "/"
  end
  
  it "should handle sub-URLs" do
    get "/", :url => "/foo"

    last_response.should be_ok
    last_response.body.should == "/foo"
  end
  
  it "should provide full paths if asked" do
    get "/", :url => "/foo", :mode => :full

    last_response.should be_ok
    last_response.body.should == "http://example.org/foo"
  end
  
  it "should accept options" do
    get "/", :url => "/foo", :options => { :x => "y" }
    
    last_response.should be_ok
    last_response.body.should == "/foo?x=y"
  end
  
  it "should accept multiple options" do
    get "/", :url => "/foo", :options => { :x => "y", :bar => "wombat" }
    
    last_response.should be_ok
    last_response.body.should == "/foo?x=y&bar=wombat"
  end
  
  it "should escape option values" do
    get "/", :url => "/foo", :options => { :x => "M&Ms", :amount => "15%", :equals => "=" }
    
    last_response.should be_ok
    last_response.body.should == "/foo?x=M%26Ms&amount=15%25&equals=%3D"
  end

  it "should even escape URLs" do
    get "/", :url => "/foo", :options => { :return_to => "http://example.com/bar?x=y" }
    
    last_response.should be_ok
    last_response.body.should == "/foo?return_to=http%3A%2F%2Fexample.com%2Fbar%3Fx%3Dy"
  end
  
  it "should handle not being passed a mode" do
    get "/nomode", :url => "/foo", :options => { :x => "y" }
    
    last_response.should be_ok
    last_response.body.should == "/foo?x=y"
  end
  
  it "should handle URLs with placeholders in them" do
    get "/", :url => "/object/:id/status", :options => { :id => 3, :extra => "test" }
    
    last_response.should be_ok
    last_response.body.should == "/object/3/status?extra=test"
  end
  
  it "should be able to handle multiple occurrences of URL placeholders" do
    get "/", :url => "/object/:id/status/:id", :options => { :id => "M&Ms", :extra => "test" }
    
    last_response.should be_ok
    last_response.body.should == "/object/M%26Ms/status/M%26Ms?extra=test"
  end
end
