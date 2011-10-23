"use strict";
YUI().use('node','io','overlay','json',function(Y) {
	var overlay = new Y.Overlay({
		srcNode:'#map_overlay',
		xy: [20,60],
		bodyContent: '<div id="location_map"></div>',
		footerContent:'<span class="button"><span class="submit"><button type="button" id="useThisLocation">Use this location</button></span></span><span class="button"><span class="cancel"><button type="button">Cancel</button</div></div>',
	});
	overlay.render();
	overlay.hide();
	Y.on('click',Y.bind(overlay.hide, overlay),'#map_overlay .cancel button');
	Y.one('#location-panel .changeLocationButton').append(
		'<span class="button"><span class="edit"><a id="openMapButton">Open Map</a></span></span>'
	);
	Y.on('click',function(e) {
		e.preventDefault();
		overlay.show();
		var geocoder = new google.maps.Geocoder();
		var map = new google.maps.Map(document.getElementById('location_map'), {
			zoom: 14,
			center: new google.maps.LatLng(DEFAULT_LATITUDE, DEFAULT_LONGITUDE),
			mapTypeId: google.maps.MapTypeId.ROADMAP
		});
		/*
		if (navigator.geolocation) {
			navigator.geolocation.getCurrentPosition(function(position) {
				map.setCenter(new google.maps.LatLng(
					position.coords.latitude,position.coords.longitude
				));
			});
		}
		*/
		var crosshairs = new google.maps.Marker({
			map: map,
			icon:'cross-hairs-small-yellow-cropped.png'
		});
		crosshairs.bindTo('position',map,'center');

		Y.on('click',function(e) {
			document.getElementById('ticket-latitude').value = map.getCenter().lat();
			document.getElementById('ticket-longitude').value = map.getCenter().lng();
			geocoder.geocode({latLng:map.getCenter()}, function(results,status) {
				if (status == google.maps.GeocoderStatus.OK) {
					if (results[0]) {
						for (var i=0; i<results[0].address_components.length; i++) {
							switch (results[0].address_components[i].types[0]) {
								case 'street_number':
									document.getElementById('ticket-location').value = results[0].address_components[i].long_name + ' ';
									break;
								case 'route':
									document.getElementById('ticket-location').value += results[0].address_components[i].long_name;
									break;
								case 'locality':
									document.getElementById('ticket-city').value = results[0].address_components[i].long_name;
									break;
								case 'administrative_area_level_1':
									document.getElementById('ticket-state').value = results[0].address_components[i].short_name;
									break;
								case 'postal_code':
									document.getElementById('ticket-zip').value = results[0].address_components[i].long_name;
									break;
							}
						}
					}
				}
			});
			overlay.hide();
		},'#useThisLocation');
	},'#openMapButton');
});
