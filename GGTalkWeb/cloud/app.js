var express = require('express');
var app = express();

// App configuration section
app.set('views', 'cloud/views'); // Folder containing view templates
app.set('view engine', 'ejs'); // Template engine
app.use(express.bodyParser()); // Read the request body into a JS object

app.use(app.router);


// Attach request handlers to routes
app.get('/beacon/:objectId', function (req, res) {
    
    var query = new Parse.Query("Item");
    query.equalTo("objectId", req.params.objectId);
    query.find({
        success: function (results) {
        	var beacon = {name:"", description:""};
        	if(results.length>0){
        		beacon = results[0].toJSON();
        	}
		    res.render('beacon.ejs', { beacon: beacon });
        },
        error: function () {
            res.error("beacon lookup failed");
        }
    });
});

app.get('/staff/:objectId', function (req, res) {
    var query = new Parse.Query("Staff");
    query.equalTo("objectId", req.params.objectId);
    query.find({
        success: function (results) {
        	var staff = {name:"", jobTitle:"", department:"", description:""};
        	if(results.length>0){
        		staff = results[0].toJSON();
        	}
		    res.render('staff.ejs', {
		        staff: staff
		    });
        },
        error: function () {
            res.error("staff lookup failed");
        }
    });
});


app.get('/requestNewStaffBeacon', function (req, res) {
    var query = new Parse.Query("Beacon");
    query.equalTo("deleted", false);
    query.find({
        success: function (results) {
        	var query2 = new Parse.Query("App");
        	query2.find({
        		success:function(results){
        			var pfapp = results[0];

		        	var proximityUUID = pfapp.get("proximityUUID");
		        	var major = pfapp.get("staffBeaconMajor");
		        	var startMinor = pfapp.get("staffBeaconMinMinor");
		        	var minor = startMinor%65536;
		        	

		        	var cnt = 0;
		        	while(true){
			        	for(var i = 0 ; i < results.length ; i++) {
			        		var pfbeacon = results[i];
			        		if(pfbeacon.get("proximityUUID") == proximityUUID && pfbeacon.get("major") == major && pfbeacon.get("minor") == minor) {
			        			minor++;
			        			minor%=65536;
			        			cnt++;
			        			if(cnt >= 65536) {
			        				res.error("request new staff beacon failed");
			        			}
			        			continue;
			        		}
			        	}
			        	break;
		        	}//*/


		        	pfapp.set("staffBeaconMinMinor", (minor+1)%65536);
		        	pfapp.save();

					res.setHeader('Content-Type', 'application/json');

		        	var Beacon = Parse.Object.extend("Beacon");
		  			var pfbeacon = new Beacon();
		  			pfbeacon.set("proximityUUID", proximityUUID);
		  			pfbeacon.set("major", major);
		  			pfbeacon.set("minor", minor);
		  			pfbeacon.set("deleted", false);
		  			pfbeacon.save(null, {
		  				success:function(){
		  					res.end(JSON.stringify({ beacon:pfbeacon.toJSON() }));
		  				},
		  				error:function(){
							res.error("request new staff beacon failed");
		  				}
		  			});
				},
				error:function(){
					res.error("request new staff beacon failed");
				}
			});
        },error: function () {
            res.error("request new staff beacon failed");
        }
    });
});


// Attach the Express app to your Cloud Code
app.listen();