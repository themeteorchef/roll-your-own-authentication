Router.route('dashboard',
  path: '/dashboard'
  template: 'dashboard'
  onBeforeAction: ->
    Session.set 'currentRoute', 'dashboard'
    @next()
)
