package  _states{
	
	public class Eraser implements IState {
		
		private var dirx:int;
		private var diry:int;
		private var deltax:int;
		private var deltay:int;
		private var slope:Number;
		private var intercept:Number;
		private var y:int;
		private var x:int;
		private var error:Number;
		private var error2:Number;
		
		public function Eraser()
		{}
		
		public function update(map:Object):IState
		{
			if (withinBounds(map.targetTilePos.x,map.targetTilePos.y,map.mapSize.h,map.mapSize.w))
			{
				
				dirx = (map.targetTilePos.x > map.targetTilePos.lastX)?1: -1;
				diry = (map.targetTilePos.y > map.targetTilePos.lastY)?1: -1;
				deltay = Math.abs(map.targetTilePos.y - map.targetTilePos.lastY);
				deltax = Math.abs(map.targetTilePos.x - map.targetTilePos.lastX);
				
				error = (deltax > deltay ? deltax:-deltay) / 2;
				
				y = map.targetTilePos.lastY;
				x = map.targetTilePos.lastX;
				
				while (true)
				{
					if(withinBounds(x,y,map.mapSize.h,map.mapSize.w))map.curLayer[y][x] = 0;
					if (x == map.targetTilePos.x && y == map.targetTilePos.y) break;
					error2 = error;
					if (error2 > -deltax)
					{
						error -= deltay;
						x += dirx;
					}
					if (error2 < deltay)
					{
						error += deltax;
						y += diry;
					}
				}				
			}
			return null;
		}
		
		public function enter(map:Object):void
		{}
		
		private function withinBounds(x:int,y:int,height:int,width:int):Boolean
		{
			if (y >= 0 && y < height && x >= 0 && x < width)
			{
				return true;
			}
			return false;
		}

	}
	
}
