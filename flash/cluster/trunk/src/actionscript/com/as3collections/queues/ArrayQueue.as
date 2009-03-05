package com.as3collections.queues
{
	import com.as3collections.collections.ArrayCollection;

	/**
	 * An implementation of the IQueue data structure using an Array.  An ArrayQueue is an
	 * ArrayCollection and therefore also wraps an Array object, however, for convenience
	 * the ArrayQueue will provide a new Array if one is not specified.
	 * 
	 * @author Michael Avila
	 */
	public class ArrayQueue extends ArrayCollection implements IQueue
	{
		public function get head():Object { return array[0]; }
		
		/**
		 * Creates a new ArrayQueue.  You can either have it wrap an already
		 * existing array object, or you can not specifiy an array object and have
		 * it create a new one for you.
		 */
		public function ArrayQueue( array:Array=null )
		{
			if ( !array )
				array = new Array();
				
			super( array );
		}
		
		public function enqueue(object:Object):void
		{
			array.push( object );
		}
		
		public function dequeue():Object
		{
			return array.shift();
		}
	}
}