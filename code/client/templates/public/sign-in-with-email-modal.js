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
