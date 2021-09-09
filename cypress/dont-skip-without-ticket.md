# Don't skip tests without creating a ticket

Eventually you'll probably find yourself doing this:

```javascript
// skipping the test for now, it is flaky due to a bug
it.skip('The user can checkout with a coupon', () => {
    // ... etc ...
});
```

Well, it's fine to do this.

Flaky tests are a part of reality with browser testing.
It's pretty much impossible to have every test pass every time, once your application has a sufficient level of complexity.

How can we improve this code?
It doesn't even do anything!

---

## Communicate to the future devs!

We should not merge this change until it contains a reference to a ticket/card number on an issue tracker (like JIRA, etc).

Let's say you add this code, and then the team ends up kind of forgetting about it, since it is not running anymore.

Later, another dev comes to work on the tests for this feature.
They see that the tests have been skipped for some reason.
Thankfully, the last dev wrote a note - it's flaky due to some bug.
Maybe they even described the bug.

As the future dev, there is a choice to make:
* try to manually test if the feature has started working (will take time to figure it all out)
* uncomment the test and see if it works (but it was flaky, so maybe it will work... maybe it will stop working after the merge...)
* ask the team if the issue is fixed
* "pass the buck" and just do nothing, and say it's not your problem

Or, instead, we could have created an issue/ticket and referenced it here:

```javascript
// skipping the test for now, it is flaky due to a bug
// see: TEST-1234
it.skip('The user can checkout with a coupon', () => {
    // ... etc ...
});
```

Now, as the future dev, all we have to do is check if the work on TEST-1234 is finished.

---

## TL;DR

Don't merge `.skip`s without referencing an issue on your tracker.