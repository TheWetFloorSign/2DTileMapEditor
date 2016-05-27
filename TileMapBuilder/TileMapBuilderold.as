package  {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import PlayerIncreaseNum;
	import MapTile;
	import DragSlider;
	import flash.net.FileFilter;
	import flash.text.TextField;

	[SWF(height="720",width="1080",backgroundColor="0x000000")]
	public class TileMapBuilder extends Sprite{
		
		/*[Embed(source="_raw/tilea2.png")]
		public var TileSheet:Class;*/
		
		private var tileSize:Number = 24;
		private var mapX:int = 0;
		private var mapY:int = 0;
		
		private var mapWidth:int = 20;
		private var mapHeight:int = 15;
		
		private var tarTileX:int = 0;
		private var tarTileY:int = 0;
		
		private var lastX:Number;
		private var lastY:Number;
		
		private var curX:Number;
		private var curY:Number;
		
		private var indX:int;
		private var indY:int;
		
		
		private var lastTileY:Number;		
		private var curTileY:Number;
		
		private var curLayer:int;
		
		private var layerSelector:PlayerIncreaseNum;
		private var zoomSlider:DragSlider;
		
		private var zoomText:TextField;
		
		private var wrapper:Sprite;
		private var tileWrapper:Sprite;
		
		private var translate:Boolean = false;
		private var tileScroll:Boolean = false;
		
		private var sceneBM:Bitmap; 
		private var sceneBMD:BitmapData; 
		
		private var curTileBM:Bitmap;
		private var curTileBMD:BitmapData;
		
		private var jsonTileList:Array = new Array();
		private var tileList:Array = new Array();
		private var curTileData:Object;
		
		private var tileSheet:TileSheet2 = new TileSheet2();
		private var tileSheetData:BitmapData = tileSheet.bitmapData;
		
		private var tempFR:FileReference;
		
		private var mapLayers:Array = new Array();
		
		private var menuBackground:Sprite;
		private var maskTile:Sprite;
		private var tileIndicator:Sprite;
		
		public function TileMapBuilder() {
			initialize();
		}
		
		public function startGame():void{
			createAssets();
			addAssets();
			possitionAssets();
			createEvents();
			//updateCurTile();
			popTileSet();
		}
		
		public function addKeyControl():void{
		}
		
		
		
		public function createAssets():void{
			sceneBMD = new BitmapData(mapWidth * tileSize,mapHeight * tileSize,false,0xffffff);
			sceneBM = new Bitmap(sceneBMD);
			curTileBMD = new BitmapData(tileSize * 4,tileSize * 48,false,0xffffff);
			curTileBM = new Bitmap(curTileBMD);
			
			
			layerSelector = new PlayerIncreaseNum(0,0,2,1,"Layer",2);
			layerSelector.color = 0xbbbbbb;
			zoomSlider = new DragSlider();
			zoomSlider.minVal = 0.5;
			zoomSlider.maxVal = 4;
			
			
			zoomText = new TextField();
			zoomText.text = int(zoomSlider.startVal * 100) + "%";
			
			set2DMap(mapLayers,2);
			
			set2DMap(mapLayers[0],mapWidth);
			set2DMap(mapLayers[1],mapWidth);
			set2DMap(mapLayers[2],mapWidth);
			
			wrapper = new Sprite();
			tileWrapper = new Sprite();
			
			menuBackground = new MovieClip();
			menuBackground.name = "menuBackground";
			menuBackground.graphics.lineStyle(5,0xbbbbbb);
			menuBackground.graphics.beginFill(0xeeeeee);
			menuBackground.graphics.moveTo(0,0)
			menuBackground.graphics.lineTo(150,0);
			menuBackground.graphics.lineTo(150,stage.stageHeight + 6);
			menuBackground.graphics.lineTo(0,stage.stageHeight + 6);
			menuBackground.graphics.lineTo(0,0);
			menuBackground.graphics.endFill();
			
			maskTile = new MovieClip();
			maskTile.name = "maskTile";
			maskTile.graphics.beginFill(0x00cccc,0.75);
			maskTile.graphics.moveTo(0,0)
			maskTile.graphics.lineTo(128,0);
			maskTile.graphics.lineTo(128,384);
			maskTile.graphics.lineTo(0,384);
			maskTile.graphics.lineTo(0,0);
			maskTile.graphics.endFill();
			
			tileIndicator = new MovieClip();
			
			tileIndicator.name = "tileIndicator";
			tileIndicator.graphics.lineStyle(1,0xff0000);
			tileIndicator.graphics.beginFill(0x000000,0);
			tileIndicator.graphics.moveTo(0,0)
			tileIndicator.graphics.lineTo(tileSize,0);
			tileIndicator.graphics.lineTo(tileSize,tileSize);
			tileIndicator.graphics.lineTo(0,tileSize);
			tileIndicator.graphics.lineTo(0,0);
			tileIndicator.graphics.endFill();
		}
		
		public function addAssets():void{
			wrapper.addChild(sceneBM);
			this.addChild(wrapper);
			
			this.addChild(menuBackground);
			tileWrapper.addChild(curTileBM);
			this.addChild(maskTile);
			tileWrapper.addChild(tileIndicator);
			this.addChild(tileWrapper);
			tileWrapper.mask = maskTile;
			layerSelector.showMe(this);
			zoomSlider.showMe(this);
			this.addChild(zoomText);
		}
		
		public function possitionAssets():void{
			menuBackground.x = -3;
			menuBackground.y = -3;
			
			sceneBM.x = menuBackground.width;
			sceneBM.y = stage.stageHeight/2 - sceneBM.height/2;
			
			layerSelector.x = 20;
			layerSelector.y = 20;
			zoomSlider.x = layerSelector.x;
			zoomSlider.y = layerSelector.y + layerSelector.height + 10;
			
			zoomText.x = zoomSlider.x + zoomSlider.width + 10;
			zoomText.y = zoomSlider.y;
			zoomText.width = 40;
			zoomText.height = 20;
			zoomText.selectable = false;
			
			tileWrapper.x = 10;
			tileWrapper.y = zoomSlider.y + zoomSlider.height + 20;
			
			maskTile.x = tileWrapper.x;
			maskTile.y = zoomSlider.y + zoomSlider.height + 20;
		}
		
		public function set2DMap(map:Array, length:int):void{
			for(var i:int = 0; i<=length;i++){
				map[i] = new Array();
			}
		}
		
		public function adjustZoom():void{
			var oldWidth:Number = sceneBM.width;
			var oldHeight:Number = sceneBM.height;
			
			var prevOffX:Number = stage.stageWidth/2 - sceneBM.x;
			var perOffX:Number = prevOffX/sceneBM.width;
			var prevOffY:Number = (stage.stageHeight/2) - sceneBM.y;
			var perOffY:Number = prevOffY/sceneBM.height;
			
			sceneBM.scaleX = sceneBM.scaleY = zoomSlider.curVal;
			zoomText.text = int(zoomSlider.curVal * 100) + "%";
			
			sceneBM.x -= perOffX * (sceneBM.width - oldWidth);
			sceneBM.y -= perOffY * (sceneBM.height - oldHeight);
		}
		
		public function popTileSet():void{
			var tempWidth:int = tileSheet.width / tileSize;
			var tempHeight:int = tileSheet.height / tileSize;
			var tempY:int = 0;
			for(var i:int = 0; i<tempWidth;i++){
				for(var j:int = 0; j<tempHeight;j++){
					var tileOb:Object = new Object();
					tileOb.frames = new Array();
					tileOb.frames[0] = new Object();
					tileOb.frames[0].frameSize = [tileSize,tileSize];
					tileOb.frames[0].framePosition = [0,0];
					tileList.push(tileOb);
					curTileBMD.copyPixels(tileSheet, new Rectangle(tileSize* i,tileSize* j,tileSize, tileSize),new Point(0,tempY *tileSize));
					tempY++;
					
				}
			}
		}
		
		
		public function createEvents():void{
			wrapper.addEventListener(MouseEvent.MOUSE_DOWN, onMapClickDown);
			wrapper.addEventListener(MouseEvent.MOUSE_UP, onMapClickUp);
			tileWrapper.addEventListener(MouseEvent.MOUSE_DOWN, onTileClickDown);
			tileWrapper.addEventListener(MouseEvent.MOUSE_UP, onTileClickUp);
			zoomSlider.addEventListener(DragSlider.UPDATE, onSliderUpdate);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseScroll);
			layerSelector.addEventListener(PlayerIncreaseNum.UPDATE, selUpdate);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardDown);
		}
		
		private function onSliderUpdate(e:Event):void{
			adjustZoom();
		}
		
		public function onMouseScroll(e:MouseEvent):void{
			trace(e.delta);
			zoomSlider.handleX(e.delta);
			
		}
		
		public function onKeyboardDown(e:KeyboardEvent):void{
			
			if(e.keyCode ==76){
				 loadXML();
			}
			if(e.keyCode ==83){
				 saveXML();
			}			
			if(e.keyCode ==86){
				 translate = true;
			}
			if(e.keyCode ==66){
				translate = false;
			}
			//updateCurTile();
			
		}
		
		public function onKeyboardUp(e:KeyboardEvent):void{
			
		}
		
		public function updateKeyInput():void{
			
		}
		
		public function loadXML():void{
			tempFR = new FileReference();
			tempFR.addEventListener(Event.SELECT, mapSelected)
			tempFR.browse([new FileFilter("XML Files (*.xml)","*.xml")]);
			
		}
		
		public function mapSelected(e:Event):void{
			tempFR.addEventListener(Event.COMPLETE, mapLoaded)
			tempFR.load();
		}
		
		public function mapLoaded(e:Event):void{
			/*var tempXML:XML = new XML(tempFR.data.readUTFBytes(tempFR.data.length));
			for(var i:int=0;i<tempXML.layer.length();i++){
				for(var j:int=0;j<tempXML.layer[i].width.length();j++){
					for(var k:int=0;k<tempXML.layer[i].width[j].tile.length();k++){
						var tempTile = new MapTile();
						tempTile.mapName = tempXML.layer[i].width[j].tile[k].@tileSet;
						tempTile.mapX = tempXML.layer[i].width[j].tile[k].@setX;
						tempTile.mapY = tempXML.layer[i].width[j].tile[k].@setY;
						mapLayers[i][j][k] = tempTile;
					}
				}
			}
			
			updateFullMap();*/
			var testOb:Object = JSON.parse(tempFR.data.readUTFBytes(tempFR.data.length));
			trace(testOb.layers[0][0]);
		}
		
		public function updateFullMap():void{
			for(var i:int=0;i<mapLayers.length;i++){
				for(var j:int=0;j<mapLayers[i].length;j++){
					for(var k:int=0;k<mapWidth;k++){
						if(mapLayers[i][j][k] != undefined){
							if(i != curLayer){
								sceneBMD.copyPixels(tileSheet, new Rectangle(tileSize * mapLayers[i][j][k].mapX,tileSize * mapLayers[i][j][k].mapY,tileSize,tileSize),new Point(j * tileSize,k * tileSize),new BitmapData(300, 300, true, 0x59FFFFFF),null,true);
							}else{
								sceneBMD.copyPixels(tileSheet, new Rectangle(tileSize * mapLayers[i][j][k].mapX,tileSize * mapLayers[i][j][k].mapY,tileSize,tileSize),new Point(j * tileSize,k * tileSize));
							}
							
						}
					}
				}
			}
		}
		
		public function saveXML():void{
			var xml:XML = <xml></xml>;
							
			var level:Object = new Object();
			level.background = new Array();
			for(var i:int=0;i<mapLayers.length;i++){
				xml.appendChild(<layer></layer>);
				for(var j:int=0;j<mapLayers[i].length;j++){
					xml.layer[i].appendChild(<width></width>);
					level.background[j] = new Array();
					for(var k:int=0;k<mapWidth;k++){
						level.background[j][k] = 1;
						if(mapLayers[i][j][k] != undefined){
							
							xml.layer[i].width[j].appendChild(<tile></tile>);
							xml.layer[i].width[j].tile[k].@tileSet = mapLayers[i][j][k].mapName;
							xml.layer[i].width[j].tile[k].@setX = mapLayers[i][j][k].mapX;
							xml.layer[i].width[j].tile[k].@setY = mapLayers[i][j][k].mapY;
						}else{
							xml.layer[i].width[j].appendChild(<tile tileSet="test" setX="0" setY="0"></tile>);
						}						
					}
				}
			}
			var t1:Object = new Object();
			t1.test = 1;
			
			var t2:Object = new Object();
			t2.test = 3;
			
			var t3:Object = new Object();
			t3.test = 2;
			
			var same:Boolean = false;
			var tileList:Array = new Array();
			tileList =[t1,t2];
			var newT:Object = t3;
			for each(var tar in tileList){
				for(var foo in tar)if(tar[foo] == newT[foo])same = true;
			}
			trace(same);
			
			level["tile"+1] = new Object();
			level["tile"+1].id = 1;
			/*var frame:Number =1;
			while(frame <2){
				tile["frame"+frame].sheet = "";
				tile["frame"+frame].sheetx = 0;
				tile["frame"+frame].sheety = 0;
				tile["frame"+frame].width = 24;
				tile["frame"+frame].height = 24;
				frame++;
			}*/
			level["tile"+1].solid = false;
			level["tile"+1].damage = 3;
			/*var hitbox:Number = 1;
			while(hitbox <2){
					tile["hitbox"+hitbox].width = 24;
					tile["hitbox"+hitbox].height = 24;
					tile["hitbox"+hitbox].xoff = 12;
					tile["hitbox"+hitbox].yoff = 12;
					hitbox++;
				
			}*/
			var tileStr:String = JSON.stringify(level,null,4);
			var tileCop:Object = JSON.parse(tileStr);
			for(var a:int=1; a<5;a++){
				if(tileCop["tile"+a].id == a){
					break;
				}
			}
			
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(tileStr);
			
			var fr:FileReference = new FileReference();
			fr.save(ba, "test.xml");
			
		}
		
		public function selUpdate(e:Event):void{
			if(e.target.id == 0){
				mapX = e.target.currentValue;
				//updateCurTile();
			}else if(e.target.id == 1){
				mapY = e.target.currentValue;
				//updateCurTile();
			}else if(e.target.id == 2){
				curLayer = e.target.currentValue;
				updateFullMap();
			}
			
		}
		
		public function updateCurTile():void{
			curTileBMD.copyPixels(new BitmapData(tileSize,tileSize,false,0xffffff), new Rectangle(0,0,tileSize,tileSize),new Point(0,0));
			curTileBMD.copyPixels(tileSheet, new Rectangle(tileSize* mapX,tileSize* mapY,tileSize,tileSize),new Point(0,0));
			
		}
		
		public function pushTile():void{
			
		}
		
		public function onMapClickDown(e:MouseEvent):void{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMapMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMapClickUp);
			
			if(!translate){
				tarTileX = Math.floor(sceneBM.mouseX / tileSize);
				tarTileY = Math.floor(sceneBM.mouseY / tileSize);
				applyTile();
			}else{
				curX = mouseX;
				curY = mouseY;
			}
			
		}
		
		public function onMapClickUp(e:MouseEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMapMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMapClickUp);
		}
		
		public function onMapMove(e:MouseEvent):void{
			if(!translate){
				tarTileX = Math.floor(sceneBM.mouseX / tileSize);
				tarTileY = Math.floor(sceneBM.mouseY / tileSize);
				applyTile();
			}else{
				lastX = curX;
				lastY = curY;
				curX = mouseX;
				curY = mouseY;
				
				sceneBM.x += curX - lastX;
				sceneBM.y += curY - lastY;
			}
			
		}
		
		public function onTileClickDown(e:MouseEvent):void{
			curTileY = mouseY;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onTileMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onTileClickUp);
		}
		
		public function onTileClickUp(e:MouseEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onTileMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onTileClickUp);
			
			if(!tileScroll){
				var i:int = int((curTileBM.mouseY/(3 * tileSize))/4);
				var j:int = i * 4 + int(curTileBM.mouseX / tileSize);
				var k:int = int(curTileBM.mouseY/tileSize) - (int(curTileBM.mouseY/(12 * tileSize)) * 12);
				mapX = j;
				mapY = k;
				tileIndicator.x = int(curTileBM.mouseX/tileSize) * tileSize;
				indX = curTileBM.mouseX/tileSize;
				tileIndicator.y = curTileBM.y + int(curTileBM.mouseY/tileSize) * tileSize;
				indY = curTileBM.mouseY/tileSize;
			}
			tileScroll = false;
			curTileData = new Object();
			curTileData.frames = new Array();
			curTileData.frames[0] = new Object();
			curTileData.frames[0].frameSize = [tileSize,tileSize];
			curTileData.frames[0].framePosition = [0,0];
		}
		
		public function onTileMove(e:MouseEvent):void{
			
			lastTileY = curTileY;
			curTileY = mouseY;
			
			if(curTileBM.y + curTileY - lastTileY < -(curTileBM.height - 386)){
			   	curTileBM.y = -(curTileBM.height - 386);
				tileIndicator.y = curTileBM.y + (indY * tileSize);
			}else if(curTileBM.y + curTileY - lastTileY > 0){
				curTileBM.y = 0;
				tileIndicator.y = curTileBM.y + (indY * tileSize);
			}else{
				curTileBM.y += curTileY - lastTileY;
				tileIndicator.y += curTileY - lastTileY;
			}
			tileScroll = true;			
			
		}
		
		public function applyTile():void{
			if(tarTileX <0) tarTileX = 0;
			if(tarTileY <0) tarTileY = 0;
			
			trace(tarTileX + " and " + tarTileY);
			
			if(tarTileX >= mapWidth) tarTileX = mapWidth -1;
			if(tarTileY >= mapHeight) tarTileY = mapHeight -1;
			var tempTile = new MapTile();
			tempTile.mapName = "test";
			tempTile.mapX = mapX;
			tempTile.mapY = mapY;
			mapLayers[curLayer][tarTileX][tarTileY] = tempTile;
			
			sceneBMD.copyPixels(new BitmapData(tileSize,tileSize,false,0xffffff), new Rectangle(0,0,tileSize,tileSize),new Point(tarTileX * tileSize,tarTileY * tileSize));
			
			for(var i:int = 0; i< mapLayers.length; i++){
				if(mapLayers[i][tarTileX][tarTileY] != undefined){
					sceneBMD.copyPixels(tileSheet, new Rectangle(tileSize * mapLayers[i][tarTileX][tarTileY].mapX,tileSize * mapLayers[i][tarTileX][tarTileY].mapY,tileSize,tileSize),new Point(tarTileX * tileSize,tarTileY * tileSize));
				}
			}
			
			
		}
		
		private function initialize():void{
			startGame();
		}

	}
	
}
