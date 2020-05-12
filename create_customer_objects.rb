class CreateCustomerObjects < ActiveRecord::Migration
  def up
    create_table "address_types", :force => true do |t|
      t.string   "type_name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "addresses", :force => true do |t|
      t.integer  "address_type_id"
      t.integer  "customer_id",                                      :null => false
      t.string   "first_name"
      t.string   "address1",                                         :null => false
      t.string   "address2"
      t.string   "city",                                             :null => false
      t.integer  "state_id"
      t.string   "state_name"
      t.string   "zip_code",                                         :null => false
      t.boolean  "is_default",                    :default => false
      t.boolean  "active",                        :default => true
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "last_name",       :limit => 45
    end

    add_index "addresses", ["customer_id"], :name => "index_addresses_on_customer_id"
    add_index "addresses", ["state_id"], :name => "index_addresses_on_state_id"

    create_table "card_types", :force => true do |t|
      t.string   "type_name"
      t.string   "type_abbr",  :limit => 10
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "countries", :force => true do |t|
      t.string   "country_name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "credit_cards", :force => true do |t|
      t.integer  "customer_id"
      t.integer  "card_type_id"
      t.string   "card_num"
      t.string   "last_4"
      t.date     "exp_date"
      t.string   "verification_code"
      t.string   "card_name"
      t.string   "address"
      t.string   "city"
      t.string   "state"
      t.string   "zip_code"
      t.integer  "state_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "address2"
      t.string   "encrypted_card_num"
      t.string   "first_name"
      t.string   "last_name"
    end

    create_table "customer_referers", :force => true do |t|
      t.integer  "customer_id"
      t.string   "referer"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "customer_sponsor_types", :force => true do |t|
      t.string   "type_name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "customer_sponsors", :force => true do |t|
      t.integer  "customer_id"
      t.integer  "customer_sponsor_type_id"
      t.integer  "sponsor_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "customer_title_group_groups", :force => true do |t|
      t.integer  "customer_group_id"
      t.integer  "sponsor_group_id"
      t.decimal  "percentage",        :precision => 10, :scale => 2
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "customer_title_groups", :force => true do |t|
      t.string  "group_name",      :limit => 45
      t.decimal "personal_volume",               :precision => 10, :scale => 2
    end

    create_table "customer_titles", :force => true do |t|
      t.string   "title_name"
      t.float    "discount"
      t.text     "title_desc"
      t.integer  "level"
      t.boolean  "inactive"
      t.integer  "customer_title_group_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "customer_types", :force => true do |t|
      t.string   "type_name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "customers", :force => true do |t|
      t.integer  "customer_type_id"
      t.string   "company_name"
      t.string   "last_name"
      t.string   "first_name"
      t.string   "middle_initial"
      t.datetime "dob"
      t.string   "spouse_first_name"
      t.string   "spouse_last_name"
      t.datetime "spouse_dob"
      t.datetime "customer_date"
      t.string   "phone"
      t.string   "fax"
      t.string   "email"
      t.integer  "customer_title_id"
      t.boolean  "active"
      t.string   "resell_num"
      t.string   "pw"
      t.string   "ssn"
      t.integer  "sponsor_id"
      t.integer  "silver_id"
      t.integer  "gold_id"
      t.integer  "plat_id"
      t.string   "comments"
      t.string   "user_comments"
      t.string   "referrer_link"
      t.integer  "customer_check_type_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "crypted_password"
      t.string   "password_salt"
      t.string   "persistence_token"
      t.integer  "login_count",                             :default => 0
      t.datetime "last_request_at"
      t.datetime "last_login_at"
      t.datetime "current_login_at"
      t.string   "last_login_ip"
      t.string   "current_login_ip"
      t.string   "access_token"
      t.string   "referred_by"
      t.string   "dist_photo_file_name"
      t.string   "dist_photo_content_type"
      t.integer  "dist_photo_file_size"
      t.datetime "dist_photo_updated_at"
      t.string   "store_url"
      t.string   "store_name"
      t.string   "store_title"
      t.text     "store_desc"
      t.string   "store_meta_title"
      t.text     "store_meta_tags"
      t.string   "recommended_products_text"
      t.string   "reset_password_token",      :limit => 45
      t.datetime "reset_password_updated_at"
      t.string   "store_location",            :limit => 45
      t.string   "store_welcome",             :limit => 45
      t.text     "store_meta_tags"
      t.boolean  "email_me",                  :limit => 1
    end

    add_index "customers", ["access_token"], :name => "access_token_UNIQUE", :unique => true

    create_table "customers_roles", :force => true do |t|
      t.integer "customer_id"
      t.integer "role_id"
    end

    create_table "roles", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "states", :force => true do |t|
      t.string  "name",                                                     :null => false
      t.string  "abbreviation", :limit => 5,                                :null => false
      t.integer "country_id",                                               :null => false
      t.decimal "tax_rate",                  :precision => 10, :scale => 4
    end

    add_index "states", ["abbreviation"], :name => "index_states_on_abbreviation"
    add_index "states", ["country_id"], :name => "index_states_on_country_id"
    add_index "states", ["name"], :name => "index_states_on_name"

  end
  def down
    drop_table :address_types
    drop_table :addresses
    drop_table :card_types
    drop_table :countries
    drop_table :credit_cards
    drop_table :customer_referers
    drop_table :customer_sponsor_types
    drop_table :customer_sponsors
    drop_table :customer_title_groups
    drop_table :customer_title_group_groups
    drop_table :customer_titles
    drop_table :customer_types
    drop_table :customers
    drop_table :customers_roles
    drop_table :roles
    drop_table :states

  end
end