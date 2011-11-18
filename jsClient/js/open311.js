"use strict";
/**
 * @copyright 2011 City of Bloomington, Indiana
 * @license http://www.gnu.org/licenses/agpl.txt GNU/AGPL, see LICENSE.txt
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 */
var CLIENT = {
	endpoint: 'https://bloomington.in.gov/ureport/open311/v2',
	DEFAULT_LATITUDE: 39.169927,
	DEFAULT_LONGITUDE: -86.536806,
	service_name:'',
	service: {},
	overlay: {},
	init: function () {
		if (CLIENT.endpoint) {
			CLIENT.getServiceList(); 
		}
		else {
			alert('No open311 server defined');
		}
	},
	getServiceList: function () {
		YUI().use('io','json-parse', function (Y) {
			Y.on('io:complete', function (id, o, args) {
				var services = Y.JSON.parse(o.responseText);
				var html = '<form method="get"><fieldset><label>Choose a Service<select name="service_code" id="service_code" onchange="CLIENT.getServiceDefinition(this);">';
				html += '<option value="">Select Servie</option>';
				for (var i in services){
					html += '<option value="' + services[i].service_code + '">' + services[i].service_name + '</option>';
				}
				html += '</select></label></fieldset></form>';
				document.getElementById('mainContent').innerHTML = html;
			}, Y);
			Y.io(CLIENT.endpoint + '/services.json');
		});
 	},				
	getServiceDefinition: function (select) {
		CLIENT.service_name = select.options[select.selectedIndex].text;
		YUI().use('io', 'json-parse', function(Y) {
			Y.on('io:complete', function (id, o, args) {
				CLIENT.service = Y.JSON.parse(o.responseText);
				var html = '<h2>'+CLIENT.service_name+' Report</h2>'+
					'<form id="reportform" enctype="multipart/form-data">'+
					//'<form id="reportform">'+
					'	<fieldset id="allfields">'+				
					'		<input type="hidden" name="service_code" value="'+CLIENT.service.service_code+'" />'+
					'		<input type="hidden" name="jurisdiction_id" value="bloomington.in.gov" />'+
					'		<input type="hidden" name="address_id" id="address_id" value="" />'+
					'		<input type="hidden" name="address_string" id="address_string" value="" />'+					
					'		<input type="hidden" name="lat" id="lat" value="" /></td>'+
					'		<input type="hidden" name="long" id="long" value="" /></td>'+
					'		<table>'+
					'           <tr><td><div id="location"><a href="#" id="openMapButton">Choose a Location </a></td><td><strong><div id="addressstring"></div></strong></td></tr>   '+
					'			<tr><td><label for="media">Upload a file or picture</label></td>'+
					'				<td><input type="file" id="media" name="media" /></td>'+
					'			</tr>'+ 
					'			<tr>'+
					'				<td><label id="first_name">First Name</label></td>'+
					'				<td><input name="first_name" id="first_name" value="" /></td>'+
					'			</tr>'+
					'			<tr>'+
					'				<td><label id="last_name">Last Name</label></td>'+
					'				<td><input name="last_name" id="last_name" value="" /></td>'+
					'			</tr>'+								
					'			<tr>'+
					'				<td><label id="phone">Phone</label></td>'+
					'				<td><input name="phone" id="phone" value="" /></td>'+
					'			</tr>'+
					'			<tr>'+
					'				<td><label id="email">Email</label></td>'+
					'				<td><input name="email" id="email" value="" /></td>'+
					'			</tr>'+
					'			<tr>'+
					'				<td><label id="address">Address</label></td>'+
					'				<td><div id="addr_id"><input name="address" id="address" value="" /></div></td>'+
					'			</tr>'+
					'			<tr>'+
					'				<td><label id="description">Description</label></td>'+
					'				<td><textarea name="description" id="description"></textarea>'+
					'				</td>'+
					'			</tr>';				
				
				for (var i in CLIENT.service.attributes) {
					var field = CLIENT.service.attributes[i];
					var name = field.code;
					var description = field.description;					
					if(field.datatype){
						html += 
						'		<tr><td><label for="'+name+'">'+description+'</label></td><td>';													
						switch(field.datatype){
							case 'singlevaluelist':
								html +=
								'			<select name="'+name+'" id="'+name+'">'+
								'				<option value=""></option>';
								for(var j in field.values){
									var key = field.values[j].key;
									var value = field.values[j].name;
									html += '				<option value="'+key+'">'+value+'</optoin>';						
								}
								html +=
								'			</select>';
								break;
							case 'multivaluelist':
								html +=
								'			<select multiple="multiple" name="'+name+'" id="'+name+'">'+
								'				<option value=""></option>';
								for(j in field.values){
									var key = field.values[j].key;
									var value = field.values[j].name;
									html += '				<option value="'+key+'">'+value+'</optoin>';						
								}
								html += '			</select>';
								break;
							case 'text':
								html += '			<textarea name="'+name+'" id="'+name+'"></textarea>';
								break;
							case 'string':
							case 'number':
							case 'datetime':
							default:	
								html += '			<input id="'+name+'" name="'+name+'" value="" />';
						}
						html +=
							'			</td></tr>';
					}
					else{
						html += '			<input id="'+name+'" name="'+name+'" value="" />';
					}
					html += '			</td></tr>';
				}
			html += '		</table>'+
					'		<div id="submit">'+
					'			<input type="submit" value="Report" />'+
					'		</div>'+
					'	</fieldset>'+
					'</form>';					
				document.getElementById('mainContent').innerHTML = html;
				document.getElementById('reportform').addEventListener('submit',CLIENT.postServiceRequest, false);
				
			});
			Y.io(CLIENT.endpoint + '/services/' + select.options[select.selectedIndex].value + '.json');
		});
	},
	/**
	 * Send in the post from the form
	 */
	postServiceRequest: function (e) {
		e.preventDefault();
		//document.getElementById('addressstring').innerHTML = '';
		//document.getElementById('reportform').reset();
		
		// YUI().use('io-upload-iframe', 'json-parse', function(Y) {
		YUI().use('io-form', 'json-parse', function(Y) {			
			var cfg = {
				 timeout : 3000,
				 method: 'POST',
				 xdr:{use: 'native'},
				 form:{
					id: document.getElementById('reportform')
					// upload: true
				 },
				 on: {
					start: function(iOid){
						var id = iOid;
						// alert("Started");
					},
					complete: function(iOid, o){
						if(o.responseText !== undefined){
							var responses = Y.JSON.parse(o.responseText);
							var html = "<h2>Successfull Submission</h2>";
							// var responses = o.responseText;
							for(var i in responses){
								html += "<table>";
								var response = responses[i];
								for(var key in response){
									html += "<tr><td>"+key+"</td><td>"+response[key]+"</td></tr>";
								}
								html += "</table>";
							}
							document.getElementById('mainContent').innerHTML = html;
						}
						else{
							document.getElementById('mainContent').innerHTML ="no response text";
						}
					},
					failure: function(iOid, o){
						alert("called on failure");
						 if(o.responseText !== undefined){
							var s = "<ul>"+
								"<li>id: " + ioId +"</li>"+
								" <li>HTTP status: " + o.status+"</li>"
								" <li>Status code message: " + o.statusText+"</li>";	
							document.getElementById('mainContent').innerHTML =s;
						 }
						 else
						 	document.getElementById('mainContent').innerHTML =" failure no response";
					}
				}
			};
			Y.io(CLIENT.endpoint + '/requests.json', cfg);
		});
		return false;
	}
}

