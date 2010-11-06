// (c) 2007 Ian Thomas
// Freely usable in whatever way you like, as long as it's attributed.
package com.awen
{
  public class Callback
  {
    // Create a wrapper for a callback function.
    // Tacks the additional args on to any args normally passed to the
    // callback.
    public static function create(handler:Function,...args):Function
    {
      return function(...innerArgs):void
      {
        handler.apply(this,innerArgs.concat(args));
      }
    }
  }
}