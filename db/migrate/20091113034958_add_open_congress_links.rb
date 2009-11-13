class AddOpenCongressLinks < ActiveRecord::Migration
  def self.up
    Link.all(:conditions => {:opencongress_link => nil, :link_type => 'bill'}).each do |link|
      link.generate_opencongress_permalink
      link.save
    end
  end

  def self.down
    Link.all(:conditions => {:link_type => 'bill'}).each do |link|
      link.opencongress_link = nil
      link.save
    end
  end
end
