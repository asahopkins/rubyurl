class AddGovtrackLink < ActiveRecord::Migration
  def self.up
    add_column :links, :govtrack_link, :string, :default=>nil
  end

  def self.down
    remove_column :links, :govtrack_link
  end
end
