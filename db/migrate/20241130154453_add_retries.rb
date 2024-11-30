class AddRetries < ActiveRecord::Migration[7.0]
  def change
    add_column :videos, :retries, :integer, :default => 0
  end
end
