###
  Publications
  Data being published to the client.
###

# /profile

Meteor.publish('userData', ->
  # Cache this.userId first since we use it twice below.
  currentUser = this.userId
  # If a current user is available, find the current user and publish the
  # specified fields. Note: Meteor stores OAuth emails differently than it does
  # for accounts created using the standard accounts-password package.
  if currentUser
    Meteor.users.find({_id: currentUser}, {
      fields: {
        "services.facebook.email": 1
        "services.github.email": 1
        "services.google.email": 1
        "services.twitter.screenName": 1
        "emails.address[0]": 1
        "profile": 1
      }
    })
  else
    this.ready()
)
