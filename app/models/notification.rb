class Notification < ActiveRecord::Base
	attr_accessible :message, :hours_before_rental_ends, :hour_on_last_day

	has_and_belongs_to_many :locations

	validates :message, :presence => true
	validate :has_only_one_time_column

	def has_only_one_time_column
		if hours_before_rental_ends && hour_on_last_day || hours_before_rental_ends.nil? && hour_on_last_day.nil?
			errors.add(:notification_time, "need to have only one time setting")
		end
	end
end