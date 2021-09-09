# Don't use one function when you really need two

Sometimes you'll have an existing function, and maybe you want to add functionality.
To accomplish the additional functionality, you may add a flag as an argument, like `isFoo` or `shouldBar`.

When you're adding the flag, consider this:

> Does the new functionality need to be a new function entirely?

---

```javascript
function purchaseItem(item, isGuest) {
    if (!checkStock(item)) {
        throw new Error(`${item} is not in stock - cannot purchaseItem`);
    }
    
    
}