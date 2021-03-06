class AddBillTextOpencongressLinks < ActiveRecord::Migration
  def self.up
    Link.all(:conditions => {:opencongress_link => nil, :link_type => 'bill_text'}).each do |link|
      link.bill_ident = link.bill_ident.downcase.gsub(/\./,"")
      link.generate_opencongress_permalink
      link.save
    end
  end

  def self.down
    Link.all(:conditions => {:link_type => 'bill_text'}).each do |link|
      link.opencongress_link = nil
      link.save
    end
  end
end
