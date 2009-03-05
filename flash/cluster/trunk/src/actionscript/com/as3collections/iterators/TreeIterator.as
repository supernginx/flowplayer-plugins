package com.as3collections.iterators
{
	import com.as3collections.stacks.ArrayStack;
	import com.as3collections.trees.ITree;
	
	public class TreeIterator implements IIterator
	{
		private var stack:ArrayStack;
		
		public function TreeIterator( tree:ITree )
		{
			stack = new ArrayStack();
			stack.push( tree );
		}
		
		public function get hasNext():Boolean
		{
			return !stack.isEmpty;
		}
		
		public function next():Object
		{
			var top:ITree = ITree( stack.pop() );
			
			for ( var i:int = top.children - 1; i >=0; --i )
			{
				var tree:ITree = top.getChildTree( i );
				if ( !tree.isEmpty )
					stack.push( tree );
			}
			
			return top.key;
		}
		
		public function peek():Object
		{
			return stack.top;
		}
	}
}