class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.integer :baseball
      t.integer :golf
      t.timestamps
    end
  end
end
