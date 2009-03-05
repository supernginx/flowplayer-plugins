package com.as3collections.trees
{
	import com.as3collections.collections.ArrayCollection;
	import com.as3collections.queues.ArrayQueue;
	import com.as3collections.queues.IQueue;
	import com.as3collections.visitors.IVisitor;
	import com.as3collections.visitors.IPrePostVisitor;
	import flash.utils.getQualifiedClassName;
	import com.as3collections.iterators.IIterator;
	import com.as3collections.iterators.TreeIterator;

	public class ArrayTree extends ArrayCollection implements ITree
	{
		private var _key:Object;
		public function get key():Object { return _key; }
		
		public override function get isEmpty():Boolean { return key == null; }
		
		public function get isLeaf():Boolean { return !(key is ITree); }
		public function get children():uint { return array.length; }
		
		public function ArrayTree( key:Object )
		{
			_key = key;		
			super(  new Array() );
		}
		
		public override function accept( visitor:IVisitor ):void
		{
			breadthFirstTraversal( visitor );
		}
		
		public function getChildTree( index:int ):ITree
		{
			return array[ index ];
		}
		
		public function addChildTree( tree:ArrayTree ):void
		{
			array.push( tree );
		}
		
		public function removeChildTree( tree:ArrayTree ):ArrayTree
		{
			return array.splice( array.indexOf( tree ), 1 )[0];
		}
		
		public override function getIterator():IIterator
		{
			return new TreeIterator( this );
		}
		
		public function breadthFirstTraversal( visitor:IVisitor ):void
		{
			var queue:IQueue = new ArrayQueue();
			
			if ( !isEmpty )
				queue.enqueue( this );
				
			while ( !queue.isEmpty && !visitor.isDone )
			{
				var head:ITree = ITree( queue.dequeue() );
				
				visitor.visit( head.key );
				for ( var i:int=0; i<head.children; i++ )
				{
					var tree:ITree = head.getChildTree( i );
					if ( !tree.isEmpty )
						queue.enqueue( tree );
				}
			}
		}
		
		public function depthFirstTraversal( visitor:IPrePostVisitor ):void
		{
			if ( visitor.isDone )
				return;
			
			if ( !isEmpty )
			{
				visitor.preVisit( key );
			
				for ( var i:int=0; i<children; i++ )
					getChildTree( i ).depthFirstTraversal( visitor );
				
				visitor.postVisit( key );
			}
		}

		public override function toString():String
		{
			var className:String = getQualifiedClassName( this );
			return "[" + className.slice( className.lastIndexOf( ":" ) + 1, className.length ) + " " + key + " - " + array.toString() + " ]";
		}
	}
}