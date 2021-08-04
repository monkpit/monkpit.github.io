# Don't shorten names

## Shortening a name to avoid duplicating names: 🔴
If you have something called `flight` and something called `flt`, the names need to be *different* - not shortened or abbreviated.


Add some context to the names to differentiate them - `outboundFlight` and `inboundFlight` or something.
Use [destructuring](https://hacks.mozilla.org/2015/05/es6-in-depth-destructuring/) to rename destructured parameters when appropriate.

```javascript
// 🔴 bad - 2 different objects with similar names
const flight = response.body.trips.routes.outbound.flight;
const flt = response.body.trips.routes.inbound.flight;
processFlight(flight);
processFlight(flt);

// 🔴 bad - 1 used and 1 unused, with similar names
const flight = response.body.trips.routes.outbound.flight;
const flt = getValidFlightInfo(flight);
// call it something different - like `validFlight`

// 🟢 good
const { outbound, inbound } = response.body.trips.routes;
const { flight: outboundFlight } = outbound;
const { flight: inboundFlight } = inbound;
processFlight(outboundFlight);
processFlight(inboundFlight);

// 🟢 also good - just reuse `outbound` and `inbound`
const { outbound, inbound } = response.body.trips.routes;
processFlight(outbound.flight);
processFlight(inbound.flight);
// we could also potentially have `processFlight` accept the `inbound/outbound` objects directly
```

---

## Shortening a name because it's too long to type: 🔴

Modern editors have completion features.
If you type part of a name and press `tab` (or possibly some other key combo) it will fill in the entire name.
If you find yourself naming `flight` as `flt` or `f` just to avoid typing, let the editor do the work for you.

```javascript
// 🔴 bad
const f = response.body.trips.routes.outbound.flight;

// 🟢 good
const { flight } = response.body.trips.routes.outbound;
```

Exception: sometimes a very short name can be acceptable within a short anonymous function body, but I still prefer to avoid it:

```javascript
// 🟡 acceptable
// the name `el` is acceptable because there is high locality.
// it's clear what the name means because of the immediate context
// and it is used only once.
const foos = array.map(el => el.foo);

// 🟢 preferred
// however, temporary variables like this are called `points`
// in Functional Programming style, we strive to eliminate them
// which is called `pointfree`
// https://kyleshevlin.com/just-enough-fp-pointfree
const _ = require('lodash');
const foos = array.map(_.property('foo'));
```

---

## Shortening a name because it's too verbose: 🟢

Names like `flightOptionsForAncillaryProductPassengers` can be shortened because they contain more information than is strictly necessary.

Consider rearranging the name to communicate the same thing more efficiently: `ancillaryFlightOptions`

---

## TL;DR

Name things succinctly, but with enough context to be meaningful within the surrounding code.
Your team will thank you!