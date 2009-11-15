class AddSiteToVisit < ActiveRecord::Migration
  def self.up
    add_column :visits, :site, :string
  end

  def self.down
    remove_column :visits, :site
  end
end
