$(function(){

vjs.cuePointBar = function(options){
	var player = this;
	var el = $("<div>", {"class":"vjs-cuepoints-holder", "html": '<div class="cuepoints"></div>'});
	var hookEl = $(player.controlBar.progressControl.seekBar.handle.el_); //$(".vjs-seek-handle");
	var url = options.url || "";
	console.log(player.el_, url);
	function init(){
		hookEl.before(el);
		ajax(url);
		this.el_ = el;
		this.player_ = player;
	}

	function ajax(url){
		var duration = parseFloat(options.duration);
		console.log(duration)
		$.getJSON(url)
			.done(function(d){ 
				var holder = $(".cuepoints", el); 
				var html = "";
				console.log("data", d, d.length)
				for (var i = 0, len = d.length, o = {}; i < len; i++) {
					o = d[i];
					html += "<div class='cuepoint' style='left:"+(parseFloat(o.time)/duration)*100+"%' data-type='"+o.type+"' title='"+o.type+"'></div>"
					
					console.log(i,o, html)
				}
				holder.html(html);
			})
			.fail(function(){ console.log("Error occur in getting gesture track") })
	}
    init();
}

vjs.plugin('cuepoints', vjs.cuePointBar);

});