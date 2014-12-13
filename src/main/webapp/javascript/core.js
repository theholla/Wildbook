
var wildbook = {
	classNames: [
		'Encounter',
		'MarkedIndividual',
		'SinglePhotoVideo',
		'Measurement',
	],

	Model: {},
	Collection: {},

	loadAllClasses: function(callback) {
		this._loadAllClassesCount = this.classNames.length;
		var me = this;
		for (var i = 0 ; i < this.classNames.length ; i++) {
		classInit(this.classNames[i], function() {
			me._loadAllClassesCount--;
//console.log('huh??? %o', me._loadAllClassesCount);
			if (me._loadAllClassesCount <= 0) {
				console.info('wildbook.loadAllClasses(): DONE loading all classes');
				if (callback) callback();
			}
		});
		}
	},


/*
	fetch: function(cls, arg, callback) {
		if (!cls || !cls.prototype || !cls.prototype.meta) {
			console.error('invalid class %o', cls);
			return;
		}
		var url = cls.prototype.url();
		if (arg) url += '/' + arg;
console.log('fetch() url = ' + url);

		var ajax = {
			url: url,
			success: function(d) {
				if (!(d instanceof Array)) d = [d];
				var arr = [];
				for (var i = 0 ; i < d.length ; i++) {
					var obj = new cls(d[i]);  //TODO do we need to trap failures?
					arr.push(obj);
				}
				callback(arr);
			},
			error: function(x,a,b) { callback({error: a+': '+b}); },
			type: 'GET',
			dataType: 'json'
		};
console.log('is %o', ajax);
		$.ajax(ajax);
	},
*/


	// h/t http://stackoverflow.com/questions/1353684/detecting-an-invalid-date-date-instance-in-javascript
	isValidDate: function(d) {
		if (Object.prototype.toString.call(d) !== "[object Date]") return false;
		return !isNaN(d.getTime());
	},

	//oh the joys of human representation of time (and the inconsistency of browsers implementation of new Date() )
	parseDate: function(s) {
		s = s.trim();  //some stuff had trailing spaces, ff fails.
		//we make assumptions that wildbook is at least returning to us with YYYY-MM-DD ... hope this is always true.  :(
		if (s.length == 10) s += 'T00:00:00';
		//hope we have the right string now -- but wildbook does not put "T" between date/time, which chokes ff and ie(?).
		s = s.substr(0,10) + 'T' + s.substr(11);
		var d = new Date(s);
		if (!this.isValidDate(d)) return false;
		return d;
	},

	init: function(callback) {
		classInit('Base', function() { wildbook.loadAllClasses(callback); });  //define base class first - rest can happen any order
	}

};




function classInit(cname, callback) {
	console.info('attempting to load class %s', cname);
	$.getScript(wildbookGlobals.baseUrl + '/javascript/classes/' + cname + '.js', function() {
		console.info('successfully loaded class %s', cname);

		//just a way to get actual name... hacky, but cant figure out the elegant way??
		if (wildbook.Model[cname] && wildbook.Model[cname].prototype) {
			wildbook.Model[cname].prototype.meta = function() {
				return {
					className: cname
				};
			};
		}
		////// end hackery

		callback();
	});
}


//$.getScript('/mm/javascript/prototype.js', function() { wildbook.init(); });

//$(document).ready(function() { wildbook.init(); });
