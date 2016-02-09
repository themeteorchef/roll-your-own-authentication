Template.registerHelper( 'userIdentity', () => {
  return Modules.both.getUserIdentity( Meteor.user() );
});
