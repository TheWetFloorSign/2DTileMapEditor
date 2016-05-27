package ref {

	import flash.display.*;
	import flash.events.*;
	
	public class MovingObject extends MovieClip{
        
		public static const LEFT:int = 1;
		public static const RIGHT:int = 2;
		public static const UP:int = 3;
		public static const DOWN:int = 4;	
		
		private var _speed:Number;
		private var _distance:int;
		private var _distanceCount:Number;
		private var _direction:int;
		
		private var _moving:Boolean;
		
		public function MovingObject(){
			// initialization
			
			_speed = 10;
			_distance = 32;
			_distanceCount = 0;
			_direction = 1;
			
			_moving = false;		
		}
		//
		//--------------------------- GET/SET METHODS
		//
		public function get speed():int {
			return _speed;
		}
		public function set speed(value:int):void {
			_speed = value;
		}
		
		public function get direction():int {
			return _direction;
		}
		public function set direction(value:int):void {
			_direction = value;
		}
		
		public function get distance():int {
			return _distance;
		}
		public function set distance(value:int):void {
			_distance = value;
		}
		
		public function get distanceCount():int {
			return _distanceCount;
		}
		public function set distanceCount(value:int):void {
			_distanceCount = value;
		}
		
		public function get moving():Boolean {
			return _moving;
		}
		
		//
		//--------------------------- PUBLIC METHODS 
		//	
		public function startMe():void {
			moveMe();
			
		}
		
		public function stopMe():void {
			if (_moving == true) {
			_moving = false;
			}
		}
		//
		//--------------------------- EVENT HANDLERS
		//
		private function moveMe():void {
			//_moving = true;
			_moving = true;
			if (_direction == 1) {
				if (distanceCount >= distance - speed){
					this.x = this.x - speed;
					_moving = false;
					distanceCount = 0;
				}else{
					this.x = this.x - speed;
					distanceCount = distanceCount + speed;
					trace(distanceCount);
				}
				
			}else if (_direction == 2) {
				
				if (distanceCount >= distance - speed){
					this.x = this.x + speed;
					_moving = false;
					distanceCount = 0;
				}else {
					this.x = this.x + speed;
					distanceCount = distanceCount + speed;
				}
				
			}else if (_direction == 3) {
				
				if (distanceCount >= distance - speed){
					this.y = this.y - speed;
					_moving = false;
					distanceCount = 0;
				}else {
					this.y = this.y - speed;
					distanceCount = distanceCount + speed;
				}
				
			}else if (_direction == 4) {
				
				if (distanceCount >= distance - speed){
					this.y = this.y + speed;
					_moving = false;
					distanceCount = 0;
				}else {
					this.y = this.y + speed;
					distanceCount = distanceCount + speed;
				}
			}
		}
	}
}