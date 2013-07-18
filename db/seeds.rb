Tax.create(:name => "GST", :rate => 5)

Tax.create(:name => "PST", :rate => 7)

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