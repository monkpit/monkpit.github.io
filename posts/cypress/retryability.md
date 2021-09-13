# Cypress Retryability

Cypress has a [setting to allow tests to retry.](https://docs.cypress.io/guides/guides/test-retries)


A test is 'retryable' if it can fail once, then pass on a subsequent retry.


Tests are often written without retryability in mind.
If retries are enabled globally in a Cypress project and a test is not retryable, then it will increase the time it takes for a failing test run to actually fail.

Consider this test block:

```javascript
describe('The user', () => {
  before(() => {
    cy.visit('/');
  });

  it('can log in', () => {
    cy.get('.user').type('asdf');
    cy.get('.pass').type('secret');
    cy.get('.login-submit').click();
    cy.get('.greeting').should('contain', 'Hello, asdf!');
  });

  it('can access user settings', () => {
    cy.get('a.account-settings').click();
    cy.get('.settings .avatar').should('be.visible');
  });

  it('can access direct messages', () => {
    // we stage the test using the back command
    cy.go('back');
    cy.get('a.messages').click();
    // What if the next line is flaky?
    cy.get('.unread-messages').should('contain', 'testing');
  });
});
```

If the last line is flaky, maybe it fails.

But, we think, it's ok because the test will just retry.

Right?

Not exactly...

The test is relying upon the page being in a given state at the start of the `it` block.
That is, we are relying upon the previous block clicking on `a.account-settings` before the last test is run.

Since the test uses `cy.go('back')`, we have permanently altered the starting state of the test during the test itself.

So, even if we retry, we will try to go back for a 2nd time, and it will fail.

---

## Hooks and the Cypress Retry flow

What about that `before` hook (aka `beforeAll`)?
Won't it be able to help us during the retry?

Actually, if a test fails, Cypress will do the following:
* Mark the failed `it` block
* Evaluate the context to find _only_ the `beforeEach/afterEach` hooks (if they exist)
* Re-run the `beforeEach` hook with the exact state of the page after the failed `it` block
* Re-run the `it` block
* Run the `afterEach` hook
* If the test failed, repeat the process until either the test passes, or the retry limit is reached.

So, `before` and `after` hooks are actually completely excluded from the retry cycle.

---

## Test state: Speed vs Flake
So, we have run into a bit of a dilemma: speed vs flake.

Should we set up a known state before each and every test so we can retry?
Or should we just accept flake and failures and have fast test runs?

---

## Solutions

### Solution 1: Write retryable tests

I have taken to testing every new spec with a helper function that I call `failOnce` registered as an `afterEach` hook.

```javascript
let shouldPass = false;

// This function will alter between fail / pass, starting with fail.
const failOnce = () => {
  // if you were to use `expect` here it would not work correctly
  // since execution will stop after `expect` fails
  cy.wrap(shouldPass, { timeout: 0 }).should('be.true');
  shouldPass = !shouldPass;
};
```

The `failOnce` function will start with `shouldPass = false` and fail the test in the `afterEach` hook.
Then, the test will run again with `shouldPass = true`, and if the test was written to be retryable, the test will pass.


```javascript
describe('cypress', () => {

  afterEach(failOnce);

  it('can retry a test', { retries: 2 }, () => {
    cy.wrap('foo').should('equal', 'foo');
  });
});
```

The test can fail if:
* the test is flaky
* the test is not written to be retryable

---

### Solution 2: Snapshot application state, aka "Savestates"

If you have the ability to snapshot and restore the application state by modifying cookies/localStorage/applicationStorage, then there are two approaches:
* snapshot in a `before` and restore in a `beforeEach` to a single known state (seems ideal)
* or possibly snapshot in `before` and then `afterEach` and restore in `beforeEach` depending on desired behavior / DOM manipulation in tests


## TL;DR

* Don't rely upon previous tests to set up the DOM for you.
* Write tests that are atomic and can be rerun individually as many times as needed.
* Consider the retry cycle and hooks - `beforeEach -> it -> afterEach` executes during a retry.
* Test for retryability with `afterEach(failOnce)`.
* If it's practical, snapshot application state (cookies, applicationStorage, localStorage) and restore it as desired.
* Enable retries on a per-describe or per-it basis if needed, or override the global setting.