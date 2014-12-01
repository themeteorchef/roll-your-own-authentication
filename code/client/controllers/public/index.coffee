###
  Controller: Index
  Template: /client/views/public/index.html
###

# Events
Template.index.events(
  'click .btn-facebook': ->
    Meteor.loginWithFacebook(
      requestPermissions: ['email']
    , (error)->
      console.log error.reason if error
    )

  'click .btn-github': ->
    Meteor.loginWithGithub(
      requestPermissions: ['email']
    , (error)->
      console.log error.reason if error
    )

  'click .btn-google': ->
    Meteor.loginWithGoogle(
      requestPermissions: ['email']
    , (error)->
      console.log error.reason if error
    )

  'click .btn-twitter': ->
    Meteor.loginWithTwitter((error)->
      console.log error.reason if error
    )
)
