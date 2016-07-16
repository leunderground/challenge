Meteor.methods({
  'counts.set': function(userId, num) {
    if(Meteor.userId()) {
      const count = Counts.findOne({userId})
      if(count) {
        // count already exists for user, update
        Counts.update(count._id, {num})
      } else {
        // if no count set for userId, insert
        Counts.insert({userId, num});
      }

      return num;
    } else {
      throw Meteor.Error("Not allowed to set count")
    }
  }
});
