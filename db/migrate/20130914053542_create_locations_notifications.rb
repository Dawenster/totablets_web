class CreateLocationsNotifications < ActiveRecord::Migration
  def change
  	create_table :locations_notifications do |t|
      t.belongs_to :location
      t.belongs_to :notification
    end
  end
end
