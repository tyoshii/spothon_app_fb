class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.string :fbid
      t.integer :baseball
      t.integer :golf
      t.timestamps
    end
  end
end
