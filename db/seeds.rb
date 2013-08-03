gst = Tax.create(:name => "GST", :rate => 5)

pst = Tax.create(:name => "PST", :rate => 7)

Location.create(
	:name => "Nuvo Hotel",
	:location_type => "Hotel",
	:city => "Calgary",
	:province_or_state => "Alberta",
	:country => "Canada"
)

Location.create(
	:name => "Shangri-La",
	:location_type => "Hotel",
	:city => "Vancouver",
	:province_or_state => "British Columbia",
	:country => "Canada"
)

Device.create(
	:name => "iPad Alpha",
	:profile_value => "584342051651322821",
	:device_type => "iPad 2"
)