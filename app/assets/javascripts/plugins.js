;(function ( $, window, document, undefined ) {
    
    // Toggle switch Plugins
    // Create the defaults once
    var pluginName = 'toggleSwitch',
        defaults = {
            status: "off",
            trigger_event: "click"
        };

    // The actual plugin constructor
    function ToggleSwitch( element, options ) {
        this.element = element;
        this.$element = $(element);

        // jQuery has an extend method that merges the 
        // contents of two or more objects, storing the 
        // result in the first object. The first object 
        // is generally empty because we don't want to alter 
        // the default options for future instances of the plugin
        this.options = $.extend( {}, defaults, options) ;
        
        this._defaults = defaults;
        this._name = pluginName;
        
        this.init();
    }

    ToggleSwitch.prototype.init = function () {
        var init_status = this.options.status;
        var self = this;
        console.log(this.element)
        //$(".toggle-btn")
        this.$element
        .on("click",function(e){
          var btn = $(e.delegateTarget);

          var active = self.flip(btn);

          var handler = active.data("toggle-handler");
          $(handler).trigger(self.options.trigger_event);
          
        })
        .attr("data-toggle-status", init_status);
         
        $(".toggle-handle[data-toggle-status="+init_status+"]").addClass("active");
    };


    ToggleSwitch.prototype.flip = function(el){
      var btn = el ? el : this.element;
      console.log("flipping", btn)
      $(".toggle-handle", btn).toggleClass("active");
      var active = $(".active", btn);
      var status = active.data("toggle-status");
      
      
      $(btn).attr("data-toggle-status", status);
      return active;
    }

    // A really lightweight plugin wrapper around the constructor, 
    // preventing against multiple instantiations
    $.fn[pluginName] = function ( options ) {
        return this.each(function () {
            var entity = 'plugin-' + pluginName
            var instance =  $.data(this, entity)
            if (!instance) {
                $.data(this, entity, new ToggleSwitch( this, options ));
            } else {
              if ( typeof options === "string"){
                instance[options]() //execute cmd. 
              } else if(typeof options === 'object'){ //TODO: update setting
                $.noop();
              }
            }
        });
    }

})( jQuery, window, document );

