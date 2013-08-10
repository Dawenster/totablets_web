class AdminAccess < ActiveRecord::Base
	attr_accessible :device_name_during_access, :location_during_access, :action
end