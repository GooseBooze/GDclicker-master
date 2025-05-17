The way i intend to test the program is by launching it in debug mode, as it retains all functionality and at the same time outputs errors in the debugger.
Errors might look like this:
"
E 0:00:00:615   main.gd:44 @ @implicit_ready(): Node not found: "Music" (relative to "/root/Main").
  <C++ Error>   Method/function failed. Returning: nullptr
  <C++ Source>  scene/main/node.cpp:1877 @ get_node()
  <Stack Trace> main.gd:44 @ @implicit_ready()
"
This error occurs because the variable music_controller is trying to connect itself to a non existent node named Music.

Or the error could be a visual bug or a button which have been wrongfully assigned a variable. 



Errors I have encountered while making this.

1. The amount of visual pointers would increase even when upgrading other buildings than the pointer itself.
  Fix: Assign a variable to the pointers to use instead of being created by the amount of clicks per second.

2. Pointers would not have their place saved and were placed wildly after loading a saved game.
  Fix: Make pointers be placed based on the amount of pointer upgrades i had instead of having its placement saved.

3. Used a Timer node that did nothing, yet was referenced in a lot of code.
  Fix: Removed Unused code.

4. Prices for the pointer building were increasing unrealistically.
   Fix: I changed the price to calculate the base price * 1.15 ** amount of that building
