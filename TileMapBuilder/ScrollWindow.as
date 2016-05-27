package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	public class ScrollWindow extends MovieClip{
		
		private var contentY:Number;
		private var lastContentY:Number;
		
		public var scrolled:Boolean = false;
		
		private var _contentMC:Sprite;
		private var maskMC:MovieClip;
		private var contentBG:MovieClip;
		
		private var maskW:Number = 100;
		private var maskH:Number = 200;
		
		
		public function ScrollWindow() {
			// constructor code
			
		}
		
		public function set contentMC(mc:Sprite):void{
			_contentMC = mc;
			initializeAsset();
		}
		
		public function set maskWidth(val:Number):void{
			maskW = val;
			drawMask();
		}
		
		public function set maskHeight(val:Number):void{
			maskH = val;
			drawMask();
		}
		
		public function redrawWindow():void{
			drawMask();
		}
		
		private function addAssets():void{
			this.addChild(contentBG);
			this.addChild(_contentMC);
			this.addChild(maskMC);
		}
		
		private function createAssets():void{
			contentBG = new MovieClip();
			
			maskMC = new MovieClip();
			maskMC.name = "mask";
			drawMask();
		}
		
		private function createEvents():void{
			_contentMC.addEventListener(MouseEvent.MOUSE_DOWN, onContentClick);
			_contentMC.addEventListener(MouseEvent.MOUSE_UP, onContentRelease);
		}
		
		private function drawMask():void{
			if(maskMC != null && _contentMC.width > 10){
				maskMC.graphics.clear();
				maskMC.graphics.beginFill(0x00cccc,0.75);
				maskMC.graphics.drawRect(0,0,maskW,maskH);
				maskMC.graphics.endFill();
				_contentMC.mask = maskMC;
				
				contentBG.graphics.clear();
				contentBG.graphics.beginFill(0xa3a3a3,0.75);
				contentBG.graphics.drawRect(-3,-3,_contentMC.width + 6,(_contentMC.height < maskH)?_contentMC.height + 6:maskH+ 6);
				contentBG.graphics.endFill();
				
			}
		}
				
		public function onContentClick(e:MouseEvent):void{
			contentY = mouseY;
			scrolled = false;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onContentMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onContentRelease);
			
		}
		
		public function onContentRelease(e:MouseEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onContentMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onContentRelease);
		}
		
		public function onContentMove(e:MouseEvent):void{
			
			if(_contentMC.height > maskMC.height){
				lastContentY = contentY;
				contentY = mouseY;
				var dif:Number = contentY - lastContentY;
				if(_contentMC.y + dif < maskMC.height - _contentMC.height){
					_contentMC.y = maskMC.height - _contentMC.height;
				}else if(_contentMC.y + dif > 0){
					_contentMC.y = 0;
				}else{
					_contentMC.y += dif;
				}
			}
			
			scrolled = true;			
		}
		
		public function showMe(target:DisplayObjectContainer):void{
			target.addChild(this);
		}
		
		private function initializeAsset():void{
			createAssets();
			addAssets();
			createEvents();
		}

	}
	
}
