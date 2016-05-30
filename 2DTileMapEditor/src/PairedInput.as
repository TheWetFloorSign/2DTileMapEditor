package  {
	
	//import _lib.PlayerInfo;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.text.AntiAliasType;
	
	public class PairedInput extends MovieClip{
		
		public static const UPDATE:String = "onInputUpdate";
		
		private var _currentValue:String = "";
		private var _id:int;
		private var targetArray:Array;
		private var _fieldName:String = "";
		
		private var nameTxt:TextField;
		private var txtNum:TextField;
		
		private var nameBack:MovieClip;
		private var valueBack:MovieClip;
		
		private var charsArray:Array;

		public function PairedInput(fieldname:String = "", currentValue:String = "",id:int = 0) {
			// constructor code
			this._currentValue = currentValue;
			this._id = id;
			this._fieldName = fieldName;
			createAssets();
			addAssets();
			initialize();
		}
		
		public function set color(u:uint):void{
			//_color = u;
			removeAssets();
			createAssets();
			addAssets();
		}
		
		
		
		public function get id():int{
			return _id;
		}
		
		public function get currentValue():String{
			return _currentValue;
		}
		
		public function set currentValue(value:String):void{
			_currentValue = value;
			updateText();
		}
		
		public function get fieldName():String{
			return _fieldName;
		}
		
		public function set fieldName(value:String):void{
			_fieldName = value;
			updateText();
		}
		
		private function initialize():void{
			//createAssets();
			//addAssets();
			updateText();
			createEvents();
		}	
		
		private function updateText():void{
			txtNum.text = String(_currentValue);
			nameTxt.text = String(_fieldName);
		}
		
		public function onDown(e:MouseEvent):void{
			//trace(e.target.name);
					
			this.dispatchEvent(new Event(PlayerIncreaseNum.UPDATE));
		}
		
		
		
		private function createEvents():void{
			//this.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			this.addEventListener(KeyboardEvent.KEY_UP, textInputCapture);
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
		
		public function textInputCapture(e:KeyboardEvent):void{
			//trace("in here");
			_currentValue = txtNum.text;
			_fieldName = nameTxt.text;
		} 
		
		private function createAssets():void{
			
			
			
			nameTxt = new TextField();
			nameTxt.type = TextFieldType.INPUT;
			nameTxt.width = 60;
			nameTxt.height = 20;
			txtNum = new TextField();
			txtNum.type = TextFieldType.INPUT;
			txtNum.x = nameTxt.x + nameTxt.width + 20;
			txtNum.width = 60;
			txtNum.height = 20;
			
			
			var tempFormat:TextFormat = new TextFormat("Arial", 12, 0x000000);
			//var retro8Bit = new Font8Bit();
			nameTxt.defaultTextFormat = tempFormat;
			txtNum.defaultTextFormat = tempFormat;
			
			nameBack = new MovieClip();
			nameBack.name = "nameBack";
			nameBack.graphics.lineStyle(2, 0xBBBBBB);
			var matr:Matrix = new Matrix();
			matr.createGradientBox(10, 10, -Math.PI/2,0,1);
			nameBack.graphics.beginGradientFill(GradientType.LINEAR, [0xeeeeee,0xBBBBBB], [1, 1], [160, 255],matr);
			nameBack.graphics.drawRoundRect(nameTxt.x,nameTxt.y,60,20,8,8);
			nameBack.graphics.endFill();
			
			valueBack = new MovieClip();
			valueBack.name = "valueBack";
			valueBack.graphics.lineStyle(2,0xBBBBBB);
			valueBack.graphics.beginGradientFill(GradientType.LINEAR, [0xeeeeee,0xBBBBBB], [1, 1], [160, 255],matr);
			valueBack.graphics.drawRoundRect(txtNum.x,txtNum.y,60,20,8,8);
			valueBack.graphics.endFill();
		}
		
		private function addAssets():void{
			this.addChild(nameBack);
			this.addChild(valueBack);
			this.addChild(nameTxt);
			this.addChild(txtNum);			
		}
		
		private function removeAssets():void{
			this.removeChild(nameTxt);
			this.removeChild(txtNum);	
		}
		
		public function killMe():void{
			removeEvents();
			parent.removeChild(this);
		}

	}
	
}
