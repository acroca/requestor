require 'requestor'
require 'webmock/rspec'

describe Requestor do
  let(:content) { "<html><head></head><body><h1><span class='test'>Content</span></h1></body></html>" }
  let!(:remote_req) { stub_request(:get, "http://example.com/remote").to_return(:status => 200, :body => content, :headers => {}) }
  let!(:callback_req) { stub_request(:get, "http://example.com/callback") }
  
  let(:previous_content) { nil }  

  before { Requestor.any_instance.stub(:previous_content) { previous_content } }
  
  it "calls the callback when the previous_content content is not present" do
    Requestor.new("http://example.com/remote", "h1 .test", "http://example.com/callback").process
    remote_req.should have_been_requested
    callback_req.should have_been_requested
  end

  context "previous_content is different" do
    let(:previous_content) { "old" }  
    it "calls the callback when the previous_content content is different" do
      Requestor.new("http://example.com/remote", "h1 .test", "http://example.com/callback").process
      remote_req.should have_been_requested
      callback_req.should have_been_requested
    end
  end

  context "previous_content is the same" do
    let(:previous_content) { "Content" }  
    it "calls the callback when the previous_content content is different" do
      Requestor.new("http://example.com/remote", "h1 .test", "http://example.com/callback").process
      remote_req.should have_been_requested
      callback_req.should_not have_been_requested
    end
  end
    
end