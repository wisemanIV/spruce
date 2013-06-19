class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :url
      t.integer :follower_count
      t.integer :retweet_count
      t.integer :favorite_count
      t.integer :fb_total_count
      t.integer :fb_like_count
      t.integer :fb_comment_count
      t.integer :fb_share_count
      t.string :username
      t.references :user

      t.timestamps
    end
    
    add_column :links, :status_id, :bigint
  end
end
