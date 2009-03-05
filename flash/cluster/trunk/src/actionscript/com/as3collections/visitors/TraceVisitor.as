package com.as3collections.visitors
{	
	public class TraceVisitor implements IPrePostVisitor
	{
		public function get isDone():Boolean
		{
			return false;
		}
		
		public function preVisit( object:Object ):void 
		{
			trace( object );
		}
		
		public function visit( object:Object ):void
		{
			trace( object );
		}
		
		public function postVisit( object:Object ):void {}
	}
}