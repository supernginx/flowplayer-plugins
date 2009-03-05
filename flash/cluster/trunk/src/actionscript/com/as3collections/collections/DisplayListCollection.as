package com.as3collections.collections
{
	import com.as3collections.iterators.DisplayListIterator;
	import com.as3collections.iterators.IIterator;
	import com.as3collections.visitors.IVisitor;
	
	import flash.display.DisplayObjectContainer;

	public class DisplayListCollection implements ICollection
	{
		private var _container:DisplayObjectContainer;
		public function get container():DisplayObjectContainer { return _container; }
		
		public function get count():uint { return container.numChildren; }
		public function get isEmpty():Boolean { return count == 0; }
		
		public function DisplayListCollection( container:DisplayObjectContainer=null )
		{
			_container = container;
		}
		
		public function accept(visitor:IVisitor):void
		{
			var iterator:IIterator = getIterator();
			while ( iterator.hasNext && !visitor.isDone )
				visitor.visit( iterator.next() );
		}
		
		public function clear():void
		{
			while ( container.numChildren )
				container.removeChildAt( 0 );
		}
		
		public function getIterator():IIterator
		{
			return new DisplayListIterator( container );;
		}
	}
}