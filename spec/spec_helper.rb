# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Example::Configuration and Spec::Runner
end

module LinkSpecHelper
  def valid_attributes
    {:website_url => 'http://thomas.loc.gov/cgi-bin/query/z?r108:E26MR4-0015:', 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => "http://thomas.loc.gov/cgi-bin/query/R?r108:FLD001:E50456",    
      :link_type => "cong_record",
      :cr_page => "E50456", :congress=>108}
  end
  
  def valid_bill
    {:website_url => "http://thomas.loc.gov/cgi-bin/bdquery/z?d111:H.R.3962:", 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => 'http://hdl.loc.gov/loc.uscongress/legislation.111hr3962',
      :opencongress_link => 'http://www.opencongress.org/bill/111-h3962/show',
      :govtrack_link => 'http://www.govtrack.us/congress/bill.xpd?bill=h111-3962',
      :link_type => "bill",
      :bill_ident => "hr3962", :congress=>111}
  end
  
  def valid_bill_text
    {:website_url => "http://thomas.loc.gov/cgi-bin/query/z?c104:s.377.enr:", 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => 'http://thomas.loc.gov/cgi-bin/query/z?c104:s377.enr:',
      :opencongress_link => nil,
      :govtrack_link => 'http://www.govtrack.us/congress/billtext.xpd?bill=s104-377',
      :link_type => "bill_text",
      :bill_ident => "s377", :congress=>104, :bill_version=>"enr"}    
  end

  def valid_bill_text_2
    {:website_url => "http://thomas.loc.gov/cgi-bin/query/z?c111:H.R.3962.EH:", 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => 'http://thomas.loc.gov/cgi-bin/query/z?c111:hr3962.eh:',
      :opencongress_link => 'http://www.opencongress.org/bill/111-h3962/text',
      :govtrack_link => 'http://www.govtrack.us/congress/billtext.xpd?bill=h111-3962',
      :link_type => "bill_text",
      :bill_ident => "hr3962", :congress=>111, :bill_version=>"eh"}    
  end

  def valid_bill_text_multi
    {:website_url => "http://thomas.loc.gov/cgi-bin/query/z?c111:H.R.3962:", 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => 'http://thomas.loc.gov/cgi-bin/query/z?c111:hr3962:',  
      :opencongress_link => 'http://www.opencongress.org/bill/111-h3962/text',
      :govtrack_link => 'http://www.govtrack.us/congress/billtext.xpd?bill=h111-3962',  
      :link_type => "bill_text",
      :bill_ident => "h43962", :congress=>111, :bill_version=>nil}    
  end
  
  def valid_nomination
    {:website_url => "http://thomas.loc.gov/cgi-bin/ntquery/z?nomis:111PN0037000:", 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => 'http://thomas.loc.gov/cgi-bin/ntquery/z?nomis:111PN0037000:',    
      :link_type => "nomination",
      :nomination => "111PN0037000", :congress=>111}    
  end
  
  def valid_record_digest  # record_digests with other URL formats look like cong_records  
    {:website_url => "http://thomas.loc.gov/cgi-bin/query/B?r111:@FIELD(FLD003+d)+@FIELD(DDATE+20091107)", 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => 'http://thomas.loc.gov/cgi-bin/query/B?r111:@FIELD(FLD003+d)+@FIELD(DDATE+20091107)',    
      :link_type => "record_digest",
      :digest_date=> DateTime.civil(2009,11,7), :congress=>111}    
  end
  
  def valid_comm_report    #"http://thomas.loc.gov/cgi-bin/cpquery/2?cp111:./temp/~TSOPfShsa&sid=TSOPfShsa&item=2&sel=TOCLIST&hd_count=197&xform_type=3&r_n=hr089.111&dbname=cp111&&maxdocs=500&variant=y&r_t=h&r_t=s&r_t=jc&refer=&&w_p=energy&attr=3&&"
    {:website_url => "http://thomas.loc.gov/cgi-bin/cpquery/z?cp104:hr189.104:", 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => 'http://thomas.loc.gov/cgi-bin/cpquery/z?cp104:hr189.104:',    
      :link_type => "comm_report",
      :report_ident => "HR189", :congress=>104}    
  end
  
  def valid_cong_record
    valid_attributes
  end
  
  def valid_bill_all_info
    {:website_url => "http://thomas.loc.gov/cgi-bin/bdquery/z?d111:HR03962:@@@L&summ2=m&", 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => 'http://thomas.loc.gov/cgi-bin/bdquery/z?d111:hr3962:@@@L&summ2=m&',
      :link_type => "bill_all_info",
      :bill_ident => "hr3962", :congress=>111}    
  end
  
  def valid_bill_related
    {:website_url => "http://thomas.loc.gov/cgi-bin/bdquery/z?d111:HR03962:@@@K", 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => 'http://thomas.loc.gov/cgi-bin/bdquery/z?d111:hr3962:@@@K',
      :link_type => "bill_related",
      :bill_ident => "hr3962", :congress=>111}    
  end

  def valid_bill_titles
    {:website_url => "http://thomas.loc.gov/cgi-bin/bdquery/z?d111:HR03962:@@@T", 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => 'http://thomas.loc.gov/cgi-bin/bdquery/z?d111:hr3962:@@@T',
      :link_type => "bill_titles",
      :bill_ident => "hr3962", :congress=>111}    
  end

  def valid_bill_cosponsors
    {:website_url => "http://thomas.loc.gov/cgi-bin/bdquery/z?d111:HR03962:@@@P", 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => 'http://thomas.loc.gov/cgi-bin/bdquery/z?d111:hr3962:@@@P',
      :link_type => "bill_cosponsors",
      :bill_ident => "hr3962", :congress=>111}    
  end

  def valid_bill_amendments
    {:website_url => "http://thomas.loc.gov/cgi-bin/bdquery/L?d111:./temp/~bdau5fC:1[1-2](Amendments_For_H.R.3962)&./temp/~bdyzpG", 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => 'http://thomas.loc.gov/cgi-bin/bdquery/z?d111:hr3962:@@@L&summ2=m&#amendments',
      :link_type => "bill_amendments",
      :bill_ident => "hr3962", :congress=>111}    
  end

  def valid_bill_subjects
    {:website_url => "http://thomas.loc.gov/cgi-bin/bdquery/z?d111:HR03962:@@@J", 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => 'http://thomas.loc.gov/cgi-bin/bdquery/z?d111:hr3962:@@@J',
      :link_type => "bill_subjects",
      :bill_ident => "hr3962", :congress=>111}    
  end

  def valid_bill_crs_summary
    {:website_url => "http://thomas.loc.gov/cgi-bin/bdquery/z?d111:HR03962:@@@D&summ2=m&", 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => 'http://thomas.loc.gov/cgi-bin/bdquery/z?d111:hr3962:@@@D&summ2=m&',
      :link_type => "bill_crs_summary",
      :bill_ident => "hr3962", :congress=>111}    
  end

  def valid_bill_committees
    {:website_url => "http://thomas.loc.gov/cgi-bin/bdquery/z?d111:HR03962:@@@C", 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => 'http://thomas.loc.gov/cgi-bin/bdquery/z?d111:hr3962:@@@C',
      :link_type => "bill_committees",
      :bill_ident => "hr3962", :congress=>111}    
  end

  def valid_bill_major_actions
    {:website_url => "http://thomas.loc.gov/cgi-bin/bdquery/z?d111:HR03962:@@@R", 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => 'http://thomas.loc.gov/cgi-bin/bdquery/z?d111:hr3962:@@@R',
      :link_type => "bill_major_actions",
      :bill_ident => "hr3962", :congress=>111}    
  end

  def valid_bill_all_actions
    {:website_url => "http://thomas.loc.gov/cgi-bin/bdquery/z?d111:HR03962:@@@X", 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => 'http://thomas.loc.gov/cgi-bin/bdquery/z?d111:hr3962:@@@X',
      :link_type => "bill_all_actions",
      :bill_ident => "hr3962", :congress=>111}    
  end

  def valid_bill_all_actions_amend
    {:website_url => "http://thomas.loc.gov/cgi-bin/bdquery/z?d111:HR03962:@@@S", 
      :ip_address => '192.168.1.1', 
      :thomas_permalink => 'http://thomas.loc.gov/cgi-bin/bdquery/z?d111:hr3962:@@@S',
      :link_type => "bill_all_actions_amend",
      :bill_ident => "hr3962", :congress=>111}    
  end

  def expired_website_url
    {:website_url => "http://thomas.loc.gov/cgi-bin/bdquery/D?d111:2:./temp/~bd5CYL::|/bss/|"}    
  end
  
  
end
