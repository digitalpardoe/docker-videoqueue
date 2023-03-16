class CreateVideos < ActiveRecord::Migration[7.0]
  def change
    create_table :videos do |t|
      t.string :url
      t.boolean :downloaded
      t.timestamps
    end
  end
end
