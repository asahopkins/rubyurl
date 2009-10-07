require File.dirname(__FILE__) + '/../../spec_helper'

describe Api::LinksController, "creating a new rubyurl" do
  def valid_parameters
    { :website_url => 'http://thomas.loc.gov/cgi-bin/query/z?r108:E26MR4-0015:', 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => "http://thomas.loc.gov/cgi-bin/query/R?r108:FLD001:E50456",    
      :link_type => "cong_record",
      :cr_page => "E50456" }
  end
  
  before( :each ) do
    @link = mock_model( Link )
    @link.stub!( :ip_address= )
    @link.stub!( :new_record? ).and_return( true )
    Link.stub!( :find_or_create_by_url ).and_return( @link ) 
    @link.stub!( :save ).and_return( true )
    @link.stub!( :to_api_xml )
  end
  
  it "should create a new instance of a Link object" do
    Link.should_receive( :find_or_create_by_url ).with( valid_parameters[:website_url] ).and_return( @link )        
    post :create, :link => valid_parameters, :format => 'xml'
  end

  it "should assign the remote ip address" do
    @link.should_receive( :ip_address= )
    post :create, :link => valid_parameters, :format => 'xml'
  end  

  it "should successfully save the new link" do
    @link.should_receive( :save ).and_return( true )
    post :create, :link => valid_parameters, :format => 'xml'
  end
  
  it "should return XML" do
    @link.should_receive( :to_api_xml )    
    post :create, :link => valid_parameters, :format => 'xml'
  end
  
  it "should be successful" do
    post :create, :link => valid_parameters, :format => 'xml'    
    response.should be_success
  end
  
end