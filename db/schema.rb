# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110927142610) do

  create_table "votes", do |t|
    t.string "fbid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index( "votes", "fbid", :unique => true )

  create_table "soccers", do |t|
    t.string "fbid"
    t.integer "point", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index( "soccers", "fbid", :unique => true )
  
  create_table "icehockeys", do |t|
    t.string "fbid"
    t.integer "point", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index( "icehockeys", "fbid", :unique => true )
  
  create_table "baseballs", do |t|
    t.string "fbid"
    t.integer "point", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index( "baseballs", "fbid", :unique => true )
  
  create_table "basketballs", do |t|
    t.string "fbid"
    t.integer "point", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index( "basketballs", "fbid", :unique => true )

  create_table "americanfootballs", do |t|
    t.string "fbid"
    t.integer "point", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index( "americanfootballs", "fbid", :unique => true )
end
