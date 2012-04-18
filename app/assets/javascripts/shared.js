  	$(function() {
  		$( "#duration-range" ).slider({
  			range: true,
  			min: 0,
  			max: 20,
  			values: [ 3, 15 ],
  			slide: function( event, ui ) {
  				$( "#duration-amount" ).val( ui.values[ 0 ] + " - " + ui.values[ 1 ] + " minutes" );
  			}
  		});
  		$( "#duration-amount" ).val( $( "#duration-range" ).slider( "values", 0 ) +
  			" - " + $( "#duration-range" ).slider( "values", 1 ) + " minutes" );
  	});
    
  	$(function() {
  		$( "#date-range" ).slider({
  			range: true,
  			min: 0,
  			max: 20,
  			values: [ 3, 15 ],
  			slide: function( event, ui ) {
  				$( "#date-amount" ).val( ui.values[ 0 ] + " - " + ui.values[ 1 ] + " days" );
  			}
  		});
  		$( "#date-amount" ).val( $( "#date-range" ).slider( "values", 0 ) +
  			" - " + $( "#date-range" ).slider( "values", 1 ) + " days" );
  	});
    
    $(document).ready(function(){
      $(".group-video").colorbox({rel:'group-video', transition:"none", width:"75%", height:"75%"});
    });
