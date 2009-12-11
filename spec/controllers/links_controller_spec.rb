require File.dirname(__FILE__) + '/../spec_helper'

describe LinksController, "index action" do
  controller_name :links
  
  before(:each) do
    @link = mock('link')
    Link.stub!(:new).and_return(@link)    
    get :index
  end
  
  it "should render the index view" do
    response.should render_template('links/index')
  end

  it "should instantiate a new link variable" do
    assigns[:link].should equal(@link)
  end  

end

describe LinksController do
  include LinkSpecHelper

  controller_name :links
  
  it "should not save a new link without a website url" do
    post :create, :link => {}
    assigns(:link).should have_at_least(1).errors_on(:website_url)
  end
  
  it "should save a new link with valid attributes" do
    lambda do
      post :create, :link => valid_attributes
    end.should change(Link, :count).by(1)
  end
end

describe LinksController, "create action" do
  include LinkSpecHelper
  controller_name :links
    
  it "should redirect an expired URL to the 'expired' page" do
    post :create, :link => expired_website_url
    response.should render_template( 'links/expired' )
  end
end

describe LinksController, "redirect routing" do
  controller_name :links
  
  it "should route to the redirect action in LinksController" do
    assert_routing '/abc', { :controller => 'links', :action => 'redirect', :token => 'abc' }
  end
  
  it "should redirect to the invalid page when the token is invalid" do
    get :redirect, :token => 'magoo'
    response.should redirect_to( :action => 'invalid' )
  end

  it "should route /oc links to the redirect action in LinksController" do
    assert_routing '/abc/oc', { :controller => 'links', :action => 'redirect', :token => 'abc', :site=>'oc' }
  end

  it "should route /gt links to the redirect action in LinksController" do
    assert_routing '/abc/gt', { :controller => 'links', :action => 'redirect', :token => 'abc', :site=>'gt' }
  end

end

describe LinksController, "redirect with token" do
  
  before(:each) do
    @link = mock( 'link' )
    Link.should_receive( :find_by_token ).with( 'abcd' ).and_return( @link )
    @link.stub!( :add_visit )
    @link.should_receive( :thomas_permalink ).and_return( 'http://thomas.loc.gov/cgi-bin/query/z?r108:E26MR4-0015:' )
    get :redirect, :token => 'abcd'    
  end
  
  it "should call redirected to a website when passed a token" do
    response.should redirect_to( 'http://thomas.loc.gov/cgi-bin/query/z?r108:E26MR4-0015:' )
  end
end

describe LinksController, "redirect with bill number token" do
  
  before(:each) do
    @link = mock( 'link' )
    Link.should_receive( :find_by_token ).with( 'hr001' ).and_return( nil )
    Link.should_receive( :find_or_create_by_bill ).with( 'hr001' ).and_return( @link )
    @link.stub!( :add_visit )
    @link.should_receive( :thomas_permalink ).and_return( 'http://hdl.loc.gov/loc.uscongress/legislation.111hr1' )
    get :redirect, :token => 'hr001'    
  end
  
  it "should call redirected to a website when passed a token" do
    response.should redirect_to( 'http://hdl.loc.gov/loc.uscongress/legislation.111hr1' )
  end
end

describe LinksController, "redirect to OpenCongress with token" do
  
  before(:each) do
    @link = mock( 'oc_link' )
    Link.should_receive( :find_by_token ).with( 'abcd' ).and_return( @link )
    @link.stub!( :add_visit )
    @link.should_receive( :opencongress_link ).and_return( 'http://www.opencongress.org/bill/111-h3962/text' )
    get :redirect, :token => 'abcd', :site=>'oc'    
  end
  
  it "should call redirected to a website when passed a token and /oc" do
    response.should redirect_to( 'http://www.opencongress.org/bill/111-h3962/text' )
  end
end

describe LinksController, "redirect to GovTrack with token" do
  
  before(:each) do
    @link = mock( 'gt_link' )
    Link.should_receive( :find_by_token ).with( 'abcd' ).and_return( @link )
    @link.stub!( :add_visit )
    @link.should_receive( :govtrack_link ).and_return( 'http://www.govtrack.us/congress/bill.xpd?bill=h111-3962' )
    get :redirect, :token => 'abcd', :site=>'gt'    
  end
  
  it "should call redirected to a website when passed a token and /gt" do
    response.should redirect_to( 'http://www.govtrack.us/congress/bill.xpd?bill=h111-3962' )
  end
end
