package com.as3collections.visitors
{
	public interface IPrePostVisitor extends IVisitor
	{
		function preVisit( object:Object ):void;
		function postVisit( object:Object ):void;
	}
}