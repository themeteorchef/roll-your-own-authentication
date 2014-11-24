###
  Startup
  Collection of methods and functions to run on server startup.
###

Meteor.startup(->
  # Function: Create Service Configuration
  # Here, we create a function to help us reset and create our third-party login
  # configurations to keep our code DRY.
  createServiceConfiguration = (service,clientId,secret)->
    ServiceConfiguration.configurations.remove(
      service: service
    )
    if service == 'facebook'
      ServiceConfiguration.configurations.insert(
        service: service
        appId: clientId
        secret: secret
      )
    else
      ServiceConfiguration.configurations.insert(
        service: service
        clientId: clientId
        secret: secret
      )

  ###
    Configure Third-Party Login Services
    Note: We're passing the Service Name, Client Id, and Secret. These values
    are obtained by visiting each of the given services (URLs listed below) and
    registering your application.
  ###

  # Facebook
  createServiceConfiguration('facebook', '833779916667282', '89dd54fbc1a5ff5ab610ec2c278f1c14')
  # Generate your Client & Secret here: https://developers.facebook.com/apps/

  # GitHub
  createServiceConfiguration('github', 'd768e3dcdf876092da9f', '1df75614371739ce8d6fbfba67dcabc9c4c46cf1')
  # Generate your Client & Secret here: https://github.com/settings/applications

  # Google (Yeah, that ClientID is for real)
  createServiceConfiguration('google', '313280785371-o6m4t7alshghi24eia9pvm0kuvt81v9n.apps.googleusercontent.com', 'XnVn13MUr1cMjjK9YC2DzAai')
  # Generate your Client & Secret here: https://console.developers.google.com

  # Twitter
  createServiceConfiguration('twitter', 'AS0lL1mTR7So0Zy7p59ghhLyF', '7OEHvFugps8fyWZ0R1LAMOA5tBnYp321Cqy3bBVZXGdRCOgSp3')
  # Generate your Client & Secret here: https://apps.twitter.com/

  ###
    Generate Test Accounts
    Creates a collection of test accounts automatically on startup.
  ###

  # Create an array of user accounts.
  users = [
    { name: "Admin", email: "admin@admin.com", password: "password" }
  ]

  # Loop through array of user accounts.
  for user in users

    # Check if the user already exists in the DB.
    checkUser = Meteor.users.findOne({"emails.address": user.email});

    # If an existing user is not found, create the account.
    if not checkUser

      id = Accounts.createUser(
        email: user.email
        password: user.password
        profile:
          name: user.name
      )

)
