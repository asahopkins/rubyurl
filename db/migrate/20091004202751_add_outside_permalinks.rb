class AddOutsidePermalinks < ActiveRecord::Migration
  def self.up
    add_column :links, :thomas_permalink, :string
    add_column :links, :opencongress_link, :string
    add_column :links, :bill_congress, :integer
    add_column :links, :bill_ident, :string
    add_column :links, :bill_title, :string
  end

  def self.down
    remove_column :links, :bill_title
    remove_column :links, :bill_ident
    remove_column :links, :bill_congress
    remove_column :links, :opencongress_link
    remove_column :links, :thomas_permalink
  end
end
