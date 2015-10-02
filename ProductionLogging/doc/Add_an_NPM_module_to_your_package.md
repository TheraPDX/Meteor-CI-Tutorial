---
.left-column[
  ### NPM module
.footnote[.red.bold[] [Table of Contents](./)] 
<!-- H -->]
.right-column[
~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ - o 0 o - ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

#### Add the NPM logger module Bunyan to your package.

Meteor supports 'npm' modules with the package NPM. 

Edit ```'${PKG_NAME}-tests.js'``` again adding :

```const Bunyan = require('bunyan');```

```javascript
/**
 * Tinytest unit tests
 * @namespace Tinytest
 */
const Bunyan = require('bunyan');  //  ADD! <--
```

... save, start up Meteor and observe the command line logs and the browser console. The NodeJS command on its own, **will not work**. We need ```require``` from the Npm package, so try ```const Bunyan = Npm.require('bunyan'); ```  instead.

We now need to fix ```"Error: Cannot find module 'bunyan'"!```



<!-- B -->]