# Preserving State

Cypress makes it really, REALLY hard to store state.

```javascript
describe('Some tests that need to be set up', () => {
    // Will `setupData` run Cypress commands?
    // If you already drank the kool-aid, you're out of luck.
    // Cypress commands can't run outside of test lifecycle,
    // so you can't run `setupData` here.
    // Even if you could, you'd have to use .then() to access the result.
    const testData = setupData();

    testData.each(generateTestCases);
});
```

They say "it's for your own good", but if you're reading this, you have probably found out that it's kind of a pain.

So here are some recipes for storing state in Cypress across tests.

---

## let \<variable\> and use it later
This approach was the most simple to understand for me, when starting with Cypress.
But, it has lots of drawbacks and gotchas, since Cypress isn't plain JavaScript.

### The approach

This approach causes what I call "Cypress Gymnastics" - you have to jump through many hoops for this to work.

```javascript
// assuming setupData() is some function running Cypress commands and returning wrapped Cypress object...
describe('Some tests that need to be set up', () => {
    let testData;

    before(() => {
        setupData().then(data => {
            testData = data;
        });
    });

    // Oops - this doesn't work now.
    // `testData` is undefined outside of the test lifecycle!
    testData.each(generateTestCase);

    // This works fine, though.
    it('can test something', () => {
        cy.get('[data-test=firstName]').should('contain', testData.firstName);
    });
});
```

### Pros
* Somewhat easy to understand for a newcomer (until you hit edge cases - which you will)
* Type checked variables and intellisense (if using TypeScript)
* no magic strings
* resembles normal JavaScript, apart from the Cypress `.then()` requirement.

### Cons
* You WILL hit edge cases if you try to do anything remotely complicated.
* You have to be able to reason about whether or not your variable will be defined at the time you want to use it (and you will probably be surprised and annoyed when it is not).

---

## Alias and .as()

This is the more "Cypress-approved" way to preserve state - aliasing values using the Cypress `.as()` chainable command.

### Alias approach #1

```javascript
// assuming setupData() is some function running Cypress commands and returning wrapped Cypress object...
describe('Some tests that need to be set up', () => {
    before(() => {
        setupData().as('testData');
    });

    // Oops - this doesn't work.
    // We can't use `cy.get` to get the aliased value back
    // when we are not inside a test.
    cy.get('@testData').each(parameterizedTest);

    // This works fine, though.
    it('can test something', () => {
        cy.get('testData').then(testData => {
            // Welcome to callback hell!
            cy.get('[data-test=firstName]').should('contain', testData.firstName);
        });
    });
});
```

There's a different approach provided by the Cypress team which they seem to discourage, but it is more appealing to me.

You can access aliased values on the `this` object of any test function.

### Alias approach #2
```javascript
// assuming setupData() is some function running Cypress commands and returning wrapped Cypress object...
describe('Some tests that need to be set up', () => {
    before(() => {
        // con - `.as()` takes a magic string!
        // consuming functions must be aware of the alias name
        setupData().as('testData');
    });

    // Note the use of `function () {}` instead of arrow function
    // so that we can access `this`.
    it('can test something', function () {
        // Say goodbye to those nested callbacks!
        cy.get('[data-test=firstName]')
            .should('contain', this.testData.firstName);
    });

    // if we have any parameterized tests, they either have to be hard-coded with
    // the magic string, or they have to accept string parameters.
    // And there's no guarantee you didn't make a typo!
    parameterizedTest('testData');
});

// maybe our implementation looks like this:
const parameterizedTest(alias) =>
    it('can test something else', function () {
        const { firstName } = this[alias];
        cy.get('[data-test=firstName]').should('contain', firstName);
    });
```

### Alias approach #3 - avoiding magic strings
After some experimentation, I like this approach.

Assign the alias name to a variable with the same name - like `testData = 'testData'`.

Then, instead of having to hard-code magic strings across your specs, you can just define them in 1 place and reference them indirectly afterwards.

You can even pass them as parameters!

As long as you implement it correctly - like this:

```javascript
// assuming setupData() is some function running Cypress commands and returning wrapped Cypress object...
describe('Some tests that need to be set up', () => {
    // We can create a variable with the name of the alias
    // and it will feel a bit nicer to use.
    const testData = 'testData';
    before(() => {
        // Now, we pass in the variable instead of the raw string.
        // it feels somewhat like you're 'assigning' the value to the variable.
        setupData().as(testData);
    });

    // Note the use of `function () {}` instead of arrow function
    // so that we can access `this`.
    it('can test something', function () {
        // Use indirect property accessor so that the code will still work
        // if someone changes the string `testData` to something else.
        cy.get('[data-test=firstName]')
            .should('contain', this[testData].firstName);
    });

    // if we have any parameterized tests,
    // they can take `testData` as a parameter
    parameterizedTest(testData);
});

// maybe our implementation looks like this:
const parameterizedTest(alias) =>
    it('can test something', function () {
        const { firstName } = this[alias];
        cy.get('[data-test=firstName]').should('contain', firstName);
    });

```

---

## Ol' reliable - aka cy.writeFile

This approach will always work, but it's really overkill for most needs.

---

## Alternative approach - setup without Cypress commands if possible
Use async/await and do not use Cypress to set up your data. Async mixed with Cypress is a whole different topic, and a whole different headache... I have grown to prefer testing tools that don't pull any punches, don't hold your hand, everything is explicit, and the JavaScript you write Just Works™.

---

## TL;DR