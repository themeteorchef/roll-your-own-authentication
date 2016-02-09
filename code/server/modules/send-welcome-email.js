const send = ( user, profile ) => {
  let data = {
        email: Modules.both.getUserIdentity( user ),
        name: profile && profile.name ? profile.name : "",
        url: Meteor.settings.public.domain
      },
      html = _getHTMLForEmail( 'welcome-email', data );

  _sendEmail( data.email, html );
};

const _getHTMLForEmail = ( templateName, data ) => {
  SSR.compileTemplate( templateName, Assets.getText( `email/templates/${ templateName }.html` ) );
  return SSR.render( templateName, data )
};

const _sendEmail = ( emailAddress, html ) => {
  if ( emailAddress.includes( '@' ) ) {
    Meteor.defer( () => {
      Email.send({
        to: emailAddress,
        from: "The Meteor Chef - Demo <demo@themeteorchef.com>",
        subject: "Welcome aboard, team matey!",
        html: html
      });
    });
  }
};

Modules.server.sendWelcomeEmail = send;

// userToWelcome = {
//   email: Modules.both.getUserIdentity(),
//   name: profile ? profile.name : ''
// };
//
// Meteor.methods(
//
//   sendWelcomeEmail: (userData)->
//     # Check our userData argument against our expected pattern.
//     check(userData,{email: String, name: String})
//     # Compile and render our email template using meteorhacks:ssr.
//     SSR.compileTemplate('welcomeEmail', Assets.getText('email/welcome-email.html'))
//     emailTemplate = SSR.render('welcomeEmail',
//       name: if userData.name != "" then userData.name else null
//       url: "http://localhost:3000"
//     )
//     # Send off our email to the user.
//     Email.send(
//       to: userData.email
//       from: "The Meteor Chef - Demo <demo@themeteorchef.com>"
//       subject: "Welcome aboard, team matey!"
//       html: emailTemplate
//     )
//
// )
