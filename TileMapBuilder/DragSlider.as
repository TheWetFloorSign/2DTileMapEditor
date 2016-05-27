package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	
	public class DragSlider extends Sprite{
		
		public static const UPDATE:String = "onDragSlideUpdate";
		
		private var handle:Sprite;
		private var line:Sprite;
		
		public var minVal:Number = 0;
		public var maxVal:Number = 60;
		
		public var startVal:Number =1;
		
		public var curVal:Number = startVal;
		
		private var curDragTar:Object;

		public function DragSlider() {
			// constructor code
		}
		
		private function initialize():void{
			createAssets();
			addAssets();
			positionAssets();
			createEvents();
		}
		
		public function handleX(n:Number):void{
			handle.x += n;
			handle.x = (handle.x < line.x-handle.width/2)?(line.x-handle.width/2) : handle.x;
			handle.x = (handle.x > line.x + line.width - handle.width/2)?(line.x + line.width - handle.width/2) : handle.x;
			findCurVal();
			this.dispatchEvent(new Event(DragSlider.UPDATE));
		}
		
		public function setCurrent(n:Number):void{
			curVal = findMinMax(n);
			handle.x = ((curVal - minVal) / (maxVal - minVal)) * line.width + (line.x - handle.width / 2);
			this.dispatchEvent(new Event(DragSlider.UPDATE));
		}
		
		private function createAssets():void{
			handle = new Sprite();
			handle.graphics.lineStyle(1,0xaaaaaa);
			handle.graphics.beginFill(0x999999,1);
			handle.graphics.drawRect(0,0,10,5);
			handle.graphics.endFill();
			
			
			line = new Sprite();
			line.graphics.lineStyle(1,0xAAAAAA,1);
			line.graphics.lineTo(60,0);
		}
		
		private function removeAssets():void{
			
		}
		
		private function addAssets():void{
			this.addChild(line);
			this.addChild(handle);
		}
		
		private function positionAssets():void{
			line.x = 5;
			line.y = handle.y + handle.height/2;
			
			var tempPrcnt:Number = startVal / maxVal;
			handle.x = (tempPrcnt * line.width) -(handle.width/2);
			
		}
		
		private function createEvents():void{
			handle.addEventListener(MouseEvent.MOUSE_DOWN, onDrag);
			handle.addEventListener(MouseEvent.MOUSE_UP, onDragRelease);
			stage.addEventListener(MouseEvent.MOUSE_UP, onDragRelease);
			
			trace("here");
		}
		
		private function removeEvents():void{
			
		}
		
		public function onDrag(e:MouseEvent):void{
			
			curDragTar = e.currentTarget;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMoveUpdate);
		}
		
		public function onDragRelease(e:MouseEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMoveUpdate);
		}
		
		private function onMoveUpdate(e:MouseEvent):void{
			//curDragTar.y = line.y - (curDragTar.height/2);
			curDragTar.x = this.mouseX - (handle.width/2);
			curDragTar.x = (curDragTar.x < line.x-curDragTar.width/2)?(line.x-curDragTar.width/2) : curDragTar.x;
			curDragTar.x = (curDragTar.x > line.x + line.width - curDragTar.width/2)?(line.x + line.width - curDragTar.width/2) : curDragTar.x;
			findCurVal();
			trace(curVal);
			this.dispatchEvent(new Event(DragSlider.UPDATE));
		}
		
		private function findCurVal():void{
			var tabx = handle.x + (handle.width/2) - line.x;
			var totalx = line.width;
			
			var tempVal = tabx/totalx;
			curVal = (((maxVal-minVal) * tempVal) + minVal);
		}
		
		private function findMinMax(n:Number):Number
		{
			if (n > maxVal)
			{
				return maxVal;
			}
			if (n < minVal)
			{
				return minVal;
			}
			return n;
		}
		
		public function showMe(target:Object):void{
			target.addChild(this);
			initialize();
		}
		
		private function killMe():void{
			removeEvents();
			removeAssets();
			parent.removeChild(this);
		}

	}
	
}
