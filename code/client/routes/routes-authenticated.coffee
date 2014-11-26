Router.route('dashboard',
  path: '/dashboard'
  template: 'dashboard'
  waitOn: ->
    Meteor.subscribe 'userData'
  onBeforeAction: ->
    Session.set 'currentRoute', 'dashboard'
    @next()
)
