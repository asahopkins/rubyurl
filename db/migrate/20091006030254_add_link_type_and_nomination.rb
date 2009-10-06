class AddLinkTypeAndNomination < ActiveRecord::Migration
  def self.up
    add_column :links, :link_type, :string
    add_column :links, :nomination, :string
    add_column :links, :comm_report, :string
    add_column :links, :cr_page, :string
  end

  def self.down
    remove_column :links, :cr_page
    remove_column :links, :comm_report
    remove_column :links, :nomination
    remove_column :links, :link_type
  end
end
