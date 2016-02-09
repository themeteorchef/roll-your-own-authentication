Template.index.events({
  'click [data-social-login]' ( event, template ) {
    const service   = event.target.getAttribute( 'data-social-login' ),
          platforms = {
            facebook: 'loginWithFacebook',
            github: 'loginWithGithub',
            google: 'loginWithGoogle',
            twitter: 'loginWithTwitter'
          },
          options = {
            requestPermissions: [ 'email' ]
          };

    if ( service === 'twitter' ) {
      delete options.requestPermissions;
    }

    Meteor[ platforms[ service ] ]( options, ( error ) => {
      if ( error ) {
        Bert.alert( error.message, 'danger' );
      }
    });
  }
});
