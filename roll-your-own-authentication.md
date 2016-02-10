<div class="note info">
  <h3>Pre-Written Code <i class="fa fa-info"></i></h3>
  <p><strong>Heads up</strong>: this recipe relies on some code that has been pre-written for you, <a href="https://github.com/themeteorchef/roll-your-own-authentication">available in the recipe's repository on GitHub</a>. During this recipe, our focus will only be on implementing a custom authentication workflow. If you find yourself asking "we didn't cover that, did we?", make sure to check the source on GitHub.</p>
</div>

<div class="note">
  <h3>Additional Packages <i class="fa fa-warning"></i></h3>
  <p>This recipe relies on several other packages that come as part of <a href="https://github.com/themeteorchef/base">Base</a>, the boilerplate kit used here on The Meteor Chef. The packages listed below are merely recipe-specific additions to the packages that are included by default in the kit. Make sure to reference the <a href="https://themeteorchef.com/base/packages-included/">Packages Included list</a> for Base to ensure you have fulfilled all of the dependencies.</p>
</div>

### Prep
- **Time**: ~2-3 hours
- **Difficulty**: Intermediate
- **Additional knowledge required**: [ES2015](https://themeteorchef.com/blog/what-is-es2015/) [basics](https://themeteorchef.com/snippets/common-meteor-patterns-in-es2015/), [the module pattern](https://themeteorchef.com/snippets/using-the-module-pattern-with-meteor/), [sending email](https://themeteorchef.com/snippets/using-the-email-package) 

### What are we building?
Don Carlton Sales is a tiny sales team with a big heart. Don, the owner, has gotten in touch with us to see if we can help him out. Don is building an application for all of the member's of his sales team to manage their clients. Don, being a tech-savvy fellow, has asked us if we can set the app to allow for logging in with social accounts. Don is a big fan of sites like Facebook, but in his older age admits he has trouble remembering a lot of passwords. After seeing another site use "Login with Facebook," he knew it was a must-have for his sales team's app.

In this recipe, we're going to help Don out and get both oAuth-based and password-based login implemented in his application. As an added bonus, we've suggested that Don add a bit of personalization to his app and send out an email when anyone signs up. Don loved this idea and has given us a template he'd like to send out welcoming new members. As part of the sign up process, we'll send out an email with this information to give users a nice, polished user experience.

### Ingredients
Before we start building, make sure that you've installed the following packages and libraries in your application. We'll use these at different points in the recipe, so it's best to install these now so we have access to them later.

#### Meteor packages

<p class="block-header">Terminal</p>

```.lang-bash
meteor add accounts-facebook
```
The `accounts-facebook` package will allow users to connect to and sign in with their Facebook account.

<p class="block-header">Terminal</p>

```.lang-bash
meteor add accounts-github
```
The `accounts-github` package will allow users to connect to and sign in with their GitHub account.

<p class="block-header">Terminal</p>

```.lang-bash
meteor add accounts-google
```
The `accounts-google` package will allow users to connect to and sign in with their Google account.

<p class="block-header">Terminal</p>

```.lang-bash
meteor add accounts-twitter
```
The `accounts-twitter` package will allow users to connect to and sign in with their Twitter account.

<p class="block-header">Terminal</p>

```.lang-bash
meteor add service-configuration
```
The `service-configuration` package is what we'll use to configure our own connection to the various third-party services we'll offer for signing in. This is what allows us to share our OAuth tokens with each which they'll use to "identify" our application.

<p class="block-header">Terminal</p>

```.lang-bash
meteor add email
```
The `email` package will give us the ability to send email from the server using the nifty `Email.send` method.

### Setting up oAuth services
Because our third-party sign in's are relying on _external_ services outside of our control, we need a way to identify our application with those services so they know their users are safe. Fortunately for us, some smarter folks in the past came up with a convenient system known as OAuth, or, "open authentication":

> OAuth is an open standard to authorization. OAuth provides client applications a 'secure delegated access' to server resources on behalf of a resource owner. It specifies a process for resource owners to authorize third-party access to their server resources without sharing their credentials.

— via ["OAuth" on Wikipedia](https://en.wikipedia.org/wiki/OAuth)

What this essentially means is that by providing a service with a unique token for our application, we can make requests for information on behalf of the user. So for things like signing in, we can allow the user to use their email/password combination from another service (e.g. Facebook). We never store or touch that email/password, because OAuth implements a permissions system wherein users are prompted to log in to and accept or deny our access to their credentials. Pretty cool, right?

Before we get anything wired up in our application, we'll want to spend some time getting the necessary permissions from oAuth providers. Permissions come in two forms: a client key and a secret key. In the next few sections, we'll look at how to set up the services we'll cover below individually. Our goal will be to map the credentials we get from each service into our [settings.json files](https://themeteorchef.com/snippets/making-use-of-settings-json/) to make configuration a breeze later. To get started, let's look at how our `settings.json` file will be structured.

#### Storing credentials in settings.json
For each of the services that we'll cover below, we'll create "applications" which are assigned two unique values: a "client ID" and a "client secret." Because these values identify our application, it's important to keep them secure. If an attacker got a hold of them, they could potentially pretend to be our application and trick users. No bueno. To store them, we're going to rely on a [settings.json](https://themeteorchef.com/snippets/making-use-of-settings-json/) file. 

In a real application, we'd actually have two of these (or more): `settings-development.json` and `settings-production.json`. The first would contain the keys pointing to our _development_ application (this suggests we register multiple applications for each service—one for development and one for production) and the other with keys for our _production_ or user-facing application. Despite having two separate files, we can use the same code to reference their values in our application securely.

For our purposes, we'll set up a single `settings.json` file. Don't worry, what we'll learn will apply equally to a multi-file set up. Let's outline our file now and explain what each piece will be used for.

<p class="block-header">/settings.json</p>

```javascript
{
  "public": {},
  "private": {
    "oAuth": {
      "facebook": {
        "appId": "",
        "secret": ""
      },
      "github": {
        "clientId": "",
        "secret": ""
      },
      "google": {
        "clientId": "",
        "secret": ""
      },
      "twitter": {
        "consumerKey": "",
        "secret": ""
      }
    }
  }
}
```
See what's happening here? In our `settings.json` file, for each service we're adding a space for the two values that we'll get from each. Pay close attention. Notice that for `facebook` and `twitter`, what we'd expect to be the `clientId` is actually `appId` and `consumerKey` respectively. What gives? My money is on egos. Here, `appId` and `consumerKey` are just company-specific terms for `clientId`. When all is said and done, they'll achieve the same thing. We use the specific names, though, as the code we'll be using to configure each service expects these special names.

Don't worry too much about using this in our code right now. For now, just make sure to copy each of the values that we get from each service below in the corresponding fields. We'll learn how to make use of these values soon after. Let's get started by getting an application set up on Facebook.

#### Facebook
Facebook is pretty easy to get set up. First, make sure that you have an existing account with Facebook. Unless the app you're working on is something personal, make sure to use an account other than your personal Facebook account (i.e., set up a new account for your company). Once you have the correct account set up [head over to this link](https://developers.facebook.com/apps/).

<figure>
  <img src="https://tmc-post-content.s3.amazonaws.com/2016-02-10_02:27:21:513_Screen Shot 2016-02-09 at 8.26.21 PM.png" alt="Facebook Apps dashboard.">
  <figcaption>Facebook Apps dashboard.</figcaption>
</figure>

To create a new app, click the green "Add a New App" button in the top-right corner of this screen. When prompted, select the "WWW - Website" option. Once you do, you will be prompted _again_, this time to type in the title of the app you're adding. Type in the name you'd like to use and Facebook will display a button you can click to create your app "Create New Facebook App ID."

<figure>
  <img src="https://tmc-post-content.s3.amazonaws.com/2016-02-10_02:32:27:554_Screen Shot 2016-02-09 at 8.30.16 PM.png" alt="Typing in our new application name.">
  <figcaption>Typing in our new application name.</figcaption>
</figure>

Next, Facebook will ask you if the app you're creating is a test version of another application. If this is your first time creating an app, answer "no" (the default). Hint, hint, if you want to add a development-specific app for testing later, you will want to repeat this process but mark this option as "Yes" and select the existing application to create a test app for.

Once you click "Create App ID," you'll be dropped into another quick start screen. For our needs, we'll skip this by clicking the "Skip Quick Start" button in the top-right corner of the block. On the next page, Facebook will show a block where you can read your new application's `appId` and `secret` values. Just copy these values into the corresponding fields into the `facebook` block of your `settings.json` file.

<figure>
  <img src="https://tmc-post-content.s3.amazonaws.com/2016-02-10_02:38:25:277_Screen Shot 2016-02-09 at 8.38.08 PM.png" alt="Finding our App ID and App Secret on Facebook.">
  <figcaption>Finding our App ID and App Secret on Facebook.</figcaption>
</figure>

You're not done! Once you have these values set in `settings.json`, from the left-hand menu of this screen select the "Settings" link. Next, in the "App Domains" field, you'll want to put either `localhost` or the domain of your application like `tmc-003-demo.meteor.com`. Next, click the "Add Platform" button below and select the "Website" option from the popup. In the field that appears, you'll want to add the full URL for your application. Again, this will either be `http://localhost:3000` or the domain of your application like `http://tmc-003-demo.meteor.com`. That's it! Just click the "Save Changes" button toward the bottom of the screen and Facebook is ready to go.

#### GitHub
GitHub is pretty straightforward, too. Again, make sure you have an account set up on the site and that it's not your personal account (unless that's ok). Once you have an account, [head to this link](https://github.com/settings/applications) and the select the "Developer Applications" tab at the top. Once you do, a button should pop up that says "Register new application" in the top-right corner.

<figure>
  <img src="https://tmc-post-content.s3.amazonaws.com/2016-02-10_02:55:06:103_Screen Shot 2016-02-09 at 8.54.25 PM.png" alt="Toggling the Developer applications list on GitHub.">
  <figcaption>Toggling the Developer applications list on GitHub.</figcaption>
</figure>

Clicking this button, GitHub will reveal a new form to define the application you'd like to add. For the "Homepage URL" and "Authorization callback URL" fields, you can place the same URL, either `http://localhost:3000` or the domain for your application like `http://tmc-003-demo.meteor.com`. Optionally, you can add a description and an image that will be displayed for users when they sign in to your application using GitHub.

<figure>
  <img src="https://tmc-post-content.s3.amazonaws.com/2016-02-10_03:03:18:520_Screen Shot 2016-02-09 at 8.57.10 PM.png" alt="Registering a new OAuth application on GitHub.">
  <figcaption>Registering a new OAuth application on GitHub.</figcaption>
</figure>

Once you click "Register application," you're done! GitHub will display your "Client ID" and "Client Secret" on the next screen. Know what's next? Yep, copy these over to your `settings.json` file!

#### Google
Okay, party's over. Old Uncle Google is here to _confuse the hell out of you_. Same rules apply as before, make sure you have a Google account where it's okay to connect an application to and then [pop over to this link](https://console.developers.google.com/). Also, make sure to turn up your patience dial just a dash.

<figure>
  <img src="https://tmc-post-content.s3.amazonaws.com/2016-02-10_03:14:10:878_Screen Shot 2016-02-09 at 9.13.48 PM.png" alt="Finding the Create a project link in the Google dashboard.">
  <figcaption>Finding the Create a project link in the Google dashboard.</figcaption>
</figure>

First things first, from the menu in the header bar, select the dropdown menu underneath "Select a project" and locate the "Create a project" option at the bottom of the menu. If this is your first app ever, when you login you should see an easier-to-find link on the main screen to "Create project." In the popup window, give your new application a name and then click "Create." After a few seconds, you'll be redirected to a dashboard where you'll see a block labeled "Use Google APIs" with a link at the bottom labeled "Enable and manage APIs."

<figure>
  <img src="https://tmc-post-content.s3.amazonaws.com/2016-02-10_03:22:55:177_Screen Shot 2016-02-09 at 9.21.43 PM.png" alt="Finding the enable and manage APIs link.">
  <figcaption>Finding the enable and manage APIs link.</figcaption>
</figure>

From the next screen, you'll want to click the "Credentials" link from the left-hand menu (ignore the list of apps in the main area). From here (hang in there), you'll want to click the "Create credentials" button to reveal a popup with a few different options, the one you're after being the "OAuth client ID" option. Click this and you'll be lead to a screen where you'll need to click the "Configure consent screen" button. 

<figure>
  <img src="https://tmc-post-content.s3.amazonaws.com/2016-02-10_03:31:55:202_Screen Shot 2016-02-09 at 9.31.37 PM.png" alt="Setting a Product name.">
  <figcaption>Setting a Product name.</figcaption>
</figure>

On the next screen, all you'll need to add is a Product name, but you can also specify any of the other fields (and add an image) if you'd like. Once you've done this, click "Save" and you'll be redirected to the original screen, this time with the list of application types visible. From here, select "Web application" which will toggle a set of fields for you to edit. In the first field "Authorized JavaScript origins," you'll want to add at least `http://localhost:3000`, but can also add your production application URL as well like `http://tmc-003-demo.meteor.com`. 

In the "Authorized Redirect URIs" field, you'll want to do something a little different. In this field, you'll want to add the URL that Google will go to _after_ a user has successfully authenticated. In the case of your Meteor application this will be the base URL of the application plus `_oauth/google?close`. For example, you will want to add at least `http://localhost:3000/_oauth/google?close` but can also add production URLs like `http://tmc-003-demo.meteor.com/_oauth/google?close`.

<figure>
  <img src="https://tmc-post-content.s3.amazonaws.com/2016-02-10_03:46:59:525_Screen Shot 2016-02-09 at 9.46.39 PM.png" alt="Getting our Client ID and secret.">
  <figcaption>Getting our Client ID and secret.</figcaption>
</figure>

Finally, after you click "Create" once you've specified your URLs, Google will present you—drumroll, please—with your Client ID and Secret! Just snatch these and pop them in your `settings.json` file and you're good to go.

#### Twitter
Last but not least, Twitter! Good news, Twitter is pretty easy. Beating a dead horse, use an account that's safe to add applications to. Once you're all logged in, [this is the link you'll want to visit](https://apps.twitter.com/). The path forward is pretty clear, just tap "Create New App" in the top-right corner and Twitter will present you with a form to define your app.

<figure>
  <img src="https://tmc-post-content.s3.amazonaws.com/2016-02-10_03:56:58:877_Screen Shot 2016-02-09 at 9.53.42 PM.png" alt="Adding an application on Twitter.">
  <figcaption>Adding an application on Twitter.</figcaption>
</figure>

Everything you're presented with is pretty straightforward except for one tiny little thing: Twitter does not allow `localhost` based URLs. Instead, if you're creating an application to use for local development, you'll want to use `http://127.0.0.1` which is the default IP equivalent of your local machine (i.e., `127.0.0.1` == `localhost`). In "Callback URL" we'll need to use the same convention, however, appending the proper URL like we did with Google for where users will be redirected after successful authentication (like `http://127.0.0.1/_oauth/twitter?close` or `http://tmc-003-demo.meteor.com/_oauth/twitter?close`).

<figure>
  <img src="https://tmc-post-content.s3.amazonaws.com/2016-02-10_04:04:19:312_Screen Shot 2016-02-09 at 10.04.00 PM.png" alt="Finding your Consumer Key and Secret on Twitter.">
  <figcaption>Finding your Consumer Key and Secret on Twitter.</figcaption>
</figure>

Once you accept the Developer agreement and then click "Create your Twitter application," you'll be redirected to a screen detailing your application. To get your keys, just click the "Keys and Access Tokens" tab at the top of the screen to grab your Consumer Key and Secret to place in `settings.json`!

### Configuring oAuth services
In order to start using the service we've just set up, we need to let our application know about them. The good news: we've take care of the hard part. Now, we need a way to "configure" each service we'll be using when Meteor starts up. To do this, we're going to write a simple module that we can call when Meteor starts, passing in our configuration from `settings.json`. First step, let's define our module (we'll paste the full contents below) and then see how to wire it up on startup.

<p class="block-header">/server/modules/configure-services.js</p>

```javascript
const services = Meteor.settings.private.oAuth;

const configure = () => {
  if ( services ) {
    for( let service in services ) {
      ServiceConfiguration.configurations.upsert( { service: service }, {
        $set: services[ service ]
      });
    }
  }
};

Modules.server.configureServices = configure;
```

Not much here! In this file, we're defining a module that we'll call next like `Modules.server.configureServices()` following [the module pattern](https://themeteorchef.com/snippets/using-the-module-pattern-with-meteor/). We use this pattern because it gives structure to our code, but also works really well with the upcoming 1.3 release of Meteor which supports [ES2015 imports](http://www.2ality.com/2014/09/es6-modules-final.html).

So what exactly is this doing? Well, Meteor stores all of the configurations for oAuth logins in a MongoDB collection called `meteor_accounts_loginServiceConfiguration`. To make this a bit easier to consume, using the `service-configuration` package we installed earlier, we can call the `upsert` method on this collection. When we do, we pass in the name of the service that we want to upsert against—meaning, if the item does not exist, insert it, and if it does, update it—along with the values we want to set for that service. We do this in a loop over the services we've added to the `oAuth` object in our `settings.json` file. 

This is where our earlier work pays off. Because we've labeled the properties for each of the services in our `settings.json` file to match what Meteor expects in this collection, we can just loop over them and insert them into the database! That's it. Now, when we call this module, our services will be configured in the app. Where do we call this? Let's take a peek.

<p class="block-header">/server/modules/startup.js</p>

```javascript
let startup = () => {
  [...]
  Modules.server.configureServices();
  [...]
};

var _setBrowserPolicies = () => {
  [...]
};

Modules.server.startup = startup;
```

Lucky us! Because we're relying on [Base](https://themeteorchef.com/base/) for this recipe, we've already got a convenient way to tap into Meteor's startup method on the server. In this module, we simply add a call to our new module inside of the `startup` method which is called on server start up for us automatically. Here, we just add `Modules.server.configureServices();` and we're done! If we've added all of our services to our `settings.json` file properly, they'll be configured accordingly when we start Meteor up.

<div class="note">
  <h3>Starting with settings <i class="fa fa-warning"></i></h3>
  <p>In order for this to work, make sure to start your Meteor app with the settings file specified using <code>meteor --settings settings.json</code>.</p>
</div>

Good progress! Now we're ready to start making use of all this stuff. Let's push on, wiring up the buttons that will actually fire each of our oAuth logins.

### Wiring up oAuth login buttons
Let's get started on our UI. For this step, we're going to add the markup for all of the buttons our users will be able to click to login. So it's there for the next step, we'll also add in a button for signing in with email but get it working in the next section.

<p class="block-header">/client/templates/public/index.html</p>

```javascript
<template name="index">
  <div class="row">
    <div class="col-xs-12 col-sm-6">
      <img src="https://s3.amazonaws.com/themeteorchef-cdn/don_carlton.png" alt="Don Carlton holding business card.">
    </div>
    <div class="col-xs-12 col-sm-6">
      <div class="page-header">
        <h3>Sign In to DCS</h3>
        <p>Hey there team maties! Come on aboard!</p>
      </div>
      <ul class="btn-list">
        <li>
          <button data-social-login="loginWithFacebook" type="button" class="btn">
            <i class="fa fa-facebook"></i> Sign in with Facebook
          </button>
        </li>
        <li>
          <button data-social-login="loginWithGithub" type="button" class="btn">
            <i class="fa fa-github"></i> Sign in with GitHub
          </button>
        </li>
        <li>
          <button data-social-login="loginWithGoogle" type="button" class="btn">
            <i class="fa fa-google"></i> Sign in with Google
          </button>
        </li>
        <li>
          <button data-social-login="loginWithTwitter" type="button" class="btn">
            <i class="fa fa-twitter"></i> Sign in with Twitter
          </button>
        </li>
        <li>
          <button type="button" class="btn btn-success btn-login-email" data-toggle="modal" data-target="#sign-in-with-email-modal">
            <i class="fa fa-envelope"></i> Sign in with Email
          </button>
        </li>
      </ul>
    </div>
  </div>
</template>

```
Mostly repetition! All we're adding here is a button for each of our sign in types. Pay close attention. Notice that on each of the oAuth-based login options, we've added a `data-social-login` attribute with the corresponding service name's login method (`loginWith<Service>` comes from each of the accounts packages we installed earlier) passed as the value. What's this? Our next task! We'll use this to identify which buttons correspond to which oAuth sign in we need to call. Let's see the code!

<p class="block-header">/client/templates/public/index.js</p>

```javascript
Template.index.events({
  'click [data-social-login]' ( event, template ) {
    const service = event.target.getAttribute( 'data-social-login' ),
          options = {
            requestPermissions: [ 'email' ]
          };

    if ( service === 'loginWithTwitter' ) {
      delete options.requestPermissions;
    }

    Meteor[ service ]( options, ( error ) => {
      if ( error ) {
        Bert.alert( error.message, 'danger' );
      }
    });
  }
});

```

Interesting! We're doing a lot of consolidation of efforts in this one event handler. Why is that important? Well, we technically need to call four different methods, one for each of the services we support. To avoid having four different event handlers, we consolidate everything relying on the `data-social-login` attribute that we added to each of our oAuth sign in buttons.

To "switch" between each of the different platforms, we open up our click event (notice that we're watching for clicks on _any_ element with a `data-social-login` attribute) by looking at the clicked elements `data-social-login attribute`. Inside, we get clever. First, we grab the clicked buttons `data-social-login` value (remember, this is the method we'll need to call) and assign it to a `service` variable. Just beneath that, we create a "global" `options` object that we can pass to each call.

Just before we make the call, we double check if we're trying to login with Twitter. If we _are_, we want to pluck the `requestPermissions` property from our `options` object. Why? Twitter doesn't offer the user's email as a returned value! Boo! To avoid any errors, we pluck this right before we make the call.

This is the cool part. Notice that we're simply calling `Meteor[ service ]`. How is this working? Well, each of our login methods are defined directly on the `Meteor` object, so, what we're really doing here is calling `Meteor.loginWith<Service>`. Neat, eh? All of the methods are fairly uniform, so it makes sense to have a single call and treat the method name as a variable. To make it work, we just pass in the service name to get the appropriate method and feed in our `options` object as the first argument. 

All of our methods have a uniform callback, too, so we make sure to handle the error and we're done! Believe it or not, this is all of the code we need to get our social logins working. At this point—if our configurations were done properly earlier—we have a working oAuth login system! Pretty wild. We're not quite done, though. Next, we also want to add support for password-based logins for users who _do not_ want to use oAuth. Because oAuth sign in also doubles as a sign up, we'll see how to allow users to both sign up _and_ login using the same form in the next section. Times a wastin', let's get to it!

### Wiring up a login/signup modal
Since we already have our button wired up for our sign in modal—we'll be relying on Boostrap's `data-toggle` and `data-target` attributes to open this for us—our next step is to wire up the modal that will actually be fired when the button is clicked. Real quick, we need to make sure this is included in our `index.html` template.

<p class="block-header">/client/templates/public/index.html</p>

```markup
<template name="index">
  {{> signInWithEmailModal}}
  <div class="row">
    [...]
    <div class="col-xs-12 col-sm-6">
      [...]
      <ul class="btn-list">
        [...]
        <li>
          <button type="button" class="btn btn-success btn-login-email" data-toggle="modal" data-target="#sign-in-with-email-modal">
            <i class="fa fa-envelope"></i> Sign in with Email
          </button>
        </li>
      </ul>
    </div>
  </div>
</template>
```

See it up there at the top? `{{> signInWithEmailModal}}` is what we'll be working on next. This just makes sure that once it's ready, it's visible on the page. Let's take a look at the template for the modal now. It's pretty simple!

<p class="block-header">/client/templates/public/sign-in-with-email-modal.html</p>

```markup
<template name="signInWithEmailModal">
  <div class="modal fade" id="sign-in-with-email-modal" tabindex="-1" role="dialog" aria-labelledby="sign-in-with-email-modal" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
          <h4 class="modal-title" id="sign-in">Sign In to DCS With Email</h4>
        </div>
        <form id="sign-in-with-email">
          <div class="modal-body">
            <div class="form-group">
              <label for="emailAddress">Email Address</label>
              <input type="email" name="emailAddress" class="form-control" placeholder="What's your email, friend?">
            </div>
            <div class="form-group">
              <label for="password">Password</label>
              <input type="password" name="password" class="form-control" placeholder="How about a password, pal?">
            </div>
          </div>
          <div class="modal-footer">
            <button data-auth-type="create" type="submit" class="btn btn-primary">Create Account</button>
            <button data-auth-type="sign-in" type="submit" class="btn btn-default">Sign In</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>
```

Pretty basic stuff here. The part to pay attention to is inside of the `<form></form>` element. Here, we're asking our user for two pieces of input: an email address and a password. This isn't terribly exciting, but if we look down in the `.modal-footer` element, we see a bit of trickery going on. Two submit buttons?! Yep. Remember, our goal is to get our password sign in as close to our oAuth sign in as possible. Here, we're making it possible to either sign up or log in using _the same form_. Next, we'll wire up a way behind the scenes to find out which button the user clicked and then route them through the correct process. Cool, eh? Similar to our `data-social-login` trick, make note of the `data-auth-type` attribute on both of these buttons.

Let's get this form wired up.

<p class="block-header">/client/templates/public/sign-in-with-email-modal.js</p>

```javascript
Template.signInWithEmailModal.onCreated( () => {
  let template = Template.instance();
  template.createOrSignIn = new ReactiveVar();
});

Template.signInWithEmailModal.onRendered( () => {
  Modules.client.handleAuthentication({
    form: '#sign-in-with-email',
    template: Template.instance()
  });
});

Template.signInWithEmailModal.events({
  'click [data-auth-type]' ( event, template ) {
    let type = event.target.getAttribute( 'data-auth-type' );
    template.createOrSignIn.set( type );
  },
  'submit form' ( event ) {
    event.preventDefault();
  }
});
```

Underwhelming? Well, there's a lot going on here but we've worked hard to condense it down. First, let's look at our `events` block. Notice that in here, we're using a nearly _identical_ process for detecting the sign in type—sign up or log in—as we did for detecting which social login button was pressed. Instead of relying on a set of login methods here, though, all we're doing is setting a [ReactiveVar](https://themeteorchef.com/snippets/reactive-dict-reactive-vars-and-session-variables/). This is a reactive data source similar to a Session variable, but instead of being global like a Session, it's bound to the current template's instance. Once the template is destroyed, so is the variable! This is good for keeping your global namespace clean but also for helping to reason about your application later.

Just beneath this, notice that we're simply calling `event.preventDefault()` on our form's submission event. Why's that? This is our next step. If we look at our template's `onRendered` function, you can see that we're calling to a module called `handleAuthentication` and passing it two things: the selector for our form and the current template instance. This may be a bit confusing, so let's hop over there now and see what it's doing.

<p class="block-header">/client/modules/handle-authentication.js</p>

```javascript
let template;

let handleAuthentication = ( options ) => {
  template = options.template;
  _validate( options.form );
};

let _validate = ( form ) => {
  $( form ).validate( validation() );
};

let validation = () => {
  return {
    rules: {
      emailAddress: {
        required: true,
        email: true
      },
      password: {
        required: true
      }
    },
    messages: {
      emailAddress: {
        required: "Gonna need an email, there, friend!",
        email: "Is that a real email? What a trickster!"
      },
      password: {
        required: "Pop in a passwordarooni for me there, will ya?"
      }
    },
    submitHandler() { _handleAuth(); }
  };
};

let _handleAuth = () => {
  let type     = template.createOrSignIn.get(),
      email    = template.find( '[name="emailAddress"]' ).value,
      password = template.find( '[name="password"]' ).value;

  if ( type === 'create' ) {
    _createUser( email, password, 'Welcome aboard, matey!' );
  } else {
    _loginUser( email, password, 'Welcome back, matey!' );
  }
};

let _createUser = ( email, password, message ) => {
  Accounts.createUser({
    email: email,
    password: password
  }, ( error ) => {
    if ( error ) {
      Bert.alert( error.reason, 'danger' );
    } else {
      Bert.alert( message, 'success' );
      _hideModal();
    }
  });
};

let _loginUser = ( email, password, message ) => {
  Meteor.loginWithPassword( email, password, ( error ) => {
    if ( error ) {
      Bert.alert( error.reason, 'warning' );
      _hideModal();
    } else {
      Bert.alert( message, 'success' );
      _hideModal();
    }
  });
};

let _hideModal = () => {
  $( '#sign-in-with-email-modal' ).modal( 'hide' );
  $( '.modal-backdrop' ).fadeOut();
};

Modules.client.handleAuthentication = handleAuthentication;
```

Woah! What is all of this?! This is our process for getting a user both signed up _and_ logged in for our application. It's pretty neat. Similar to earlier when we worked on the configuration of our oAauth services, here, we're relying on [the module pattern](https://themeteorchef.com/snippets/using-the-module-pattern-with-meteor/) to organize our code.

So...what exactly is happening here? Well, if we look at the function bound to our module's namepsace (the `Modules.client.handleAuthentication = handleAuthentication;` part) we can see that we start way up at the top of our file. Our goal here is to handle a bit of validation on our form _before_ we determine whether or not we're trying to sign up or log in. For our validation process, we're relying on the [jQuery validation](https://themeteorchef.com/snippets/validating-forms-with-jquery-validation/) library which gives us a simple API for validating our forms.

Our first step is to attach our validation. Remember, all of this code is running when our `signInWithEmailModal` template is rendered. That means that our validation will be attached then. To make it work, we take in the selector we passed as part of our module invoication and get it over to the `_validate()` method which wraps the jQuery validation librarie's invoication call `$( form ).validate()`. Inside of our call to `.validate()`, we're passing a call to another function `validation()`. This is down below. This method is responsible for returning the "configuration" for our form's validation. It includes all of the rules and error messages that we'll display to users. It also includes something really neat: a method called `submitHandler`.

Here, `submitHandler` is being used in place of our form's standard submit event (remember, we prevented this earlier). All it's doing in our code here is making a call to another method `_handleAuth()` which is where our module really starts to shine. At this point, we're calling this method if our form passes validation. If it has, that means that we can trust the inputs in the form and pull their values.

Down in `_handleAuth` we get to work. Here, notice that we're pulling in our ReactiveVar that we defined a little bit ago to tell us which sign in method to use. At the same time, we also grab the `emailAddress` and `password` values from our form. Next is the real magic. If we find that our `createOrSignIn` ReactiveVar's value is set to `'create'` we want to create a user. Otherwise, we want to log the user in. Pay close attention here!

Notice that for our call to `_createUser` we're passing our `email` and `password` values. Down in `_createUser`, we simply make a call to `Accounts.createUser`, passing in our new user's credentials. If all is well, we make a call to another method down below `_hideModal()` to ensure that our sign in modal is hidden properly and pass in the `message` value to a success alert via [Bert](https://themeteorchef.com/snippets/client-side-alerts-with-bert/). If something goes wrong in all of this, we throw an error.

If we jump back up, we're doing something very similar for our call to `_loginUser`. If we take a peek, the code is nearly identical save for one thing: we're using a different method in Meteor. Instead of `Accounts.createUser`, here, we're calling `Meteor.loginWithPassword`. Taking our passed values, we add them as arguments to `loginWithPassword` and handle our error and success states similar to our `_createUser` method.

With this in place, we're done! Our modal will now allow our user to both login and sign up in one spot. Pretty neat, right? Next up, we need to do a litlte bit of work on figuring out who are user _is_.

### Getting the user's email
We're almost done! Just a few bits of polish. First up is figuring out our user's identity. Unfortunately, there is no one-size-fits all solution for getting things like our user's email address when we're using multiple types of account providers. The discrepancy is small, but enough to drive you nuts the first few times you box with it. The issue is that when we call something like `Meteor.user()`, in a password-based account we may expect a field like `emails` to be available on the user. 

When using oAuth, though, this isn't the case. User emails are stored _per_ service like `services.<serviceName>.email`. Because of this, we need to have a means for getting the user's email—or some fallback—no matter what method they used for signing in. To do this, we need to write a bit of code. For our sake, we're going to bring in the module pattern again. Let's take a look at what we're using and step through it.

<p class="block-header">/both/modules/get-user-identity.js</p>

```javascript
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
```

Pay close attention here. The first thing to note is that we're _not_ storing this on either the client or server, but in `/both`. This is because we'll want access to this functionality in both environments and this helps us to avoid unnecessary code duplication. Next, let's focus on the main `getUserIdentity` method. Inside is where all of the magic happens.

First, notice that we're passing in a `user` argument (this will be some version of `Meteor.user()` when invoked). Next, we check if that user object has an `emails` property or `services` property present. If it _does_ have an `emails` property, we simply grab the first email in the `emails` array and return its address. Otherwise, we find the `services` property, we can assume that our user has logged in with an oAuth provider and so we pass our `services` object to our `_getEmailFromService()` method.

Inside of `_getEmailFromService`, we simply loop over each of the keys in the services object (this will only ever be one, however, this allows us to keep this dynamic). For each service, we store its value in the `current` variable. Before we return anything, we check to see if the current service name is `'twitter'`. Why? Well, Twitter doesn't give us an email address for users, but they do give us a `screenName` value (the user's `@` name). Here, we account for this, either returning `current.screenName` or `current.email` depending on the oAuth provider.

Finally, back up in `getUserIdentity`, if we didn't find any `emails` or `services`, we simply return the user's `profile.name` value. In most cases this shouldn't ever be used, but it's good to have a backup just in case! At this point this is ready to go. But wait...how do we use it?

#### Creating a template helper
One of the places that we'll want to use this code is on the client. In our header, we want to display the current user's identity in the top-right dropdown menu. To make this work, we need to do two things: create a [global template helper](https://themeteorchef.com/snippets/using-global-template-helpers/) and add a publication with the appropriate data. Let's get the helper set up (it's super easy) and then get our publication and subscription working.

<p class="block-header">/client/helpers/template.js</p>

```javascript
Template.registerHelper( 'userIdentity', () => {
  return Modules.both.getUserIdentity( Meteor.user() );
});
```

That's it! All of the work we did in our module is coming to roost here. We simply return a call to it, making sure to pass in a call to `Meteor.user()` and we're done. Now, when we use this in our template, we'll get back either the email address or name of our user. Let's get this wired up in our header now.

<p class="block-header">/client/templates/globals/authenticated-navigation.html</p>

```markup
<template name="authenticatedNavigation">
  <ul class="nav navbar-nav">
    <li class="{{currentRoute 'dashboard'}}"><a href="{{pathFor 'dashboard'}}">Dashboard</a></li>
  </ul>
  <ul class="nav navbar-nav navbar-right">
    <li class="dropdown">
      <a href="#" class="dropdown-toggle" data-toggle="dropdown">{{userIdentity}} <span class="caret"></span></a>
      <ul class="dropdown-menu" role="menu">
        <li class="logout"><a href="#">Logout</a></li>
      </ul>
    </li>
  </ul>
</template>
```

See it in there? We simply call `{{userIdentity}}` and our user's email or name is displayed! Easy peasy. Now for the slightly more difficult part: a publication. We want to be careful with this one because we don't want to accidentally publish all of users information to the client. Instead, we only want to publish the _current_ user's information and _only_ when they're logged in. To do this, we're going to add a bit of JavaScript to our `authenticatedNavigation` template.

<p class="block-header">/client/templates/globals/authenticated-navigation.js</p>

```javascript
Template.authenticatedNavigation.onCreated( () => {
  let template = Template.instance();
  template.subscribe( 'user' );
});
```

That's it, but pay attention! Notice that we're only going to subscribe to this publication—using [template-level subscriptions](https://themeteorchef.com/snippets/publication-and-subscription-patterns/#tmc-subscribing-in-the-template)—when we create the `authenticatedNavigation` template, which should only happen when our user is logged in! As long as we get this part right, the rest will be handled for us by [Base's routing](https://themeteorchef.com/base/routing/). So far so good? Next, let's wire up our publication to match this.

<p class="block-header">/server/publications/users.js</p>

```javascript
Meteor.publish( 'user', function() {
  return Meteor.users.find( this.userId, {
    fields: {
      "services.facebook.email": 1,
      "services.github.email": 1,
      "services.google.email": 1,
      "services.twitter.screenName": 1,
      "emails": 1,
      "profile": 1
    }
  });
});
```

This is important! Notice that here, we're only returning the currently logged in user by leveraging `this.userId`. Further, we're limiting the fields in the user object to only be those fields that we'll need for use in our `getUserIdentity` module. In case it's not clear, the reason we need to do this is that we want to avoid leaking unnecessary parts of the user's account information to the client. By passing a [projection](https://themeteorchef.com/snippets/mongodb-queries-and-projections/#tmc-the-mongodb-projection-document) to our query on `Meteor.users()`, we limit the fields being returned.

With this in place, we're all set on the client! For our final trick, we want to wire up a way to send a user a welcome email when they login to the app for the first time. To get this working, we'll create one last module for sending the email and then see how to tie it into Meteor's account creation process.

### Sending a welcome email
This final step is optional, but a nice bit of polish. Our goal here is to watch for new user sign ups and when they're received, send out an email welcoming the user. To make it work, we'll leverage the module pattern one last time. Let's spit out the module below and walk through it.

<p class="block-header">/server/modules/send-welcome-email.js</p>

```javascript
const send = ( user, profile ) => {
  let data = {
        email: Modules.both.getUserIdentity( user ),
        name: profile && profile.name ? profile.name : "",
        url: Meteor.settings.public.domain
      },
      html = _getHTMLForEmail( 'welcome-email', data );

  _sendEmail( data.email, html );
};

const _getHTMLForEmail = ( templateName, data ) => {
  SSR.compileTemplate( templateName, Assets.getText( `email/templates/${ templateName }.html` ) );
  return SSR.render( templateName, data )
};

const _sendEmail = ( emailAddress, html ) => {
  if ( emailAddress.includes( '@' ) ) {
    Meteor.defer( () => {
      Email.send({
        to: emailAddress,
        from: "The Meteor Chef - Demo <demo@themeteorchef.com>",
        subject: "Welcome aboard, team matey!",
        html: html
      });
    });
  }
};

Modules.server.sendWelcomeEmail = send;
```
Nothing too wild going on here. From a high-level, what we're doing here is taking in information about our user, compiling an HTML email template, and then sending the compiled version of that template to the user. That's it! It may look like a lot, but it's all pretty straightforward.

Up in our `send` method, we begin by compiling the data that we'll want to render into our template. Notice that here, we make use of our `getUserIdentity` module again. We also introduce a new value in our `settings.json` file's `public` object called `domain`. This is optional and is simply used to allow for sending a link back to our application in the email to users. We make this based on our `settings.json` file to allow us to toggle between our development and production environments with ease.

Next, using the `meteorhacks:ssr` package [included in Base](https://themeteorchef.com/base/packages-included/), we'll compile [an HTML template included in the source of this recipe](), piping in some information about our user in the `_getHTMLForEmail` method. Inside, we give the `SSR.compileTemplate` method a name for our template (we just use the file name for this, it's only used as an identifier for the `render` step) which also doubles as the name of the file for out HTML template in our source code. In the second argument, we pass our freshly minted `data` object. From here, `SSR.render()` takes care of the rest. It takes the compiled HTML template, pipes in the data we've sent to it, and returns an HTML string for our email. Neat! 

<div class="note">
  <h3>Configuring Email <i class="fa fa-warning"></i></h3>
  <p>In order for all of this to work, you'll need to configure an email provider. A detailed explanation of how to get this done is <a href="https://themeteorchef.com/snippets/using-the-email-package/#tmc-configuration">available here</a>.</p>
</div>

With this in hand, we jump back up to the `send` method and make one last call to `_sendEmail()` passing in the email address of our user and the `html` we just compiled using the `SSR` methods. Almost done! Down in `_sendEmail` we make a quick check to see if our `emailAddress` value includes an `@` symbol. Wait, why? Remember, our `getUserIdentity` module could potentially return a value that's not an email address. To guard against this, we check if an `@` symbol is present in the value we receive before attempting to send an email to it. If an `@` is not found, we skip sending an email.

<figure>
  <img src="https://tmc-post-content.s3.amazonaws.com/2016-02-10_04:33:07:144_Screen Shot 2016-02-10 at 10.32.22 AM.png" alt="The final email our users will receive when they sign up.">
  <figcaption>The final email our users will receive when they sign up.</figcaption>
</figure>

If the `@` is present, we wrap our call to `Email.send()` in a [Meteor.defer()](https://themeteorchef.com/snippets/using-unblock-and-defer-in-methods/#tmc-using-meteordefer) block to prevent our app from getting tripped up in the sending process. For our email, we pass in the necessary credentials and we're off! Our email is out the door and off to our users.

Cool! But wait...how are we actually _sending_ this? Good question! This is our last step, let's take a peek.

#### Wiring this up to Accounts.onCreateUser
Last step! This is where everything comes together. With out module in place, all we need to do is call it. To complete the circle on this, we're going to add a call to Meteor's `Accounts.onCreateUser()` callback which is fired whenever a new user—oAuth or password-based—is added to our application.

<p class="block-header">/server/admin/on-create-user.js</p>

```javascript
Accounts.onCreateUser( ( options, user ) => {
  let profile = options.profile;

  Modules.server.sendWelcomeEmail( user, profile );

  if ( profile ) {
    user.profile = profile;
  }
  
  return user;
});
```

A few things to note here. First, when we call this method, we're technically short-circuiting Meteor's account creation process. Because of this, we need to make sure we keep the existing functionality in place. More specifically, we need to return a final `user` object that Meteor can use to store our user in the database. Before we do, we want to make sure to assign the user's `profile` field if `options.profile` exists. If it does, we assign it to `user.profile` before returning.

Back to our course of action, we can see our method being put to use near the top of our call. Simple as that! All we need to do is call `sendWelcomeEmail`, passing in the expected `user` information and `profile` information. Now, whenever a user signs up for our application, they'll get a neat welcome email!

Give yourself a pat on the back, we're all done! We now have a fully functional oAuth and password-based login system.

### Wrap up & summary
In this recipe, we learned how to wire up our own authentication workflow in Meteor. We learned how to set up support for oAuth login providers, as well as add the means for both signing up and logging into our application using an email and password combination. We also learned how to create a custom helper to delegate finding our user's email address regardless of account type. Finally, we learned how to tap into Meteor's `Accounts.onCreateUser` callback to send off a fancy email whenever anyone joins our app.