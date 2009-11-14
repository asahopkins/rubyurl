class Link < ActiveRecord::Base
  TOKEN_LENGTH = 4
  
  has_many :visits
  has_many :spam_visits, :class_name => 'Visit', :conditions => ["flagged = 'spam'"]
  
  validates_presence_of :website_url, :ip_address, :link_type, :thomas_permalink
  validates_uniqueness_of :website_url, :token  
  # validates_format_of :website_url, :with => /^(http|https):\/\/[a-z0-9]/ix, :on => :save, :message => 'needs to have http(s):// in front of it', :if => Proc.new { |p| p.website_url? }
  validates_format_of :website_url, :with => /^http:\/\/(thomas|hdl).loc.gov\/[a-z0-9]/ix, :on => :save, :message => 'needs to start with http://thomas.loc.gov/', :if => Proc.new { |p| p.website_url? }
  
  before_create :generate_token
  # before_create :generate_thomas_permalink
  # before_create :generate_opencongress_permalink
  
  def flagged_as_spam?
    self.spam_visits.empty? ? false : true
  end
  
  def add_visit(request)
    visit = visits.build(:ip_address => request.remote_ip)
    visit.save
    return visit
  end
  
  def Link.find_or_create_by_url(website_url)
    l = Link.find_by_website_url(website_url)
    return l if l
    ltype = Link.id_document_type(website_url)
    if ltype == "none"
      return Link.new
    else
      c = Curl::Easy.perform(website_url).body_str
      doc = Hpricot(c)
      n = (website_url =~ /\?/)
      m = (website_url =~ /n\./)
      case ltype
      when "bill"
        if n
          congress = website_url[n+2..n+4].to_i
          if (doc/"div#content"/"b")[0]
            bill_id = (doc/"div#content"/"b")[0].inner_html.downcase.gsub(/\./,"")
            if bill_id[0..3] == "item"
              bill_id = (doc/"div#content"/"b")[1].inner_html.downcase.gsub(/\./,"")
            end
          else
            return website_url
          end
        elsif m #handle redirect
          congress = website_url[m+2..m+4].to_i
          bill_id = website_url[m+5..-1].downcase.gsub(/\./,"")
        else
          return Link.new
        end
        link = Link.find_or_create_by_congress_and_bill_ident_and_link_type(congress, bill_id, ltype)
      when "nomination"
        if doc.inner_html =~ /Control\s+Number:\s+<\/span>\w+/
          s_full = $&
          s_full =~ /\w+$/
          s = $&
          congress = s[0..2].to_i
          link = Link.find_or_create_by_congress_and_nomination_and_link_type(congress, s, ltype)
        else
          return website_url
        end
      when "cong_record"
        # TODO: give better permalinks for CR pages with Next and Previous links (to get down to remarks rather than pages)
        congress = website_url[n+2..n+4].to_i
        if doc.inner_html =~ /Page:\s+[HSED]\d+\]/
          s = $&
          page = s[6...-1]
          t = page[0..0]
          p = page[1..-1].to_i
        elsif doc.inner_html =~ /Page\s+[HSED]\d+/
          s = $&
          page = s[5..-1]
          t = page[0..0]
          p = page[1..-1].to_i          
        else
          return website_url
        end
        doc.inner_html =~ /(January|February|March|April|May|June|July|August|September|October|November|December)\[*\s+\d+,\s+\d+/
        year = $&[-4..-1].to_i
        if (year % 2) == 0
          # second session
          p = p+50000
        else
          # first session
        end
        p_s = p.to_s
        while p_s.length < 5
          p_s = "0"+p_s
        end
        cr_page =t+p_s
        link = Link.find_or_create_by_congress_and_cr_page_and_link_type(congress, cr_page, ltype)        
      when "comm_report"
        if doc.inner_html =~ /(Senate|House)\s+Report\s+\d+\-\d+/
          s = $&
          s =~ /^(Senate|House)/
          body = $&
          s =~ /\d+$/
          report_num = $&
          s =~ /\d+\-/
          congress = $&
          congress = congress[0..2].to_i
          if body == "House"
            report_ident = "hr"+report_num
          elsif body == "Senate"
            report_ident = "sr"+report_num            
          else
            return Link.new
          end
          link = Link.find_or_create_by_congress_and_report_ident_and_link_type(congress, report_ident, ltype)
        else
          return website_url
        end
      when "bill_text" #TODO
        congress = website_url[n+2..n+4].to_i
        if doc.inner_html =~ /cong_bills&docid=f:(h|s)(\w|\d)+\.txt\.pdf/
          s = $&
          s =~ /(h|s)(\w|\d)+/
          t = $&
          t =~ /[a-zA-Z]*$/
          bill_version = $&.downcase.gsub(/\./,"")
          t =~ /^(h|s)[a-zA-Z]*\d+/
          bill_ident = $&
          m = (bill_ident =~ /\d+/)
          bill_ident = (Link.type_translate[bill_ident[0..m-1]]+bill_ident[m..-1]).downcase.gsub(/\./,"")
          link = Link.find_or_create_by_congress_and_bill_ident_and_link_type_and_bill_version(congress, bill_ident, ltype, bill_version)
        elsif doc.inner_html =~ /a\shref="\/cgi-bin\/bdquery\/z\?d\d+:(s|h)(\w|\d|\.)+:">/ix
          # TODO this section is not tested -- I'm not sure if there are bill text pages that don't have the PDF link but do have the summary and status link
          s = $s
          s =~ /(h|s)(\w|\d)+/
          t = $&
          t =~ /^(h|s)[a-zA-Z]*\d+/
          bill_ident = $&.downcase.gsub(/\./,"")
          link = Link.find_or_create_by_congress_and_bill_ident_and_link_type(congress, bill_ident, ltype)
        elsif website_url =~ /F\?c/
          link_text = ""
          (doc/"div#content"/"a").each do |a|
            if a.html.strip == "Contents Display"
              link_text = a['href'].to_s
              break
            end
          end
          unless link_text == ""
            new_url = "http://thomas.loc.gov"+link_text
            link = Link.find_or_create_by_url(new_url)
          else
            return Link.new
          end
        elsif website_url =~ /z\?c\d+:(h|s)(\w|.)*\d+:$/ix
          # the url is already in permalink form
          s = $& #"z?c111:H.R.3200:"
          s =~ /(h|s)(\w|.)*\d+/ix
          bill_ident = $&.downcase.gsub(/\./,"")
          link = Link.find_or_create_by_congress_and_bill_ident_and_link_type(congress, bill_ident, ltype)
        else
          return Link.new
        end
      when "record_digest" # record_digests with other URL formats look like cong_records
        congress = website_url[n+2..n+4].to_i
        n = (website_url =~ /DDATE\+/)
        date_str = website_url[n+6..-2]
        digest_date = DateTime.civil(date_str[0..3].to_i, date_str[4..5].to_i, date_str[6..7].to_i)
        link = Link.find_or_create_by_congress_and_digest_date_and_link_type(congress, digest_date, ltype)
      end
      link.website_url = website_url
      if link.new_record?
        link.generate_token
        link.generate_thomas_permalink
        link.generate_opencongress_permalink        
      end
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
    if n.nil? or n == false
      n = (website_url =~ /hdl.loc.gov\/loc.uscongress\/legislation/)
      if n.nil? or n == false
        return "none"
      else
        return "bill"
      end
    end
    return "bill" if website_url =~ /\/(z|D)\?d\d/
    return "bill_text" if website_url =~ /\/(\d|z|D|F)\?c\d/
    return "cong_record" if website_url =~ /\/(z|C|D|R|F)\?r\d/
    return "nomination" if website_url =~ /\/(z|D)\?nomis/
    return "comm_report" if website_url =~ /\/(\d+|z|R)\?cp\d/
    return "comm_report" if website_url =~ /cpquery\/\?sel=(DOC|TOCLIST)/
    return "record_digest" if website_url =~ /\/B\?r\d\S+\)$/ # record_digests with other URL formats look like cong_records
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
#      self.thomas_permalink = "http://thomas.loc.gov/cgi-bin/bdquery/z?d"+congress.to_s+":"+bill_ident+":"
      self.thomas_permalink = "http://hdl.loc.gov/loc.uscongress/legislation."+congress.to_s+bill_ident.gsub(/\./,"").downcase
    when "nomination"
      self.thomas_permalink = "http://thomas.loc.gov/cgi-bin/ntquery/z?nomis:"+nomination+":"
    when "cong_record"
      self.thomas_permalink = "http://thomas.loc.gov/cgi-bin/query/R?r"+congress.to_s+":FLD001:"+cr_page
    when "record_digest"
      self.thomas_permalink = "http://thomas.loc.gov/cgi-bin/query/B?r"+congress.to_s+":@FIELD(FLD003+d)+@FIELD(DDATE+"+digest_date.strftime("%Y%m%d")+")"
    when "comm_report"
      self.thomas_permalink ="http://thomas.loc.gov/cgi-bin/cpquery/z?cp"+congress.to_s+":"+report_ident+"."+congress.to_s+":"
    when "bill_text"
      if bill_version
        self.thomas_permalink ="http://thomas.loc.gov/cgi-bin/query/z?c"+congress.to_s+":"+bill_ident+"."+bill_version+":"
      else
        self.thomas_permalink ="http://thomas.loc.gov/cgi-bin/query/z?c"+congress.to_s+":"+bill_ident+":"
      end
    end
  end
  
  def generate_opencongress_permalink
    unless congress < 109
      if link_type == "bill" or link_type == "bill_text"
        if m = bill_ident.match(/^(h|s)(re|j|c)/ix)
          type_abbrev = "#{m[1]}#{m[2][0..0]}".downcase
        elsif m = bill_ident.match(/^(HR|S)\d+/ix)
          type_abbrev = m[1][0..0].downcase
        else
          # OpenCongress doesn't have pages for amendments (e.g. H.AMDT.1)
          return
        end

        bill_num = bill_ident.gsub(/[^\d]+/, '')
        if link_type == "bill"
          self.opencongress_link = "http://www.opencongress.org/bill/#{congress.to_s}-#{type_abbrev}#{bill_num}/show"
        elsif link_type == "bill_text"
          self.opencongress_link = "http://www.opencongress.org/bill/#{congress.to_s}-#{type_abbrev}#{bill_num}/text"          
        end
      end
    else
      return
    end
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
    
    def Link.type_translate
      {"h"=>"hr","hr"=>"hres","s"=>"s","hc"=>"hconres","sr"=>"sres","sc"=>"sconres","sj"=>"sjres","hj"=>"hjres"}
    end
    
end

