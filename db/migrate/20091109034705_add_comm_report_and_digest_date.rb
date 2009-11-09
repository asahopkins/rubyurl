class AddCommReportAndDigestDate < ActiveRecord::Migration
  def self.up
    add_column :links, :digest_date, :datetime
    add_column :links, :report_ident, :string
  end

  def self.down
    remove_column :links, :report_ident
    remove_column :links, :digest_date
  end
end
