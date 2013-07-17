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

ActiveRecord::Schema.define(:version => 20130717041637) do

  create_table "customers", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "stripe_token"
    t.string   "stripe_customer_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.string   "city"
    t.string   "province_or_state"
    t.string   "country"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "rentals", :force => true do |t|
    t.string   "device_name"
    t.string   "location_detail"
    t.integer  "days"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "subtotal"
    t.integer  "tax_amount"
    t.integer  "grand_total"
    t.string   "currency"
    t.integer  "customer_id"
    t.integer  "location_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "taxes", :force => true do |t|
    t.string   "name"
    t.integer  "rate"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
