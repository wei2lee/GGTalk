// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
//Parse.Cloud.define("hello", function(request, response) {
//  response.success("Hello world!");
//});




Parse.Cloud.afterSave("Staff", function(request) {
	if (request.object.existed()) {
		// it existed before 
	} else {
		// it is new 
		var url = request.object.get("url");
		if (!url) {
			url = "https://ggtalk.parseapp.com/staff/" + request.object.id;
			request.object.set("url", url);
			request.object.save();
		}
	}
	new Parse.Query("App").first({
	  success: function(pfapp) {
	  	pfapp.set("dataUpdatedAt", new Date());
	  	pfapp.save();
	  }
	});
});


Parse.Cloud.afterDelete("Beacon", function(request) {
	new Parse.Query("App").first({
	  success: function(pfapp) {
	  	pfapp.set("dataUpdatedAt", new Date());
	  	pfapp.save();
	  }
	});
});

Parse.Cloud.afterSave("Beacon", function(request) {
	var isCreatedFromRequestNewStaffBeacon = false;
	if (request.object.existed()) {
		// it existed before 
	} else {
		// it is new 
		var pfbeacon = request.object;
		if(!pfbeacon.get("item") && !pfbeacon.get("staff")) {
			isCreatedFromRequestNewStaffBeacon = true;
		}
	}

	if(!isCreatedFromRequestNewStaffBeacon) {
		new Parse.Query("App").first({
		  success: function(pfapp) {
		  	pfapp.set("dataUpdatedAt", new Date());
		  	pfapp.save();
		  }
		});
	}
});

Parse.Cloud.afterSave("Item", function(request) {
	new Parse.Query("App").first({
	  success: function(pfapp) {
	  	pfapp.set("dataUpdatedAt", new Date());
	  	pfapp.save();
	  }
	});
});

Parse.Cloud.afterSave("Notification", function(request) {
	new Parse.Query("App").first({
	  success: function(pfapp) {
	  	pfapp.set("dataUpdatedAt", new Date());
	  	pfapp.save();
	  }
	});
});

require('cloud/app.js');