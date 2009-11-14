class AddBillVersion < ActiveRecord::Migration
  def self.up
    add_column :links, :bill_version, :string, :default=>nil
  end

  def self.down
    remove_column :links, :bill_version
  end
end
