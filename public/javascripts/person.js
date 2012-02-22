$( function() {
  // global variable (I know, I know...) to store the current target of the create person dialog
  var $CREATE_PERSON_TARGET = null;

  /* Best In Place :: in-place editing with ajax
  ** =========================================================*/

  /* Initialize a custom form type "autocomplete" for best_in_place */
  BestInPlaceEditor.forms.autocomplete = {
    activateForm : function() {
      var output = '<form class="form_in_place" action="javascript:void(0)" style="display:inline;">';
      output += '<input type="text"';
      output += this.inner_class          ? ' class="'              + this.inner_class          + '"' : '';
      output += this.options.autocomplete ? ' data-autocomplete="'  + this.options.autocomplete + '"' : '';
      output += this.options.id_element   ? ' data-id_element="#'   + this.options.id_element   + '"' : '';
      output += ' />';
      output += this.options.id_element
        ? '<input type="hidden" id="' + this.options.id_element + '" name="' + this.options.id_element_name + '" />'
        : '';
      output += '</form>';
      this.element.html( output );
      this.element.find( "input" )[0].select();
      autoCompletePerson( null, this.element.find( 'input' )[0] );
      this.element.find( "form" ) .bind( 'submit', {editor: this}, BestInPlaceEditor.forms.autocomplete.submitHandler );
      this.element.find( "input" ).bind( 'blur',   {editor: this}, BestInPlaceEditor.forms.autocomplete.inputBlurHandler );
      this.element.find( "input" ).bind( 'keyup',  {editor: this}, BestInPlaceEditor.forms.autocomplete.keyupHandler );
      this.element.find( "input" ).bind( 'keypress', stopSubmitOnEnter );
    },

    getValue : function() {
      return this.sanitizeValue( this.element.find("input")[1].value );
    },

    inputBlurHandler : function(event) {
      $input = $(event.target);
      if ($input.data("list_open") === "true") {
        // do nothing, so as not to prevent user clicks from registering!
      } else {
        event.data.editor.abort();
      }
    },

    submitHandler : function(event) {
      event.data.editor.update();
    },

    keyupHandler : function(event) {
      if ( event.keyCode == 27 ) {
        event.data.editor.abort();
      }
    }
  };

  BestInPlaceEditor.prototype.loadErrorCallback = function(request, error) {
    this.element.html( this.oldValue );

    // Display all error messages from server side validation
    errorHandler( request );

    // Binding back after being clicked
    $( this.activator ).bind( 'click', { editor: this }, this.clickHandler );
  };

  /* Activate in-place ajaxy editing with best_in_place */
  $( ".best_in_place" ).best_in_place();

  /* Stop propogation of click event for links within a best_in_place field */
  $( ".best_in_place > a" ).each( function() {
    $( this ).click( function(e) {
      e.stopPropagation();
    } );
  } );

  /* Partnerships
  ** =========================================================*/

  /* Partnership form */
  $( '#add_partnership_form' )
    .bind( "ajax:success", function( evt, data, status, xhr ) {
      var $form = $( this );
      clearFields( $form );
      $( '#partnerships' ).append( xhr.responseText );
      swapVisibility( $( '#add_partnership_link' ), $( '#add_partnership_form_container' ) );
    } )
    .bind( 'ajax:complete', function( evt, xhr, status ) {
      $( "#partnership_partner_id" ).val( '' );
    } )
    .bind( "ajax:error", ajaxFormErrorHandler );
  /* Bind escape key handler for add partnership form */
  $( "#partnership_partner_name" ).bind( 'keyup', function( event ) {
    if ( event.keyCode == 27 && $( '#add_partnership_link' ).css( 'display' ) == 'none' ) { // escape key
      swapVisibility( $( '#add_partnership_link' ), $( '#add_partnership_form_container' ) );
      clearFields( $( '#add_partnership_form' ) );
    }
  } );
  /* Bind enter key handler for add partnership form */
  $( "#partnership_partner_name" ).bind( 'keypress', stopSubmitOnEnter );

  /* Children
  ** =========================================================*/

  /* Child form */
  $( '#add_child_form' )
    .bind( "ajax:success", function( evt, data, status, xhr ) {
      var $form = $( this );
      clearFields( $form );
      $( '#children' ).append( xhr.responseText );
      swapVisibility( $( '#add_child_link' ), $( '#add_child_form_container' ) );
    } )
    .bind( 'ajax:complete', function( evt, xhr, status ) {
      $( "#child_id" ).val( '' );
    } )
    .bind( "ajax:error", ajaxFormErrorHandler );
  /* Bind escape key handler for add child form */
  $( "#child_partner_name" ).bind( 'keyup', function( event ) {
    if ( event.keyCode == 27 && $( '#add_child_link' ).css( 'display' ) == 'none' ) { // escape key
      swapVisibility( $( '#add_child_link' ), $( '#add_child_form_container' ) );
      clearFields( $( '#add_child_form' ) );
    }
  } );
  /* Bind enter key handler for add child form */
  $( "#child_name" ).bind( 'keypress', stopSubmitOnEnter );

  /* Autocomplete for Person related fields
  ** =========================================================*/

  /* Person autocomple forms */
  $( "input[data-autocomplete]" ).each( autoCompletePerson );

  function autoCompletePerson( index, element ) {
    $( element ).autocomplete( {
      source: function ( request, response ) {
        var xhr = $.getJSON( $( element ).attr( 'data-autocomplete' ), { term: request.term }, function( data, status, xhr ) {
          data.unshift( {"label":"Add New Person...","id":null,"value":"_new"} );
          response( data, status, xhr );
        } );
      },
      focus: function ( event, ui ) {
        if ( ui.item.value == "_new" ) return false;
      },
      minLength: 2,
      open: function ( event, ui ) {
        $( this ).data( "list_open", "true" );
      },
      close: function ( event, ui ) {
        $( this ).data( "list_open", "false" );
      },
      select: function ( event, ui ) {
        var $autoCompleteField = $( this );
        if ( ui.item.value == "_new" ) {
          $CREATE_PERSON_TARGET = $autoCompleteField;
          $( "#create_person_dialog" ).dialog( "open" );
          return false;
        } else {
          $( $autoCompleteField.data( 'id_element' ) ).val( ui.item.id );
          $( $autoCompleteField[0].form ).submit();
        }
      }
    } );
              }

  /* Create Person jQuery Dialog
  ** =========================================================*/

  /* Create person modal dialog */
  $( "#create_person_dialog" ).dialog( {
    modal: true,
    autoOpen: false,
    show: "fade",
    buttons: {
      "Add Person": function() {
        $( '#create_person_form' ).submit();
      },
      "Cancel": function() {
        $( this ).dialog( "close" );
      }
    },
    open: function() {
      $( '#person_name' ).val( $CREATE_PERSON_TARGET.val() );
      $( '.ui-widget-overlay' ).hide().fadeTo( 'fast', 0.7 );
    },
    close: function() {
    }
  } );

  /* Create person ajax form */
  $( "#create_person_form" )
    .bind( "ajax:success", function( evt, data, status, xhr ) {
      var $form = $( this );
      data = $.parseJSON(data);

      // Reset fields so form can be used again, but leave hidden_field values intact.
      clearFields( $form );

      // Insert response partial into page below the form.
      $( $CREATE_PERSON_TARGET.data( 'id_element' ) ).val(data.id);
      $( $CREATE_PERSON_TARGET.context.form ).submit();

      // Hide the dialog
      $( "#create_person_dialog" ).dialog( "close" );
    } )
    .bind( 'ajax:complete', function( evt, xhr, status ) {
      $( $CREATE_PERSON_TARGET.data( 'id_element' ) ).val('');
    } )
    .bind( "ajax:error", ajaxFormErrorHandler );
} );

