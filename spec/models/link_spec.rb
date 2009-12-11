require File.dirname(__FILE__) + '/../spec_helper'

describe Link, "with fixtures loaded" do
  fixtures :links
  
  it "should load a non-empty collection of links" do
    Link.find(:all).should_not be_empty
  end
  
  it "should have seven records" do
    Link.should have(7).records
  end
end

describe "Bill link " do
  fixtures :links, :visits
  
  before(:each) do
    @link = Link.find(links(:bill).id)
  end
  
  it "should have a matching website url" do
    @link.website_url.should eql(links(:bill).website_url)
  end
  
  it "should have two (2) visits" do
    @link.should have(2).visits
  end
  
  it "should not be flagged as spam" do
    @link.flagged_as_spam?.should be_false
  end
  
  it "should add a new visit with .add_visit" do
    request = mock('request')
    request.stub!(:remote_ip).and_return('127.0.0.1')
    lambda do
      @link.add_visit(request)
    end.should change(@link.visits, :count).by(1)
  end

  it "should add a new OC visit with .add_visit" do
    request = mock('request')
    request.stub!(:remote_ip).and_return('127.0.0.1')
    site = "oc"
    lambda do
      @link.add_visit(request, site)
    end.should change(@link.visits, :count).by(1)
  end

end

describe "Spammer site" do
  fixtures :links, :visits
  
  before(:each) do 
    @link = Link.find(links(:spammer_site).id)
  end
  
  it "should have one (1) visits" do
    @link.should have(1).visits
  end
  
  it "should have one flagged as spam visit" do
    @link.should have(1).spam_visits
  end
  
  it "should be flagged as spam" do
    @link.flagged_as_spam?.should be_true    
  end
end

