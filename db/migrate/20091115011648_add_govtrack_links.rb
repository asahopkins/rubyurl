class AddGovtrackLinks < ActiveRecord::Migration
  def self.up
    Link.all(:conditions => {:govtrack_link => nil, :link_type => 'bill'}).each do |link|
      link.generate_govtrack_link
      link.save
    end
    Link.all(:conditions => {:govtrack_link => nil, :link_type => 'bill_text'}).each do |link|
      link.generate_govtrack_link
      link.save
    end
  end

  def self.down
    Link.all(:conditions => {:link_type => 'bill'}).each do |link|
      link.govtrack_link = nil
      link.save
    end
    Link.all(:conditions => {:link_type => 'bill_text'}).each do |link|
      link.govtrack_link = nil
      link.save
    end
  end
end
