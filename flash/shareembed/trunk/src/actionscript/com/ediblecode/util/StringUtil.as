package com.ediblecode.util {

	import com.chewtinfoil.utils.StringUtils;
	/**
	 * @author danielr
	 */
	public class StringUtil
	{
	public static function formatString(original:String, ...args:*):String
	{
	var replaceRegex:RegExp = /\{([0-9]+)\}/g;
	return original.replace(replaceRegex, function():String {
	if(args == null)
	{ return arguments[0]; }
	else
	{
	var resultIndex:uint = uint(StringUtils.between(arguments[0], '{', '}'));
	return (resultIndex < args.length) ? args[resultIndex] : arguments[0];
	}
	});
	} }
}
