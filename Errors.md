Errors I have encountered while making this.

1. The amount of visual pointers would increase even when upgrading other buildings than the pointer itself.
  Fix: Assign a variable to the pointers to use instead of being created by the amount of clicks per second.

2. Pointers would not have their place saved and were placed wildly after loading a saved game.
  Fix: Make pointers be placed based on the amount of pointer upgrades i had instead of having its placement saved.

3. Used a Timer node that did nothing, yet was referenced in a lot of code.
  Fix: Removed Unused code.