describe Link, "a new link" do
  include LinkSpecHelper
  
  before(:each) do
    @link = Link.new
  end
  
  it "should be invalid without a website url" do
    @link.attributes = valid_attributes.except(:website_url)
    @link.should have(1).error_on(:website_url)
  end
  
  it "should be invalid without an ip address" do
    @link.attributes = valid_attributes.except(:ip_address)
    @link.should have(1).error_on(:ip_address)    
  end
  
  it "should be valid with valid attributes" do
    @link.attributes = valid_attributes
    @link.should be_valid
  end
  
  it "should generate a token when saved" do
    @link.attributes = valid_attributes
    @link.token.should be_nil
    @link.save.should be_true
    @link.token.should_not be_nil
  end
  
  it "should generate a permalink when created" do
    @link.attributes = valid_attributes
    @link.permalink.should be_nil
    @link.save.should be_true
    @link.permalink.should_not be_nil
    @link.permalink.should eql(DOMAIN_NAME + @link.token)
  end
  
  it "should generate the correct thomas link for a bill page" do
    @link.attributes = valid_bill
    new_link = Link.find_or_create_by_url(valid_bill[:website_url])
    new_link.thomas_permalink.should eql(@link.thomas_permalink)
  end

  it "should generate the correct opencongress link for a bill page" do
    @link.attributes = valid_bill
    new_link = Link.find_or_create_by_url(valid_bill[:website_url])
    new_link.opencongress_link.should eql(@link.opencongress_link)
  end

  it "should generate the correct govtrack link for a bill page" do
    @link.attributes = valid_bill
    new_link = Link.find_or_create_by_url(valid_bill[:website_url])
    new_link.govtrack_link.should eql(@link.govtrack_link)
  end

  it "should generate the correct thomas link for a bill text page" do
    @link.attributes = valid_bill_text
    new_link = Link.find_or_create_by_url(valid_bill_text[:website_url])
    new_link.thomas_permalink.should eql(@link.thomas_permalink)
  end

  it "should generate the correct opencongress link for a bill text page" do
    @link.attributes = valid_bill_text_2
    new_link = Link.find_or_create_by_url(valid_bill_text_2[:website_url])
    new_link.opencongress_link.should eql(@link.opencongress_link)
  end

  it "should generate the correct govtrack link for a bill text page" do
    @link.attributes = valid_bill_text_2
    new_link = Link.find_or_create_by_url(valid_bill_text_2[:website_url])
    new_link.govtrack_link.should eql(@link.govtrack_link)
    @link.attributes = valid_bill_text
    new_link = Link.find_or_create_by_url(valid_bill_text[:website_url])
    new_link.govtrack_link.should eql(@link.govtrack_link)
  end

  it "should generate the correct thomas link for a bill text page with multiple versions listed" do
    @link.attributes = valid_bill_text_multi
    new_link = Link.find_or_create_by_url(valid_bill_text_multi[:website_url])
    new_link.thomas_permalink.should eql(@link.thomas_permalink)
  end

  it "should generate the correct thomas link for a nomination page" do
    @link.attributes = valid_nomination
    new_link = Link.find_or_create_by_url(valid_nomination[:website_url])
    new_link.thomas_permalink.should eql(@link.thomas_permalink)
  end

  it "should generate the correct thomas link for a record digest page" do
    @link.attributes = valid_record_digest
    new_link = Link.find_or_create_by_url(valid_record_digest[:website_url])
    new_link.thomas_permalink.should eql(@link.thomas_permalink)
  end

  it "should generate the correct thomas link for a committee report page" do
    @link.attributes = valid_comm_report
    new_link = Link.find_or_create_by_url(valid_comm_report[:website_url])
    new_link.thomas_permalink.should eql(@link.thomas_permalink)
  end
  
  it "should generate the correct thomas link for a congressional record page" do
    @link.attributes = valid_cong_record
    new_link = Link.find_or_create_by_url(valid_cong_record[:website_url])
    new_link.thomas_permalink.should eql(@link.thomas_permalink)
  end

  it "should generate the correct thomas link for a bill all information page" do
    @link.attributes = valid_bill_all_info
    new_link = Link.find_or_create_by_url(valid_bill_all_info[:website_url])
    new_link.thomas_permalink.should eql(@link.thomas_permalink)
  end

  it "should generate the correct thomas link for a bill related bills page" do
    @link.attributes = valid_bill_related
    new_link = Link.find_or_create_by_url(valid_bill_related[:website_url])
    new_link.thomas_permalink.should eql(@link.thomas_permalink)
  end
  
  it "should generate the correct thomas link for a bill titles page" do
    @link.attributes = valid_bill_titles
    new_link = Link.find_or_create_by_url(valid_bill_titles[:website_url])
    new_link.thomas_permalink.should eql(@link.thomas_permalink)
  end
  
  it "should generate the correct thomas link for a bill cosponsors page" do
    @link.attributes = valid_bill_cosponsors
    new_link = Link.find_or_create_by_url(valid_bill_cosponsors[:website_url])
    new_link.thomas_permalink.should eql(@link.thomas_permalink)
  end
  
  it "should generate the correct thomas link for a bill amendments page" do
    @link.attributes = valid_bill_amendments
    base_url = 'http://thomas.loc.gov/cgi-bin/bdquery/z?d111:hr3962:'
    c = Curl::Easy.perform(base_url).body_str
    doc = Hpricot(c)
    amendments_url = "http://thomas.loc.gov"+(((doc/"div#content"/"tr")[2]/"td")[1]/"a")[0].attributes["href"]
    new_link = Link.find_or_create_by_url(amendments_url)
    new_link.thomas_permalink.should eql(@link.thomas_permalink)
  end
  
  it "should generate the correct thomas link for a bill subjects page" do
    @link.attributes = valid_bill_subjects
    new_link = Link.find_or_create_by_url(valid_bill_subjects[:website_url])
    new_link.thomas_permalink.should eql(@link.thomas_permalink)
  end
  
  it "should generate the correct thomas link for a bill crs summary page" do
    @link.attributes = valid_bill_crs_summary
    new_link = Link.find_or_create_by_url(valid_bill_crs_summary[:website_url])
    new_link.thomas_permalink.should eql(@link.thomas_permalink)
  end
  
  it "should generate the correct thomas link for a bill committees page" do
    @link.attributes = valid_bill_committees
    new_link = Link.find_or_create_by_url(valid_bill_committees[:website_url])
    new_link.thomas_permalink.should eql(@link.thomas_permalink)
  end
  
  it "should generate the correct thomas link for a bill committees page" do
    @link.attributes = valid_bill_major_actions
    new_link = Link.find_or_create_by_url(valid_bill_major_actions[:website_url])
    new_link.thomas_permalink.should eql(@link.thomas_permalink)
  end
  
  it "should generate the correct thomas link for a bill committees page" do
    @link.attributes = valid_bill_all_actions
    new_link = Link.find_or_create_by_url(valid_bill_all_actions[:website_url])
    new_link.thomas_permalink.should eql(@link.thomas_permalink)
  end
  
  it "should generate the correct thomas link for a bill committees page" do
    @link.attributes = valid_bill_all_actions_amend
    new_link = Link.find_or_create_by_url(valid_bill_all_actions_amend[:website_url])
    new_link.thomas_permalink.should eql(@link.thomas_permalink)
  end
  
  it "should flag expired Thomas links" do
    new_link = Link.find_or_create_by_url("http://thomas.loc.gov/cgi-bin/bdquery/D?d111:2:./temp/~bd5CYL::|/bss/|")
    new_link.should eql("http://thomas.loc.gov/cgi-bin/bdquery/D?d111:2:./temp/~bd5CYL::|/bss/|")    
  end
    
end

describe "A new Link, which already exists" do
  include LinkSpecHelper
  
  before(:each) do
    @link = Link.new
    @link.attributes = valid_attributes
    @link.save
  end
  
  it "should return the original link rather than create a new one" do
    old_token = @link.token
    old_type = @link.link_type
    old_permalink = @link.permalink
    old_website_url = @link.website_url
    new_link = Link.find_or_create_by_url(valid_attributes[:thomas_permalink])
    new_link.should eql(@link)
    new_link.token.should eql(old_token)
    new_link.link_type.should eql(old_type)
    new_link.permalink.should eql(old_permalink)
    new_link.website_url.should_not eql(old_website_url)
  end
