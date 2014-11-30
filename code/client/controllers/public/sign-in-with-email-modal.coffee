# Rendered
Template.signInWithEmailModal.rendered = ->
  $('#sign-in-with-email').validate(
    rules:
      emailAddress:
        required: true
        email: true
      password:
        required: true
    messages:
      emailAddress:
        required: "Gonna need an email, there, friend!"
        email: "Is that a real email? What a trickster!"
      password:
        required: "Pop in a passwordarooni for me there, will ya?"
    submitHandler: ->
      # Once our validation passes, we need to make a decision on
      # whether we want to sign the user up, or, log them in. To do
      # this, we look at a session variable `createOrSignIn` to
      # see which path to take. This is set below in our event handler.
      createOrSignIn = Session.get 'createOrSignIn'

      # Get our user's information before we test as we'll use the same
      # information for both our account creation and sign in.
      user =
        email: $('[name="emailAddress"]').val()
        password: $('[name="password"]').val()

      # Take the correct path according to what the user clicked and
      # our session variable is equal to.
      if createOrSignIn == "create"
        # Before we do the insert, we call to the server to validate our email
        # address. This isn't *required*, but it's a good feature to have. This
        # allows us to ensure that users are signing up with legitimate email
        # addresses and not addresses that will bounce.
        Meteor.call 'validateEmailAddress', user.email, (error,response)->
          if error
            # If we get an error, let our user know.
            alert error.reason
          else
            if response.error
              # If we get an error from our method, alert to the user.
              alert response.error
            else
              # If all is well, create the user's account!
              Accounts.createUser(user, (error)->
                if error
                  alert error.reason
                else
                  # If all works as expected, we need to hide our modal backdrop (lol, Bootstrap).
                  $('.modal-backdrop').hide()
              )
      else
        Meteor.loginWithPassword(user.email, user.password, (error)->
          if error
            alert error.reason
          else
            # If all works as expected, we need to hide our modal backdrop (lol, Bootstrap).
            $('.modal-backdrop').hide()
        )
  )

# Events
Template.signInWithEmailModal.events(

  'click .btn-create-account': ->
    # When the user clicks "Create Account," set a session variable
    # to use later in our submitHandler (above).
    Session.set 'createOrSignIn', 'create'

  'click .btn-sign-in': ->
    # When the user clicks "Sign In," set a session variable
    # to use later in our submitHandler (above).
    Session.set 'createOrSignIn', 'signin'

  'submit form': (e)->
    # Prevent form submission so it's deferred to our validator.
    e.preventDefault()
)
