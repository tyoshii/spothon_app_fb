class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.string :fbid
      t.integer :soccer,     :default => 0
      t.integer :baseball,   :default => 0
      t.integer :icehockey,  :default => 0
      t.integer :basketball, :default => 0
      t.integer :football,   :default => 0
      t.integer :rugby,      :default => 0
      t.integer :cricket,    :default => 0
      t.timestamps
    end
  end
end
