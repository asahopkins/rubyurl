class AddLinkVisitCount < ActiveRecord::Migration
  def self.up
    add_column :links, :visits_count, :integer, :default=>0
    
    Link.reset_column_information
    Link.find(:all).each do |l|
      Link.update_counters l.id, :visits_count => l.visits.length
    end
    
  end

  def self.down
    remove_column :links, :visits_count
  end
end
