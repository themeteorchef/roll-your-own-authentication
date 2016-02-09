const getUserIdentity = ( user ) => {
  let emails   = user.emails,
      services = user.services;

  if ( emails ) {
    return _getEmail( emails );
  } else if ( services ) {
    return _getEmailFromService( services );
  } else {
    if ( Meteor.isClient ) {
      return _getNameFromProfile( user );
    } else {
      return null;
    }
  }
};

const _getEmail = ( emails ) => {
  return emails[ 0 ].address;
};

const _getEmailFromService = ( services ) => {
  for ( let service in services ) {
    let current = services[ service ];
    return service === 'twitter' ? current.screenName : current.email;
  }
};

const _getNameFromProfile = ( user ) => {
  return user.profile.name;
};

Modules.both.getUserIdentity = getUserIdentity;
