# Description

This is a simple blog built using [Event Sourcing][1].  It is provided
in the form of a gem to stay independent of any web framework.  All
the business logic is contained in this gem, the task that is left for
the web framework is to handle the web -- accepting requests, parsing
parameters and building responses.

[1]: http://martinfowler.com/eaaDev/EventNarrative.html#EventSourcing

# Features

The following features are to be implemented:

- [X] Write a post
- [X] Edit a post
- [X] Comment on a post.  Any comment needs to be verified by email.
- [X] Approve/reject a comment.  Comments only appear on the page
  after they have been approved.  In case of rejection, the commenter
  should get notified.

# What's missing

Currently events are just stored and not processed any further to
maintain secondary views of the data, such as REST resources or a
database.

A command line tool for controlling the application without a web
server would be nice.