package  _states{
	
	public class Brush implements IState {

		public function Brush()
		{}
		
		public function update(map:Object):IState
		{
			if (map.targetTilePos.y >= 0 && map.targetTilePos.y < map.mapSize.h && map.targetTilePos.x >= 0 && map.targetTilePos.x < map.mapSize.w)
			{
				if (map.curLayer[map.targetTilePos.y][map.targetTilePos.x] != map.pushTile(map.curTileData))
				{
					map.curLayer[map.targetTilePos.y][map.targetTilePos.x] = map.pushTile(map.curTileData);
					map.updateFullMap();
				}
				
			}
			return null;
		}
		
		public function enter(map:Object):void
		{}

	}
	
}
