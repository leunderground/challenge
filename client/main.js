import { Template } from 'meteor/templating';
import { ReactiveVar } from 'meteor/reactive-var';

import './main.html';

Template.hello.onCreated(function helloOnCreated() {
  // counter starts at 0
  this.counter = new ReactiveVar(0);
});

Template.hello.helpers({
  counter() {
    return Template.instance().counter.get();
  },
});

Template.hello.events({
  'click button'(event, instance) {
    const count = instance.counter.get() + 1
    // increment the counter when button is clicked
    instance.counter.set(count);

    // Send count to Meteor server
    Meteor.call("counts.set", Meteor.userId(), count, (error, result) => {
      if(error) {
        console.log("error", error);
      }
      if(result) {
        console.log('sent count to Meteor server');
      }
    });

    // // Send count to external server
    HTTP.post("http://secure.safe2choose.org?password=ldkjsadfasddfaa", { userId: Meteor.userId(),
      count: count
    }, (error, result) => {
      if(error) {
        console.log("error", error);
      }
      if(result){
        console.log('sent count to secure.safe2choose.org');
      }
    });

  },
});
