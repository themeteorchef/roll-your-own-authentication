let template;

let handleAuthentication = ( options ) => {
  template = options.template;
  _validate( options.form );
};

let _validate = ( form ) => {
  $( form ).validate( validation() );
};

let validation = () => {
  return {
    rules: {
      emailAddress: {
        required: true,
        email: true
      },
      password: {
        required: true
      }
    },
    messages: {
      emailAddress: {
        required: "Gonna need an email, there, friend!",
        email: "Is that a real email? What a trickster!"
      },
      password: {
        required: "Pop in a passwordarooni for me there, will ya?"
      }
    },
    submitHandler() { _handleAuth(); }
  };
};

let _handleAuth = () => {
  let type     = template.createOrSignIn.get(),
      email    = template.find( '[name="emailAddress"]' ).value,
      password = template.find( '[name="password"]' ).value;

  if ( type === 'create' ) {
    _createUser( email, password, _loginUser );
  } else {
    _loginUser( email, password, 'Welcome back, matey!' );
  }
};

let _createUser = ( email, password, login ) => {
  Accounts.createUser({
    email: email,
    password: password
  }, ( error ) => {
    if ( error ) {
      Bert.alert( error.reason, 'danger' );
    } else {
      login( email, password, 'Welcome aboard, matey!' );
    }
  });
};

let _loginUser = ( email, password, message ) => {
  Meteor.loginWithPassword( email, password, ( error ) => {
    if ( error ) {
      Bert.alert( error.reason, 'warning' );
      _hideModal();
    } else {
      Bert.alert( message, 'success' );
      _hideModal();
    }
  });
};

const _hideModal = () => {
  $( '#sign-in-with-email-modal' ).modal( 'hide' );
  $( '.modal-backdrop' ).fadeOut();
};

Modules.client.handleAuthentication = handleAuthentication;