/* Utility Functions
** =========================================================*/

function stopSubmitOnEnter(e) {
  var eve = e || window.event;
  var keycode = eve.keyCode || eve.which || eve.charCode;

  if (keycode == 13) {
    eve.cancelBubble = true;
    eve.returnValue = false;

    if (eve.stopPropagation) {
      eve.stopPropagation();
      eve.preventDefault();
    }
    return false;
  }
}

function clearFields( $elem ) {
  $elem.find( 'textarea,input[type="text"],input[type="file"]' ).val( "" ).blur();
}

function removePartnership( id ) {
  var options = {
    type:       "post",
    url:        "/partnerships/" + id,
    dataType:   'script',
    data:       { '_method': 'delete' },
    success:    function() { removePartnershipSuccessCallback(id); },
    error:      function( xhr ){ errorHandler( xhr ); },
    beforeSend: function( xhr ){ xhr.setRequestHeader( "Accept", "application/json" ); }
  };
  jQuery.ajax( options );
}

function removePartnershipSuccessCallback( id ) {
  $( "#partnership_"+ id ).remove();
}

function removeChildOfPerson( person_id, child_id ) {
  var options = {
    type:       "post",
    url:        "/people/" + person_id + "/children/" + child_id,
    dataType:   'script',
    data:       { '_method': 'delete' },
    success:    function() { removeChildSuccessCallback(child_id); },
    error:      function( xhr ){ errorHandler( xhr ); },
    beforeSend: function( xhr ){ xhr.setRequestHeader( "Accept", "application/json" ); }
  };
  jQuery.ajax( options );
}

function removeChildSuccessCallback( id ) {
  $( "#child_"+ id ).remove();
}

function ajaxFormErrorHandler( evt, xhr, status, error ) {
  errorHandler( xhr );
}

function errorHandler( xhr ) {
  var errors, errorText;

  try {
    // Populate errorText with the json errors
    errors = $.parseJSON( xhr.responseText );
  } catch( err ) {
    // If the responseText is not valid JSON (like if a 500 exception was thrown), populate errors with a generic error message.
    errors = [ "Unknown error: Please reload the page and try again" ];
  }

  // Build the list of errors
  errorText = "Oops! Seems there was a problem. ";
  errorText += errors.join( ', ' );

  var notice = '<div class="notice">'
    + '<div class="notice-body">'
    + '<img src="/images/info.png" alt="" />'
    + '<h3>Error</h3>'
    + '<p>'+ errorText +'</p>'
    + '</div>'
    + '<div class="notice-bottom">'
    + '</div>'
    + '</div>';

  $( notice ).purr( {
    usingTransparentPNG: true,
    isSticky: true
  } );
}

function swapVisibility( thing_1, thing_2 ) {
  if ( $( thing_1 ).css( 'display' ) == 'none' ) {
    $( thing_1 ).show();
    $( thing_2 ).hide();
  } else {
    $( thing_2 ).show();
    $( thing_1 ).hide();
  }
}