end

describe "A new link" do
  include LinkSpecHelper    
  
  it "should not save when provided a URL without http://" do
    @link = Link.new
    @link.attributes = valid_attributes.except(:website_url)
    @link.website_url = 'thomas.loc.gov/cgi-bin/query/z?r108:E26MR4-0015:'
    @link.should have(1).error_on(:website_url)
  end
  
  it "should not save a link without http://thomas.loc.gov/ or http://hdl.loc.gov/." do
    @link = Link.new
    @link.attributes = valid_attributes.except(:website_url)
    @link.website_url = 'http://www.google.com'
    @link.should have(1).errors_on(:website_url)
  end

  it "should save a link with query string parameters" do
    @link = Link.new
    @link.attributes = valid_attributes.except(:website_url)
    @link.website_url = 'http://thomas.loc.gov/cgi-bin/query/z?r108:E26MR4-0015:'
    @link.should have(0).errors_on(:website_url)
  end

  it "should save a link with an anchor tag and retain it" do
    @link = Link.new
    @link.attributes = valid_attributes.except(:website_url)
    @link.website_url = 'http://thomas.loc.gov/cgi-bin/query/z?r108:E26MR4-0015:#test'
    @link.save
    @link.website_url.should == 'http://thomas.loc.gov/cgi-bin/query/z?r108:E26MR4-0015:#test'
  end
end

describe "a link created from a bill number" do
  fixtures :links
  
  it "should create the correct thomas_permalink" do
    new_link = Link.find_or_create_by_bill('HR001')
    new_link.link_type.should == "bill"
    new_link.bill_ident.should == "hr1"
    new_link.congress.should == 111
    new_link.thomas_permalink.should == "http://hdl.loc.gov/loc.uscongress/legislation.111hr1"

    new_link = Link.find_or_create_by_bill('105Ha10')
    new_link.link_type.should == "bill"
    new_link.bill_ident.should == "hamdt10"
    new_link.congress.should == 105
    new_link.thomas_permalink.should == "http://thomas.loc.gov/cgi-bin/bdquery/z?d105:hamdt10:"

    new_link = Link.find_or_create_by_bill('110s1932')
    new_link.link_type.should == "bill"
    new_link.bill_ident.should == "s1932"
    new_link.congress.should == 110
    new_link.thomas_permalink.should == "http://hdl.loc.gov/loc.uscongress/legislation.110s1932"
  end
  
  it "should return nil when the bill_number doesn't make sense" do
    new_link = Link.find_or_create_by_bill('45s1932')
    new_link.should be_nil
    new_link = Link.find_or_create_by_bill('s1932d')
    new_link.should be_nil
    new_link = Link.find_or_create_by_bill('hr725364')
    new_link.should be_nil
  end

  it "should create a new link when it doesn't already exist" do
    new_link = Link.find_or_create_by_bill('HR001')
    Link.find(:first,:conditions=>["congress=:cong AND bill_ident=:bill",{:cong=>new_link.congress, :bill=>new_link.bill_ident}]).should be_nil
  end
  
  it "should use an existing link when it already exists" do
    @link = Link.find(links(:bill).id)
    new_link = Link.find_or_create_by_bill('HR2410')
    @link.thomas_permalink.should == new_link.thomas_permalink
    @link.id.should == new_link.id
  end
  
end

describe Link, 'to_api_xml' do
  before( :each ) do
    @link = Link.new( { :website_url => 'http://thomas.loc.gov/cgi-bin/query/z?r108:E26MR4-0015:', 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => "http://thomas.loc.gov/cgi-bin/query/R?r108:FLD001:E50456",    
      :link_type => "cong_record",
      :cr_page => "E50456"} )
    @link.save
  end
  
  it "should return the proper XML" do
    @link.to_api_xml.should == '<?xml version="1.0" encoding="UTF-8"?><link><website_url>' + @link.website_url + '</website_url><permalink>' + @link.permalink + '</permalink><thomas_permalink>' + @link.thomas_permalink + '</thomas_permalink></link>'
  end
end

describe Link, 'to_api_json' do
  before( :each ) do
    @link = Link.new( { :website_url => 'http://thomas.loc.gov/cgi-bin/query/z?r108:E26MR4-0015:', 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => "http://thomas.loc.gov/cgi-bin/query/R?r108:FLD001:E50456",    
      :link_type => "cong_record",
      :cr_page => "E50456"} )
    @link.save
  end
  
  it "should return the proper JSON" do
    @link.to_api_json.should == '{"link": {"permalink": "' + @link.permalink + '", "website_url": "' + @link.website_url + '", "thomas_permalink": "' + @link.thomas_permalink + '"}}'
  end
end