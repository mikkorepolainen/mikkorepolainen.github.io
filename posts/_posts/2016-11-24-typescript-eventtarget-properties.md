---
layout: post
title: Accessing TypeScript EventTarget Properties
relativeroot: ../../../../
category: posts
alt_excerpt: ...or how to solve error TS2339: Property 'value/type/checked/etc...' does not exist on type 'EventTarget'.
---

Started getting `error TS2339: Property '<prop>' does not exist on type 'EventTarget'` errors from code that tries to access `event.target.<prop>` after upgrading TypeScript 2.0.3.0 to 2.0.6.0.

Apparently, the SyntheticEvent<T> interface has changed at some point so, that the target property is no longer generic, but currentTarget is.

In many cases, the target and currentTarget properties are interchangeable (event handler is attached directly to the control emitting the event, see [here](http://stackoverflow.com/questions/10086427/what-is-the-exact-difference-between-currenttarget-property-and-target-property) for an explanation of the properties). Otherwise, you can get rid of the error message by either using the square bracket notation or by casting to the correct type:

- `event.currentTarget.prop`
- `event.target["prop"]`
- `(<HTMLInputElement>event.target).prop` (`(event.target as HTMLInputElement).prop` syntax is required in tsx (TypeScript-JSX) code if doing React).
