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

ActiveRecord::Schema.define(:version => 20130914053542) do

  create_table "admin_accesses", :force => true do |t|
    t.string   "device_name_during_access"
    t.string   "location_during_access"
    t.string   "action"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "customers", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "stripe_token"
    t.string   "stripe_customer_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "devices", :force => true do |t|
    t.string   "name"
    t.string   "profile_value"
    t.string   "device_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "location_id"
    t.string   "admin_password"
  end

  create_table "key_inputs", :force => true do |t|
    t.integer  "rate"
    t.integer  "pre_auth_amount"
    t.text     "terms_and_conditions"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.string   "location_type"
    t.string   "city"
    t.string   "province_or_state"
    t.string   "country"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "currency"
    t.string   "timezone"
  end

  create_table "locations_notifications", :force => true do |t|
    t.integer "location_id"
    t.integer "notification_id"
  end

  create_table "locations_taxes", :force => true do |t|
    t.integer "location_id"
    t.integer "tax_id"
  end

  create_table "notifications", :force => true do |t|
    t.string   "message"
    t.integer  "hours_before_rental_ends"
    t.integer  "hour_on_last_day"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "pre_auths", :force => true do |t|
    t.string   "stripe_pre_auth_id"
    t.integer  "pre_auth_amount"
    t.integer  "captured_amount",    :default => 0
    t.text     "description"
    t.integer  "rental_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "rentals", :force => true do |t|
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
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.integer  "rate"
    t.integer  "tax_rate"
    t.integer  "device_id"
    t.boolean  "finished"
    t.string   "stripe_rental_charge_id"
    t.text     "terms_and_conditions"
  end

  create_table "rentals_taxes", :force => true do |t|
    t.integer "rental_id"
    t.integer "tax_id"
  end

  create_table "taxes", :force => true do |t|
    t.string   "name"
    t.integer  "rate"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
