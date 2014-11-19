Router.route('dashboard',
  path: '/dashboard'
  template: 'index'
  onBeforeAction: ->
    Session.set 'currentRoute', 'dashboard'
    @next()
)
