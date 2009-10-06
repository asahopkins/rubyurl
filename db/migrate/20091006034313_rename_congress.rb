class RenameCongress < ActiveRecord::Migration
  def self.up
    rename_column :links, :bill_congress, :congress
  end

  def self.down
    rename_column :links, :congress, :bill_congress
  end
end
