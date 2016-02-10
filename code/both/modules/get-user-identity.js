const getUserIdentity = ( user ) => {
  let emails   = user.emails,
      services = user.services;

  if ( emails ) {
    return emails[ 0 ].address;
  } else if ( services ) {
    return _getEmailFromService( services );
  } else {
    return user.profile.name;
  }
};

const _getEmailFromService = ( services ) => {
  for ( let service in services ) {
    let current = services[ service ];
    return service === 'twitter' ? current.screenName : current.email;
  }
};

Modules.both.getUserIdentity = getUserIdentity;
