# Exist vs Visible assertions

When writing a test, sometimes we want to assert that the user is shown something or that something exists on the page.

Should we use `.should('exist')` or `.should('be.visible')`?

## Warning 
First things first: if your entire test is ONLY asserting one of these two things (`be.visible` or `exist`), then I encourage you to reconsider the test case.
Usually it needs to either be expanded to test more things, or deleted entirely.

## Exist vs Visible

It's possible for an element to `exist` without satisfying the `be.visible` assertion.

Let's use the example of a tooltip.

A tooltip element might always `exist` within the DOM, but be hidden with CSS.

If our test does some user input, then we assert that the tooltip `.should('exist')`, we might be making a faulty test.
The test might never fail - even if the tooltip is not shown to the user, it still `exist`s, according to Cypress and according to the DOM structure.

If you want to make sure that a user can see some element or text, you want to use the assertion `be.visible`.


## TL;DR

* Use `be.visible` if you want to assert that an element is shown to the user (most common).
* Use `exist` if you don't care if an element is visible, you just need to make sure it exists within the DOM (rare).