$(document).ready(function() {
	$('.phone').hover(function() {
		$("#phone_icon").toggle()
		$("#phone_icon_hover").toggle()
	}, function() {
		$("#phone_icon").toggle()
		$("#phone_icon_hover").toggle()
	});

	$('.email').hover(function() {
		$("#email_icon").toggle()
		$("#email_icon_hover").toggle()
	}, function() {
		$("#email_icon").toggle()
		$("#email_icon_hover").toggle()
	});
});