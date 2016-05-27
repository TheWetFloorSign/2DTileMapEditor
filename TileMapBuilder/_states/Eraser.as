package  _states{
	
	public class Eraser implements IState {

		public function Eraser()
		{}
		
		public function update(map:Object):IState
		{
			if (map.targetTilePos.y >= 0 && map.targetTilePos.y < map.mapSize.h && map.targetTilePos.x >= 0 && map.targetTilePos.x < map.mapSize.w)
			{
				map.curLayer[map.targetTilePos.y][map.targetTilePos.x] = 0;
			}
			return null;
		}
		
		public function enter(map:Object):void
		{}

	}
	
}
