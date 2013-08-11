gst = Tax.create(:name => "GST", :rate => 5)
pst = Tax.create(:name => "PST", :rate => 7)
hst = Tax.create(:name => "HST", :rate => 12)

nuvo = Location.create(
	:name => "Nuvo Hotel",
	:location_type => "Hotel",
	:city => "Calgary",
	:province_or_state => "Alberta",
	:country => "Canada",
)

shangri_la = Location.create(
	:name => "Shangri-La",
	:location_type => "Hotel",
	:city => "Vancouver",
	:province_or_state => "British Columbia",
	:country => "Canada"
)

king_west = Location.create(
	:name => "1 King West",
	:location_type => "Hotel",
	:city => "Toronto",
	:province_or_state => "Ontario",
	:country => "Canada"
)

simulator = Device.create(
	:name => "iPad Simulator",
	:profile_value => "584342051651323254",
	:device_type => "Simulator"
)

alpha = Device.create(
	:name => "iPad Alpha",
	:profile_value => "584342051651323254",
	:device_type => "iPad 2"
)

bravo = Device.create(
	:name => "iPad Bravo",
	:profile_value => "584342051651323755",
	:device_type => "iPad 4"
)