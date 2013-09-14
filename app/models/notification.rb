class Notification < ActiveRecord::Base
	attr_accessible :message, :hours_before_rental_ends, :hour_on_last_day, :location_ids, :url

	has_and_belongs_to_many :locations

	validates :message, :presence => true
	validate :has_only_one_time_column
	validate :legitimate_hours_before_rental_ends
	validate :legitimate_hour_on_last_day

	def has_only_one_time_column
		if hours_before_rental_ends && hour_on_last_day || hours_before_rental_ends.nil? && hour_on_last_day.nil?
			errors.add(:notification_time, "need to have only one time setting")
		end
	end

	def legitimate_hours_before_rental_ends
		if (hours_before_rental_ends && hours_before_rental_ends < 0) || (hours_before_rental_ends && hours_before_rental_ends != 99)
			errors.add(:hours_before_rental_ends, "need to be greater than 0 or equal 99")
		end
	end

	def legitimate_hour_on_last_day
		if hour_on_last_day && (hour_on_last_day >=24 || hour_on_last_day < 0)
			errors.add(:hour_on_last_day, "need to be less than 24 and greater than 0")
		end
	end

	def display_time_in_words
		if hours_before_rental_ends
			return "#{hours_before_rental_ends} hour#{'s' if hours_before_rental_ends != 1} before rental ends"
		elsif hour_on_last_day
			return "#{hour_on_last_day}:00 on the last day of the rental"
		else
			return "No time specified"
		end
	end

	def message_and_time_in_words
		"#{message} | Displayed: #{display_time_in_words}"
	end
end