package  {
	
	import flash.events.*;
	import flash.display.GradientType;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class MC_Button extends MovieClip{
		
		public static const RELEASE:String = "onRelease";
		
		private var _labelTxt:String = "up";
		public var buttonDownTxt:String = "down";
		public var btnText:TextField = new TextField();
		public var btnBG:MovieClip = new MovieClip();
		public var btnFormat:TextFormat = new TextFormat("_sans",12,0x444444);
		public var _isToggle:Boolean = false;
		public var _showText:Boolean = true;
		public var _onButton:Boolean = true;
		public var isPressed:Boolean;
		public var isDown:Boolean = false;
		public var buffer:int = 9;
		
		public var upColor:Array = [0xBBBBBB,0xeeeeee];
		public var downColor:Array = [0x999999,0x777777];
		
		public var id:int;
		
		public function MC_Button() {
			//this.gotoAndStop("up");
			btnText.autoSize = TextFieldAutoSize.LEFT;
			btnText.selectable = false;
			btnText.defaultTextFormat = btnFormat;
			updateText();
			btnBG.name = "menuBackground";
			this.addChild(btnBG);
			this.addChild(btnText);
			btnText.x = (_isToggle)?3*buffer:buffer/2;
			this.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			this.addEventListener(MouseEvent.MOUSE_UP, onUp);
			this.addEventListener(MouseEvent.MOUSE_OUT, onCancel);
		}
		
		public function set labelTxt(string:String):void{
			_labelTxt = string;
			_showText = true;
			updateText();
		}
		
		public function get labelTxt():String{
			return _labelTxt;
		}
		
		public function set toggle(b:Boolean):void{
			_isToggle = b;
			updateText();
		}
		
		public function get toggle():Boolean{
			return _isToggle;
		}
		
		public function set pressed(b:Boolean):void{
			isDown = b;
			isPressed = isDown;
			redrawBG();
		}
		
		public function get pressed():Boolean{
			return isPressed;
		}
		
		public function get showText():Boolean{
			return _showText;
		}
		
		public function set showText(b:Boolean):void{
			_showText = b;
			updateText();
		}
		
		public function set onButton(b:Boolean):void{
			_onButton = b;
			redrawBG();
			updateText();
		}
		
		private function onDown(e:Event):void{
			
			updateState("down");
		}
		
		private function onUp(e:Event):void{
			updateState("up");
		}
		private function onCancel(e:Event):void{
			isDown = isPressed;
			updateText();
		}
		
		public function updateText():void{
			btnText.text = (_showText)?_labelTxt:"";
			btnText.x = (!_onButton)?3*buffer:buffer/2;
			redrawBG();
		}
		
		private function redrawBG():void{
			btnBG.graphics.clear();
			btnBG.graphics.lineStyle(2, 0xaaaaaa);
			var matr:Matrix = new Matrix();
			matr.createGradientBox(10, 10, -Math.PI/2,0,1);
			btnBG.graphics.beginGradientFill(GradientType.LINEAR,(isDown)?downColor:upColor, [1, 1], [160, 255],matr);
			btnBG.graphics.drawRoundRect(0,0,(!_onButton)?2*buffer:btnText.width + buffer,18,8);
			btnBG.graphics.endFill();
			if(!_onButton){
				if(isPressed){
					btnBG.graphics.lineStyle(3,0xCCCCCC);
					btnBG.graphics.moveTo(6,10);
					btnBG.graphics.lineTo(8,12);
					btnBG.graphics.lineTo(12,6);
					btnBG.graphics.endFill();
				}else{
					btnBG.graphics.lineStyle(3,0x888888);
					btnBG.graphics.moveTo(6,6);
					btnBG.graphics.lineTo(12,12);
					btnBG.graphics.moveTo(6,12);
					btnBG.graphics.lineTo(12,6);
					btnBG.graphics.endFill();
				}
			}
		}
		
		public function updateState(bState:String):void{
			switch(bState){
				case "down":
					isDown = true;
					break;
				case "up":
					if(_isToggle)isPressed = !isPressed;
					isDown = isPressed;
					this.dispatchEvent(new Event(RELEASE));
					break;
			}
				
			redrawBG();
		}

	}
	
}
