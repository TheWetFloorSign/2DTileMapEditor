package  _states{
	
	public class Translate implements IState {

		public function Translate()
		{}
		
		public function update(map:Object):IState
		{
			map.sceneBM.x += map.curMousePos.x - map.lastMousePos.x;
			map.sceneBM.y += map.curMousePos.y - map.lastMousePos.y;
			return null;
		}
		
		public function enter(map:Object):void
		{}

	}
	
}
