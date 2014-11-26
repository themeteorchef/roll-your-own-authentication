###
  User Creation
  Functions for handling new user creation.
###

Accounts.onCreateUser((options, user)->
  # We'll call to send an email to the new user here.
  console.log options
  console.log user
  # As this function occurs before Meteor inserts the user into the DB, we need
  # to make sure that we keep existing functionality intact. E.g. here, we still
  # want our user to have a profile object equal to the options passed.
  if options.profile
    user.profile = options.profile
  # Lastly, we return the user to Meteor so it can perform the insert.
  user
)
