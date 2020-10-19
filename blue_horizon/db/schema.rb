# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema
# definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more
# migrations you'll amass, the slower it'll run and the greater likelihood for
# issues).
#
# It's strongly recommended that you check this file into your version control
# system.

ActiveRecord::Schema.define(version: 20191025213201) do
  create_table 'key_values', force: :cascade do |t|
    t.string 'key', null: false
    t.text 'value'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['key'], name: 'index_key_values_on_key', unique: true
  end

  create_table 'sources', force: :cascade do |t|
    t.string 'filename'
    t.text 'content'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['filename'], name: 'index_sources_on_filename'
  end
end
