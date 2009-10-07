class Link < ActiveRecord::Base
  TOKEN_LENGTH = 4
  
  has_many :visits
  has_many :spam_visits, :class_name => 'Visit', :conditions => ["flagged = 'spam'"]
  
  validates_presence_of :website_url, :ip_address, :link_type, :thomas_permalink
  validates_uniqueness_of :website_url, :token  
  # validates_format_of :website_url, :with => /^(http|https):\/\/[a-z0-9]/ix, :on => :save, :message => 'needs to have http(s):// in front of it', :if => Proc.new { |p| p.website_url? }
  validates_format_of :website_url, :with => /^http:\/\/thomas.loc.gov\/[a-z0-9]/ix, :on => :save, :message => 'needs to start with http://thomas.loc.gov/', :if => Proc.new { |p| p.website_url? }
  
  before_create :generate_token
  before_create :generate_thomas_permalink
  before_create :generate_opencongress_permalink
  
  def flagged_as_spam?
    self.spam_visits.empty? ? false : true
  end
  
  def add_visit(request)
    visit = visits.build(:ip_address => request.remote_ip)
    visit.save
    return visit
  end
  
  def Link.find_or_create_by_url (website_url)
    ltype = Link.id_document_type(website_url)
    if ltype == "none"
      return Link.new
    else
      c = Curl::Easy.perform(website_url).body_str
      doc = Hpricot(c)
      n = (website_url =~ /\?/)
      case ltype
      when "bill"
        congress = website_url[n+2..n+4].to_i
        bill_id = (doc/"div#content"/"b")[0].inner_html
        if bill_id[0..3] == "Item"
          bill_id = (doc/"div#content"/"b")[1].inner_html
        end
        link = Link.find_or_create_by_congress_and_bill_ident(congress, bill_id)
      when "nomination"
        doc.inner_html =~ /Control\s+Number:\s+<\/span>\w+/
        s_full= $&
        s_full =~ /\w+$/
        s = $&
        link = Link.find_or_create_by_nomination(s)
      when "cong_record"
        congress = website_url[n+2..n+4].to_i
        doc.inner_html =~ /Page:\s+[HSED]\d+\]/
        s = $&
        page = s[6...-1]
        t = page[0..0]
        p = page[1..-1].to_i
        # puts p
        doc.inner_html =~ /(January|February|March|April|May|June|July|August|September|October|November|December)\s+\d+,\s+\d+/
        year = $&[-4..-1].to_i
        # puts year
        if (year % 2) == 0
          # puts "second session"
          p = p+50000
        else
          # puts "first session"
        end
        p_s = p.to_s
        while p_s.length < 5
          p_s = "0"+p_s
        end
        cr_page =t+p_s
        link = Link.find_or_create_by_congress_and_cr_page(congress, cr_page)        
      when "comm_report"
        
      when "bill_text"
        
      when "record_digest"
        
      end
      link.website_url = website_url if link.new_record?
      link.link_type = ltype if link.new_record?
      link.generate_token
      link.generate_thomas_permalink
      link.generate_opencongress_permalink
      return link
    end    
  end

  def to_api_xml
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.link do
      xml.tag!( :website_url, self.website_url )
      xml.tag!( :permalink, self.permalink )
      xml.tag!( :thomas_permalink, self.thomas_permalink )
    end
  end
  
  def to_api_json
    self.to_json( :only => [ :website_url, :permalink, :thomas_permalink ] )
  end
  
  # possible return values: bill, bill_text, cong_record, comm_report, nomination, record_digest, none
  def Link.id_document_type(website_url)
    n = (website_url =~ /\?/)
    return "none" if n.nil? or n == false
    return "bill" if (website_url[n-1..n] == "z?" or website_url[n-1..n] == "D?") and website_url[n..n+1] =="?d"
    return "bill_text" if (website_url[n-1..n] == "z?" and website_url[n..n+1] =="?c")
    return "cong_record" if (website_url[n-1..n] == "C?" or website_url[n-1..n] == "D?") and website_url[n..n+1] =="?r"
    return "cong_record" if (website_url[n-1..n] == "z?" and website_url[n..n+1] =="?r")
    return "nomination" if (website_url[n-1..n] == "D?" and website_url[n..n+5] =="?nomis")
    return "comm_report" if (website_url[n-1..n] == "5?" and website_url[n..n+2] =="?cp")
    return "record_digest" if (website_url[n-1..n] == "B?" and website_url[n..n+1] =="?r")
    return "none"
  end

  def generate_token
    if (temp_token = random_token) and self.class.find_by_token(temp_token).nil?
      self.token = temp_token
      build_permalink
    else
      generate_token
    end
  end

  def generate_thomas_permalink
    case link_type
    when "bill"
      self.thomas_permalink = "http://thomas.loc.gov/cgi-bin/bdquery/z?d"+congress.to_s+":"+bill_ident+":"
    when "nomination"
      self.thomas_permalink = "http://thomas.loc.gov/cgi-bin/ntquery/z?nomis:"+nomination+":"        
    when "cong_record"
      self.thomas_permalink = "http://thomas.loc.gov/cgi-bin/query/R?r"+congress.to_s+":FLD001:"+cr_page       
    end
  end
  
  def generate_opencongress_permalink
    
  end

  private
    
    def build_permalink
      self.permalink = DOMAIN_NAME + self.token
    end
  
    def random_token
      characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890'
      temp_token = ''
      srand
      TOKEN_LENGTH.times do
        pos = rand(characters.length)
        temp_token += characters[pos..pos]
      end
      temp_token
    end
    
    
    
end

