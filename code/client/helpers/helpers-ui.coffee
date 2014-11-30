###
  UI Helpers
  Define UI helpers for common template functionality.
###

# Current Route
# Return an active class if the currentRoute session variable name
# (set in the appropriate file in /client/routes/) is equal to the name passed
# to the helper in the template.

UI.registerHelper('currentRoute', (route) ->
  if Session.equals 'currentRoute', route then 'active' else ''
)

# Current User Email
# Return the current user's email address. This method helps us to obtain the
# user's email regardless of whether they're using an OAuth login or the
# accounts-password login (Meteor doesn't offer a native solution for this).

UI.registerHelper('userIdentity', (userId) ->
  getUser = Meteor.users.findOne({_id: userId})
  if getUser.emails
    getUser.emails[0].address
  else if getUser.services
    services = getUser.services
    getService = switch
      when services.facebook then services.facebook.email
      when services.github then services.github.email
      when services.google then services.google.email
      when services.twitter then services.twitter.screenName
      else false
    getService
  else
    getUser.profile.name
)
