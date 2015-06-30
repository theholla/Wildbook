//
// TODO: Uncomment when you are ready to use the database.
//
//var mongodb = require('mongodb');
//var dbPort = 27017;
//var dbHost = 'localhost';
//var dbName = 'wildbook';
//
//// establish the database connection
//var db = new mongodb.Db(dbName, new mongodb.Server(dbHost, dbPort, {auto_reconnect: true}), {w: 1});
//    db.open(function(ex, db) {
//    if (ex) {
//        console.log(ex);
//    } else {
//        console.log('connected to database [' + dbName + ']');
//    }
//});

var request = require('request');
var https = require('https');

module.exports = function(app, config) {
    function login(req, res, callback) {
        //
        // DEAD FUNCTION NOW
        //
        callback();
//        if (req.session && req.session.user) { // req.session.loginChecked) {
//            callback();
//            return;
//        }
//
//        //
//        // WARNING: This doesn't work with localhost. I had to use the IP-Address as seen by
//        // the router for me. Got this through ipconfig by using the en0:inet value. Port 8080
//        // is fine, it's just the localhost that is the problem. Tried using an alias for localhost
//        // which also didn't work. Must be the fact that it's the same IP address as the node.js
//        // server itself.
//        //
//        //
////        request(config.wildbook.url + "/obj/user", function (error, response, user) {
////            req.session.loginChecked = true;
////            if (!error && response.statusCode == 200) {
////                if (user.username) {
////                    req.session.user = user;
////                } else {
////                    req.session.user = null;
////                }
////            }
////            callback();
////        });
//
//        callback();
    }

    var homeVars = {
        spotlight: {
            name: "Frosty",
            species: "Humpback Whale",
            id: "Cascadia #12492",
            place: "Monterey Bay, CA"
        },
        news: [{headline: "News Section Headline",
                contents: "Lorem ipsum..."},
               {headline: "News Section Headline 2",
                contents: "Ut enim..."}]
    };

    //
    // Main site
    //
    app.get('/', function(req, res) {
        //
        // NOTE: i18n available as req.i18n.t or just req.t
        // Also res.locals.t
        //
        login(req, res, function() {
            //
            // TODO: Read these from a mongo database that the site admin will be able to edit.
            //
            var variables = {
//                user: req.session.user,
                config: config.client,
                page: homeVars
            };

            res.render('home', variables);
        });
    });

    app.get('/config', function(req,res) {
        res.send(config.client);
    });

    app.get('/submitMedia', function(req, res) {
        res.render('mediasubmission');
    });

    //
    // Proxy over to wildbook
    //
    var wbCount = 0;
    app.get('/wildbook/*', function(req, res) {
        //
        // Extract out the * part of the address and forward it through
        // a pipe and request like so. Have to handle error on each section of the pipe.
        //
        var url = config.wildbook.url + req.url.slice(9);

        wbCount++;
        console.log(wbCount + ": " + url);

        req.pipe(request(url))
        .on('error', function(ex) {
            console.log("Trouble connecting to [" + url + "]");
            console.log(ex);
            res.status(500).send(ex);
        })
        .on('end', function() {
            console.log("finished [" + wbCount + ": " + url + "]");
        })
        .pipe(res)
        .on('error', function(ex) {
            console.log(ex);
        });
    });

    //
    // Proxy over to wildbook
    //
    var wbPostCount = 0;
    app.post('/wildbook/*', function(req, res) {
        //
        // Extract out the * part of the address and forward it through
        // a pipe and request like so. Have to handle error on each section of the pipe.
        //
        var url = config.wildbook.url + req.url.slice(9);

        wbPostCount++;
        console.log(wbPostCount + ": " + url);

        req.pipe(request.post({uri: url, json: req.body}))
        .on('error', function(ex) {
            console.log("Trouble connecting to [" + url + "]");
            console.log(ex);
            res.status(500).send(ex);
        })
        .on('end', function() {
            console.log("finished [" + wbPostCount + ": " + url + "]");
        })
        .pipe(res)
        .on('error', function(ex) {
            console.log(ex);
        });
    });

    //=================
    // Catch-all
    //=================

    app.get('*', function(req, res) {
        res.render('404', config.client);
    });
};