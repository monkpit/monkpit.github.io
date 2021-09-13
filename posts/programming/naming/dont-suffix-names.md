# Don't suffix names

Don't add suffixes to variable names, especially if the suffixes are long.

```javascript
// 🔴 bad - long suffix that doesn't add value or context
// as a developer you just start to ignore most of the
// name of the variable, which defeats the purpose
const { data } = await axios(/*...*/);
const fooApiJsonResponse = data.foo;
const barApiJsonResponse = data.bar;
const bazApiJsonResponse = data.baz;

// 🟢 good - call the thing what it is
const { data } = await axios(/*...*/);
const { foo, bar, baz } = data;

// 🔴 bad - adding a suffix that just says `data` or `object`
// It's a program, we know that variables contain `data`
// so we don't need that in the name
const { data } = await axios(/*...*/);
const fooData = data.foo;
const barObject = data.bar;
const bazInfo = data.baz;
```