//window.addEventListener('load', CLIENT.init, false);
// document.getElementById('reportform').addEventListener('submit', CLIENT.postServiceRequest, false);

YUI().use('node','overlay',function(Y) {
	var overlay = new Y.Overlay({
		srcNode:'#locationchooser',
		xy: [20,60],
		bodyContent: '<div id="location_map"></div>',
		footerContent:'<span class="button"><span class="submit"><button type="button" id="useThisLocation">Use this location</button></span></span><span class="button"><span class="cancel"><button type="button">Cancel</button></span></span>',
	});
	overlay.render();
	overlay.hide();
	Y.on('click',Y.bind(overlay.hide, overlay),'#locationchooser .cancel button');

	Y.on('click',function(e) {
		e.preventDefault();
		overlay.show();
		var geocoder = new google.maps.Geocoder();
		var map = new google.maps.Map(document.getElementById('location_map'), {
			zoom: 14,
			center: new google.maps.LatLng(CLIENT.DEFAULT_LATITUDE, CLIENT.DEFAULT_LONGITUDE),
			mapTypeId: google.maps.MapTypeId.ROADMAP
		});
		if (navigator.geolocation) {
			navigator.geolocation.getCurrentPosition(function(position) {
				map.setCenter(new google.maps.LatLng(
					position.coords.latitude,position.coords.longitude
				));
			});
		}
		var crosshairs = new google.maps.Marker({
			map: map,
			icon:'cross-hairs-small-yellow-cropped.png'
		});
		crosshairs.bindTo('position',map,'center');

		Y.on('click',function(e) {
			document.getElementById('lat').value = map.getCenter().lat();
			document.getElementById('long').value = map.getCenter().lng();
			geocoder.geocode({latLng:map.getCenter()}, function(results,status) {
				if (status == google.maps.GeocoderStatus.OK) {
					if (results[0]) {
						var address = '';
						for (var i=0; i<results[0].address_components.length; i++) {
							switch (results[0].address_components[i].types[0]) {
								case 'street_number':
									address = results[0].address_components[i].long_name + ' ';
									break;
								case 'route':
									address += results[0].address_components[i].long_name;
									break;
							}
						}
						Y.one('#addr_id').set('innerHTML','<input name="address" value="'+address+'" />');
						Y.one('#address_string').set('value',address);
						Y.one('#addressstring').set('innerHTML',address);
					}
				}
			});
			overlay.hide();
		},'#useThisLocation');
	},'#openMapButton');
});
window.addEventListener('load', CLIENT.init, false);

