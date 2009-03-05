package com.as3collections.iterators
{
	import com.as3collections.queues.ArrayQueue;
	import flash.display.DisplayObjectContainer;

	public class DisplayListIterator implements IIterator
	{
		private var queue:ArrayQueue;
		
		public function DisplayListIterator( owner:DisplayObjectContainer )
		{
			queue = new ArrayQueue();
			
			var index:int = 0;
			while ( index < owner.numChildren )
				queue.enqueue( owner.getChildAt( index++ ) );
		}
		
		public function get hasNext():Boolean
		{
			return !queue.isEmpty;
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