package com.as3collections.stacks
{
	import com.as3collections.collections.DisplayListCollection;
	import com.as3collections.iterators.IIterator;
	import com.as3collections.iterators.StackIterator;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;

	public class DisplayListStack extends DisplayListCollection implements IStack
	{
		public function get top():Object { return container.getChildAt( container.numChildren - 1 ); } 
		
		public function DisplayListStack( container:DisplayObjectContainer=null )
		{
			if ( !container )
				container = new Sprite();
				
			super( container );
		}
		
		public function push(object:Object):void
		{
			if ( !(object is DisplayObject ) )
				throw new ArgumentError( "Require an object of type DisplayObject." );
				
			container.addChild( object as DisplayObject );
		}
		
		public function pop():Object
		{
			return container.removeChildAt( container.numChildren - 1 );
		}
		
		public override function getIterator():IIterator
		{
			return new StackIterator( this );
		}
	}
}