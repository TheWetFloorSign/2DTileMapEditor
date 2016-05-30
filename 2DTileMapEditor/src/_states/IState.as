package  _states{
	
	public interface IState {

		function update(map:Object):IState;
		
		function enter(map:Object):void;

	}
	
}
