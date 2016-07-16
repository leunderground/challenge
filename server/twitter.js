Meteor.startup(() => {
  ServiceConfiguration.configurations.remove({
    service: "twitter"
  });
  ServiceConfiguration.configurations.insert({
    service: "twitter",
    consumerKey: Meteor.settings.public.twitter.k,
    loginStyle: "popup",
    secret: Meteor.settings.public.twitter.s
  });
})
