package  {
	
	//import _lib.PlayerInfo;
	import flash.display.*;
	import flash.events.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.text.AntiAliasType;
	
	public class PlayerIncreaseNum extends MovieClip{
		
		public static const UPDATE:String = "onNumberUpdate";
		
		private var minNum:int;
		private var maxNum:int;
		private var incValue:Number;
		private var _currentValue:Number;
		private var _id:int;
		private var targetArray:Array;
		private var fieldName:String = "";
		
		private var _color:uint = 0x000000;
		
		private var nameTxt:TextField;
		private var txtNum:TextField;
		private var arrowDec:MovieClip;
		private var arrowInc:MovieClip;
		
		private var charsArray:Array;

		public function PlayerIncreaseNum(currentValue:Number, minNum:int = 0, maxNum:int = 8, incValue:Number = 1, fieldName:String = "",id:int = 0) {
			// constructor code
			this._currentValue = currentValue;
			this._id = id;
			this.minNum = minNum;
			this.maxNum = maxNum;
			this.incValue = incValue;		
			this.fieldName = fieldName;
			createAssets();
			addAssets();
			
		}
		
		public function set color(u:uint):void{
			_color = u;
			removeAssets();
			createAssets();
			addAssets();
		}
		
		public function get currentValue():Number{
			return _currentValue;
		}
		
		public function get id():int{
			return _id;
		}
		
		public function set currentValue(value:Number):void{
			_currentValue = value;
			if(_currentValue > maxNum)_currentValue = maxNum;
			if(_currentValue < minNum)_currentValue = minNum;
			updateText();
		}
		
		private function initialize():void{
			//createAssets();
			//addAssets();
			updateText();
			createEvents();
		}		
		
		private function nextCharacter():void{
			if(_currentValue < maxNum){
				_currentValue+=incValue;
			}
			trace(_currentValue);
			updateText();
		}
		
		private function previousCharacter():void{
			if(_currentValue > minNum){
				_currentValue-=incValue;
			}
			updateText();
		}
		
		private function updateText():void{
			txtNum.text = String(_currentValue);
		}
		
		public function onDown(e:MouseEvent):void{
			trace(e.target.name);
			if(e.target.name == "arrowDec"){
				previousCharacter();
			}
			
			if(e.target.name == "arrowInc"){
				nextCharacter();
			}		
			this.dispatchEvent(new Event(PlayerIncreaseNum.UPDATE));
		}
		
		
		
		private function createEvents():void{
			this.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
		
		private function removeEvents():void{
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
		
		public function showMe(target:Sprite):void{
			target.addChild(this);
			initialize();
		}
		
		private function dispatchInputFinEvent():void{
			
		}
		
		private function createAssets():void{
			arrowDec = new MovieClip();
			arrowDec.name = "arrowDec";
			arrowDec.graphics.lineStyle(5,_color);
			arrowDec.graphics.beginFill(_color,1);
			arrowDec.graphics.moveTo(12,0)
			arrowDec.graphics.lineTo(12,16);
			arrowDec.graphics.lineTo(0,8);
			arrowDec.graphics.lineTo(12,0);
			arrowDec.graphics.endFill();
			
			arrowInc = new MovieClip();
			arrowInc.name = "arrowInc";
			arrowInc.graphics.lineStyle(5,_color);
			arrowInc.graphics.beginFill(_color,1);
			arrowInc.graphics.lineTo(12,8);
			arrowInc.graphics.lineTo(0,16);
			arrowInc.graphics.lineTo(0,0);
			arrowInc.graphics.endFill();
			
			nameTxt = new TextField();
			nameTxt.x = arrowDec.width;
			nameTxt.width = 20;
			nameTxt.height = 20;
			txtNum = new TextField();
			txtNum.x = arrowDec.width;
			txtNum.width = 20;
			txtNum.height = 20;
			
			if(fieldName !=""){
				var tempFormat:TextFormat = new TextFormat();
				//var retro8Bit = new Font8Bit();
				tempFormat.size = 12;
				tempFormat.align = TextFormatAlign.LEFT;
				tempFormat.font = "Arial";
				tempFormat.bold = true;
				nameTxt.autoSize = TextFieldAutoSize.LEFT;
				nameTxt.defaultTextFormat = tempFormat;
				nameTxt.antiAliasType = AntiAliasType.ADVANCED;
				nameTxt.text = fieldName;
				arrowDec.y = nameTxt.height;
				arrowInc.y = nameTxt.height;
				txtNum.y = nameTxt.height;
			}
			
			arrowInc.x = txtNum.width + txtNum.x;
		}
		
		private function addAssets():void{
			this.addChild(arrowDec);
			this.addChild(arrowInc);
			this.addChild(nameTxt);
			this.addChild(txtNum);			
		}
		
		private function removeAssets():void{
			this.removeChild(arrowDec);
			this.removeChild(arrowInc);
			this.removeChild(nameTxt);
			this.removeChild(txtNum);	
		}
		
		public function killMe():void{
			removeEvents();
			parent.removeChild(this);
		}

	}
	
}
