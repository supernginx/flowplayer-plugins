package org.flowplayer.related
{
	import com.adobe.utils.ArrayUtil;
	import flash.display.Sprite;
	import org.ascollada.utils.StringUtil;
	
	
	public class Pager
	{
		private var _totalItems:Number = 0;
		private var _totalPages:Number = 0;
        private var _oldPage:Number = 0;
        private var _currentPage:Number = 0;
		private var _perPage:Number;
		private var _itemData:Array;
		private var _pageData:Array = [];
		private var _pageInfoText:String;
		private var _firstRecord:Number;
		private var _pageChangeHandler:Function;
		private var _nextBtn:Sprite;
		private var _prevBtn:Sprite;
		
		
		private var _options:Object = {
			//totalItems: 0,
			itemData: [],
			pageInfoText: "{0} - {1} of {2}",
			pageChangeHandler: pageChangeHandler
			//perPage: 7
			
		};
		
		
		public function Pager(options:Object)
		{
			//_setOptions(options);
			
			//_totalItems = _options["totalItems"];
			_itemData = options.itemData;
			_pageInfoText = options.pageInfoText;
			_perPage = options.perPage;
			_pageChangeHandler = options.pageChangeHandler;
			_prevBtn = options.prevBtn;
			_nextBtn = options.nextBtn;
			
			_generatePageData();
			
		}
		
		private function _setOptions(options:Object):void
		{
			var oldoptions:Array = _options as Array;
			var newoptions:Array = options as Array;
			
			_options = ArrayUtil.createUniqueCopy(oldoptions.concat(newoptions));
		}
		
		private function pageChangeHandler():void
		{
			
		}
		
		public function get isLastPage():Boolean
    	{
        	return (_currentPage + 1 == _totalPages);
    	}
    	
    	public function get isFirstPage():Boolean
    	{
        	return (_currentPage == 0);
    	}
    	
    	public function get totalPages():Number
    	{
       		return _totalPages;
    	}
    	
    	public function get perPage():Number
    	{
       		return _perPage;
    	}
    	
    	public function get pageData():Array
    	{
       		return _pageData;
    	}
    	
    	public function get totalItems():Number
    	{
        	return _totalItems;
    	}
    	
    	public function get currentPageID():Number
    	{
        	return _currentPage;
    	}
    	
    	public function set currentPageID(page:Number):void
    	{
        	_oldPage = _currentPage;
            _currentPage = page;
        	_updateNavigation();
        	_pageChangeHandler();
    	}

    	public function get previousPageID():Number
		{
			return isFirstPage ? 0 : _currentPage - 1;
		}
		
		public function get nextPageID():Number
		{
			return (isLastPage ? _currentPage : _currentPage + 1);
		}
    	
    	private function _updateNavigation():void
    	{
    		if (isLastPage)
    		{
    			_nextBtn.visible = false;
    		} else {
    			_nextBtn.visible = true;
    		}
    		
    		if (isFirstPage)
    		{
    			_prevBtn.visible = false;
    		} else {
    			_prevBtn.visible = true;
    		}
    	}
    	
    	public function getOffsetByPageId(pageid:Number = 0):Array
    	{
	        pageid = pageid > 0 ? pageid : _currentPage;
	        if (!_pageData) {
	            _generatePageData();
	        }
	
	        if (_pageData[pageid] || _itemData == null) {
	            return [
	                        Math.max((_perPage * (pageid - 1)) + 1, 1),
	                        Math.min(_totalItems, _perPage * pageid)
	                   ];
	        } else {
	            return [0, 0];
	        }
    	}
    	
    	public function getPageData(pageID:Number = -1):Array
    	{
        	pageID = pageID > 0 ? pageID : _currentPage;

        	if (!_pageData) {
            	_generatePageData();
        	}
        	
        	if (_pageData[pageID]) {
            	return _pageData[pageID];
        	}
        	
        	return [];
    	}
    	
    	public function getPageDataItem(pageID:Number = 0, index:Number = 0):Object
    	{
    		var data:Array = getPageData(pageID);
    		return data[index];
    	}
    	
    	public function getPageItemCount(pageID:Number = -1):Number
    	{
    		return getPageData(pageID >= 0 ? pageID : currentPageID).length;
    	}
    	
    	public function getResults():String
    	{
    		var _firstRecord:Number = (_currentPage * _perPage) + 1;
    		var _lastRecord:Number = !_perPage
                                  ? _totalItems
                                  : Math.min(_firstRecord + _perPage - 1,
                                        _totalItems);
                                        

            return StringUtil.substitute(_pageInfoText, _firstRecord, _lastRecord, _totalItems, _currentPage, _totalPages);
    		
    	}
    	
    	private function _generatePageData():void
    	{

	        if (_itemData) {
	            _totalItems = _itemData.length;
	        }
	        
	        _totalPages = Math.ceil(_totalItems / _perPage);
	        
	
	        var pageIndex:Number = 0;
	        var itemIndex:Number = 0;
	        if (_itemData) {
	        	_pageData[pageIndex] = [];
	        	_pageData[pageIndex][itemIndex] = [];
	        	for (var i:int = 0; i < _itemData.length; i++)
	        	{
	        		
	        		_pageData[pageIndex][itemIndex] = _itemData[i];
	        		itemIndex++;
	        		//trace(_pageData[pageIndex].length);
	        		if (_pageData[pageIndex].length >= _perPage) {
	        			
	                    //index++;
	                    itemIndex = 0;
	                    pageIndex++
	                    _pageData[pageIndex] = [];
	                }
	        	}
	            
	        }// else {
	         //   _pageData = [];
	       // }
	
	        //prevent URL modification
	        _currentPage = Math.min(_currentPage, _totalPages);
    	}


        public function get oldPage():Number {
            return _oldPage;
        }
    }
}