package com.as3collections.iterators
{
	import com.as3collections.iterators.IIterator;
	import com.as3collections.stacks.IStack;
	import com.as3collections.queues.ArrayQueue;

	public class StackIterator implements IIterator
	{
		private var queue:ArrayQueue;
		
		public function get hasNext():Boolean { return !queue.isEmpty; }
		
		public function StackIterator( stack:IStack )
		{
			queue = new ArrayQueue();
			
			while ( !stack.isEmpty )
				queue.enqueue( stack.pop() );
				
			var items:Array = queue.array.slice( 0 );
			while ( items.length )
				stack.push( items.pop() );
		}
		
		public function next():Object
		{
			return queue.dequeue();
		}
		
		public function peek():Object
		{
			return queue.head;
		}
	}
}