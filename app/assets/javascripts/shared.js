    function clearErrorMessages() { 
      var $container = $('#error-messages-container');
      $container.empty();
    } 
    function addErrorMessage(type, msg) { 
      var $container = $('#error-messages-container');
      $container.append('<div class="alert ' + type + ' fade in" data-alert="alert"><a class="close" data-dismiss="alert">x</a>' + msg + '</div>');
    } 
    function displayErrorMessage(type, msg) { 
      clearErrorMessages();
      addErrorMessage(type, msg); 
    } 
