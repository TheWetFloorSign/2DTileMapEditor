package  {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import _states.IState;
	
	import PlayerIncreaseNum;
	import MapTile;
	import DragSlider;
	import flash.net.FileFilter;
	import flash.text.TextField;
	import _states.*;

	[SWF(height="720",width="1080",backgroundColor="0x444444")]
	public class Main extends Sprite{
		
		/*[Embed(source="_raw/tilea2.png")]
		public var TileSheet:Class;*/
		
		public var tileSize:Number = 24;
		public var mapPos:Object = {x:0,y:0};
		
		public var mapSize:Object = {w:20,h:20};
		
		public var targetTilePos:Object = {x:0,y:0};
		
		public var lastMousePos:Object = {x:0,y:0};
		
		public var curMousePos:Object = {x:0, y:0};
		
		public var workArea:Object = {x:140, y:0, w:stage.stageWidth - 140, h:stage.stageHeight};
		
		private var gridLines:Boolean = true;
		private var tileScroll:Boolean = false;
		
		public var curLayer:Array;
		
		private var layerSelector:PlayerIncreaseNum;
		private var zoomSlider:DragSlider;
		
		private var zoomText:TextField;
		
		private var wrapper:Sprite;
		private var tileWrapper:Sprite;
		private var tile2Wrapper:Sprite;
		
		private var toolState:IState = new Brush();
		private var lastState:IState;
		
		public var sceneBM:Bitmap; 
		private var sceneBMD:BitmapData; 
		
		private var curTileBM:Bitmap;
		private var curTileBMD:BitmapData;
		
		private var gridBM:Bitmap;
		private var gridBMD:BitmapData;
		
		private var inputs:Array = [];
		
		private var jsonTileList:Array = new Array();
		private var tileList:Array = new Array();
		private var defTileList:Array = new Array();
		public var curTileData:Object;
		
		private var tileSheet:TileSheet2 = new TileSheet2();
		private var tileSheetData:BitmapData = tileSheet.bitmapData;
		
		private var tempFR:FileReference;
		
		private var tileVars:Array = new Array();
		
		private var mapLayers:Array = new Array();
		
		private var menuBackground:Sprite;
		private var maskTile:Sprite;
		private var tileIndicator:Sprite;
		
		private var updateTile:MC_Button;
		private var saveTile:MC_Button;
		private var addInput:MC_Button;
		
		private var toolBrush:MC_Button;
		private var toolScroll:MC_Button;
		private var toolEraser:MC_Button;
		
		private var defTileWindow:ScrollWindow;
		private var usedTileWindow:ScrollWindow;
		
		public function Main() {
			if (stage) initialize();
			else addEventListener(Event.ADDED_TO_STAGE, initialize);
		}
		
		public function startGame():void{
			createAssets();
			addAssets();
			possitionAssets();
			createEvents();
			buttonUpdate();
			loadMap();
		}
		
		public function addKeyControl():void{
		}
		
		private function loadMap(map:Object = null):void
		{
			if (!map)
			{
				map = {layers:[],tiles:[],settings:{}};
				map.layers[0] = {name:"collision", id:0, map:[]};
				map.settings = {mapSize:{w:20, h:20}, tileSize:24};
				set2DMap(map.layers[0].map, map.settings.mapSize.w);
				optimize2d(map.layers[0].map, map.settings.mapSize.w, map.settings.mapSize.h);
			}
			
			mapLayers = map.layers;
			mapSize.h = map.settings.mapSize.h;
			mapSize.w = map.settings.mapSize.w;
			tileSize = map.settings.tileSize;
			sceneBMD = new BitmapData(mapSize.h * tileSize, mapSize.w * tileSize, false, 0xffffff);
			sceneBM.bitmapData = sceneBMD;
			sceneBM.y = (stage.stageHeight / 2 - sceneBM.height / 2 <0)?0 +tileSize:stage.stageHeight / 2 - sceneBM.height / 2;
			sceneBM.x = (((stage.stageWidth -menuBackground.width)/2)-(sceneBM.width/2)<0)?menuBackground.width + tileSize:((stage.stageWidth -menuBackground.width)/2)-(sceneBM.width/2) + menuBackground.width;	
			jsonTileList = map.tiles;
			curLayer = mapLayers[0].map;
			resizeGrid();
			popTileSet();
			updateFullMap();
			updateCurTile();
		}
		
		private function resizeGrid():void
		{
			gridBMD = new BitmapData(mapSize.w*tileSize,mapSize.h * tileSize,true,0x00000000)
			for(var f:int = mapSize.h - 1; f>0; f--){
				for(var g:int = mapSize.w - 1; g>0; g--){
					gridBMD.copyPixels(new BitmapData(mapSize.w*tileSize,1,false,0x666666),new Rectangle(0,0,mapSize.w*tileSize,1),new Point(0,f*tileSize),null,null,true);
					gridBMD.copyPixels(new BitmapData(1,mapSize.h*tileSize,false,0x666666),new Rectangle(0,0,1,mapSize.h*tileSize),new Point(g*tileSize,0),null,null,true);
				}
			}
		}
		
		public function createAssets():void{
			sceneBM = new Bitmap(new BitmapData(10,10,false,0xffffff));
			curTileBMD = new BitmapData(tileSize,(tileSheet.width * tileSheet.height)/tileSize,false,0xffffff);
			curTileBM = new Bitmap(curTileBMD);
			curTileBM.scaleX = curTileBM.scaleY = 2;
						
			layerSelector = new PlayerIncreaseNum(0,0,2,1,"Layer",2);
			layerSelector.color = 0xbbbbbb;
			zoomSlider = new DragSlider();
			zoomSlider.minVal = 0.5;
			zoomSlider.maxVal = 4;
			
			defTileWindow = new ScrollWindow();
			usedTileWindow = new ScrollWindow();
			
			zoomText = new TextField();
			zoomText.text = int(zoomSlider.startVal * 100) + "%";
			
			saveTile = new MC_Button();
			saveTile.labelTxt = "Save";
			updateTile = new MC_Button();
			updateTile.labelTxt = "Update";
			addInput = new MC_Button();
			addInput.labelTxt = "+";
			
			toolBrush = new MC_Button();
			toolBrush.name = "toolBrush";
			toolScroll = new MC_Button();
			toolScroll.name = "toolScroll";
			toolEraser = new MC_Button();
			toolEraser.name = "toolEraser";
			
			toolBrush.labelTxt = "Brush";
			toolScroll.labelTxt = "Scroll";
			toolEraser.labelTxt = "Eraser";
			
			toolScroll.toggle = toolBrush.toggle = toolEraser.toggle = true;
			toolScroll.showText = toolBrush.showText = toolEraser.showText = true;
			
			wrapper = new Sprite();
			tileWrapper = new Sprite();
			tile2Wrapper = new Sprite();
			
			menuBackground = new MovieClip();
			menuBackground.name = "menuBackground";
			
						
			
			tileIndicator = new MovieClip();
			
			tileIndicator.name = "tileIndicator";
			drawMenuObjects();
		}
		
		private function drawMenuObjects():void
		{
			menuBackground.graphics.clear();
			menuBackground.graphics.lineStyle(2,0x646464);
			menuBackground.graphics.beginFill(0xd6d6d6);
			menuBackground.graphics.drawRect(0,0,200,stage.stageHeight + 6);
			menuBackground.graphics.endFill();
			
			tileIndicator.graphics.clear();
			tileIndicator.graphics.lineStyle(1,0xff0000);
			tileIndicator.graphics.beginFill(0x000000,0);
			tileIndicator.graphics.drawRect(0,0,tileSize*curTileBM.scaleX,tileSize*curTileBM.scaleX);
			tileIndicator.graphics.endFill();
		}
		
		public function addAssets():void{
			wrapper.addChild(sceneBM);
			this.addChild(wrapper);
			tileWrapper.addChild(curTileBM);
			this.addChild(menuBackground);
			layerSelector.showMe(this);
			zoomSlider.showMe(this);
			this.addChild(zoomText);
			defTileWindow.showMe(stage);
			defTileWindow.contentMC = tileWrapper;
			defTileWindow.maskHeight = 4 * curTileBM.scaleX * tileSize;
			
			
			usedTileWindow.showMe(stage);
			usedTileWindow.contentMC = tile2Wrapper;
			usedTileWindow.maskHeight = 4 * curTileBM.scaleX * tileSize;
			
			this.addChild(toolBrush);
			this.addChild(toolScroll);
			this.addChild(toolEraser);
			
		}
		
		public function possitionAssets():void{
			menuBackground.x = -3;
			menuBackground.y = -3;
			
					
			
			zoomSlider.x = layerSelector.x;
			zoomSlider.y = layerSelector.y + layerSelector.height + 10;
			
			zoomText.x = zoomSlider.x + zoomSlider.width + 10;
			zoomText.y = zoomSlider.y;
			zoomText.width = 40;
			zoomText.height = 20;
			zoomText.selectable = false;			
			
			defTileWindow.y = 80;
			defTileWindow.x = 10;
			usedTileWindow.y = 80;
			usedTileWindow.x = 70;
			
			toolBrush.x = toolScroll.x = toolEraser.x = stage.stageWidth - 80;
			toolScroll.y = 40;
			toolBrush.y = toolScroll.y + 30;
			toolEraser.y = toolBrush.y + 30;
		}
		
		
		public function addTileInput():void{
			var input:PairedInput = new PairedInput();
			input.y = 300 + (tileVars.length * 24);
			input.x = 10;;
			this.addChild(input);
			
			var btn:MC_Button = new MC_Button();
			btn.name = "btn";
			btn.onButton = false;
			btn.showText = false;
			input.addChild(btn);
			btn.id = tileVars.length;
			btn.x = 150;
			btn.addEventListener(MouseEvent.MOUSE_UP, delTileInput);
			tileVars.push(input);
			
			this.addChild(saveTile);
			this.addChild(updateTile);
			saveTile.x = 10;
			updateTile.x = 80;
			saveTile.y = updateTile.y = tileVars[tileVars.length-1].y + 60;
			
			addInput.x = 10;
			addInput.y = 300 + (tileVars.length* 24);
		}
		
		public function adjustZoom():void{
			var oldWidth:Number = sceneBM.width;
			var oldHeight:Number = sceneBM.height;
			
			var prevOffX:Number = stage.stageWidth/2 - sceneBM.x;
			var percentOffX:Number = prevOffX/sceneBM.width;
			var prevOffY:Number = (stage.stageHeight/2) - sceneBM.y;
			var percentOffY:Number = prevOffY/sceneBM.height;
			
			sceneBM.scaleX = sceneBM.scaleY = zoomSlider.curVal;
			zoomText.text = int(zoomSlider.curVal * 100) + "%";
			
			sceneBM.x -= Math.floor(percentOffX * (sceneBM.width - oldWidth));
			sceneBM.y -= Math.floor(percentOffY * (sceneBM.height - oldHeight));
		}
		
		public function createEvents():void{
			wrapper.addEventListener(MouseEvent.MOUSE_DOWN, onCanvasClick);
			wrapper.addEventListener(MouseEvent.MOUSE_UP, onCanvasRelease);
			zoomSlider.addEventListener(DragSlider.UPDATE, onSliderUpdate);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseScroll);
			stage.addEventListener(Event.RESIZE, onStageResize);
			//layerSelector.addEventListener(PlayerIncreaseNum.UPDATE, selUpdate);
			updateTile.addEventListener(MouseEvent.CLICK, updateTileFromInputs);
			saveTile.addEventListener(MouseEvent.CLICK, saveTileFromInputs);
			addInput.addEventListener(MouseEvent.CLICK, onAddInput);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyboardUp);
			toolScroll.addEventListener(MC_Button.RELEASE, onMouseClick);
			toolBrush.addEventListener(MC_Button.RELEASE, onMouseClick);
			toolEraser.addEventListener(MC_Button.RELEASE, onMouseClick);
		}
		
		private function onStageResize(e:Event):void 
		{
			drawMenuObjects();
			possitionAssets();
			trace(menuBackground.x);
		}
		
		public function delTileInput(e:MouseEvent):void{
			this.removeChild(tileVars[e.currentTarget.id]);
			tileVars.splice(e.currentTarget.id,1);
			updateInputID();
		}
		
		public function flipGrid():void{
			gridLines = !gridLines;
			updateFullMap();
		}
		
		public function inputsNotBlank():Boolean{
			var bTemp:Boolean = true;
			for each(var field in tileVars){
				if (!(field is MC_Button))
				{
					if(field.fieldName == "" || field.currentValue == ""){
						trace("Cant Save: field or value empty");
						bTemp = false;
						break;
					}
				}
				
			}
			return bTemp;
		}
		
		
		
		
		
		//========================= LOAD/SAVE STUFF ==============================//
		
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
			loadMap(testOb);
		}
		
		public function loadXML():void{
			trace("loadXML");
			tempFR = new FileReference();
			tempFR.addEventListener(Event.SELECT, mapSelected);
			tempFR.browse([new FileFilter("TXT Files (*.txt)","*.txt")]);
			
		}
		
		public function mapSelected(e:Event):void{
			tempFR.addEventListener(Event.COMPLETE, mapLoaded)
			tempFR.load();
		}
		
		public function saveXML():void{							
			var level:Object = {};
			for each(var layer in mapLayers)
			{
				optimize2d(layer.map,mapSize.w,mapSize.h);
			}
			
			level.layers = mapLayers;
			level.tiles = jsonTileList;
			level.settings = {mapSize:{w:mapSize.w, h:mapSize.h}, tileSize:24};
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(JSON.stringify(level,null,4));
			
			var fr:FileReference = new FileReference();
			fr.save(ba, "Untitled.txt");
		}
		
		//========================= END LOAD/SAVE STUFF ==============================//
		
		
		
		public function optimize2d(tArray:Array, width:int, height:int):Array{
			for(var y:int = 0;y<height;y++){
				for(var x:int = 0;x<width;x++){
					if(tArray[y][x] == null) tArray[y][x] = 0;
				}
			}
			return tArray;
		}
		
		public function populateTileInputs(tOb:Object):void{
			for each(var inp in tileVars){
				inp.parent.removeChild(inp);
			}
			trace("populateTileInputs " + ((tOb.tempID != undefined)?tOb.tempID:tOb.id));
			tileVars = [];
			
			for(var field:String in tOb){
				if (field != "frames" && field != "hitbox" && field != "tempID"){
					if (tOb[field] is Boolean)
					{
						var togBtn:MC_Button = new MC_Button();
						togBtn.toggle = true;
						togBtn.name = "btn";
						togBtn.labelTxt = field;
						togBtn.onButton = false;
						togBtn.x = 10;
						togBtn.y = 300 + (tileVars.length * 24);
						var btn:MC_Button = new MC_Button();
						btn.name = "btn";
						btn.showText = false;
						btn.onButton = false;
						togBtn.addChild(btn);
						btn.id = tileVars.length;
						btn.x = 150;
						btn.addEventListener(MouseEvent.MOUSE_UP, delTileInput);
						this.addChild(togBtn);
						tileVars.push(togBtn);
					}
					trace(tOb[field] is int);
					if (tOb[field] is int || tOb[field] is Number || tOb[field] is String)
					{
						var input:PairedInput = new PairedInput();
						input.fieldName = field;
						input.currentValue = tOb[field];
						input.y = 300 + (tileVars.length * 24);
						input.x = 10;
						var btn:MC_Button = new MC_Button();
						btn.name = "btn";
						input.addChild(btn);
						btn.id = tileVars.length;
						btn.showText = false;
						btn.onButton = false;
						btn.x = 150;
						btn.addEventListener(MouseEvent.MOUSE_UP, delTileInput);
						this.addChild(input);
						tileVars.push(input);
					}
					
				}
			}
			this.addChild(addInput);
			addInput.x = 10;
			addInput.y = 300 + (tileVars.length* 24);
			if(tileVars.length >0){
				this.addChild(saveTile);
				this.addChild(updateTile);
				saveTile.x = 10;
				updateTile.x = 80;
				saveTile.y = updateTile.y = tileVars[tileVars.length-1].y + 60;
			}else{
				if(this.contains(saveTile))this.removeChild(saveTile);
				if(this.contains(updateTile))this.removeChild(updateTile);
			}
		}
		
		public function popTileSet():void{
			popDefTileSet();
			popUsedTileSet();
			curTileData = defTileList[0];
			populateTileInputs(curTileData);
		}
		
		public function popDefTileSet():void
		{
			var tempWidth:int = tileSheet.width / tileSize;
			var tempHeight:int = tileSheet.height / tileSize;
			var tempY:int = 0;
			var scale:int =2;
			for (var i:int = 0; i < tempHeight; i++)
			{
				for (var j:int = 0; j < tempWidth; j++)
				{
					var tileDisplay:Sprite;
					var tileOb:Object = {};
					tileOb.frames = [];
					tileOb.frames[0] = {frameSize:[tileSize,tileSize], framePosition:[j * tileSize,i * tileSize], flip: true};
					tileOb.hitbox = [];
					tileOb.hitbox[0] = {boxPosition:[0, 0], boxSize:[tileSize, tileSize]};
					tileOb.tempID = tempY;
					tileOb.flip = true;
					
					defTileList.push(tileOb);
					var tileBMD:BitmapData = new BitmapData(tileSize,tileSize);
					tileBMD = createBitmapData(tileSheet, tileSize* j,tileSize* i,tileSize, tileSize, true);
					tileDisplay = new Sprite();
					tileDisplay.name = String(tempY);
					var tileBM:Bitmap = new Bitmap(tileBMD);
					tileDisplay.addChild(tileBM);
					
					tileWrapper.addChild(tileDisplay);
					tileDisplay.y = tempY * tileSize * scale;
					tileDisplay.scaleX = tileDisplay.scaleY = scale;
										
					tileDisplay.addEventListener(MouseEvent.MOUSE_UP, onTileLibRelease);
					
					tempY++;
				}
			}
			defTileWindow.redrawWindow();
		}
		
		public function popUsedTileSet():void{
			var tempY:int = 0;
			var scale:int =2;
			for(var i:int = 0; i<jsonTileList.length;i++){
				var tileDisplay:Sprite;
				var tileBMD:BitmapData = new BitmapData(jsonTileList[i].frames[0].frameSize[0],jsonTileList[i].frames[0].frameSize[1]);
				tileBMD.copyPixels(tileSheet, new Rectangle(jsonTileList[i].frames[0].framePosition[0],jsonTileList[i].frames[0].framePosition[1],jsonTileList[i].frames[0].frameSize[0], jsonTileList[i].frames[0].frameSize[1]),new Point(0,0));
				tileDisplay = new Sprite();
				tileDisplay.name = String(tempY);
				var tileBM:Bitmap = new Bitmap(tileBMD);
				tileDisplay.addChild(tileBM);
				
				tile2Wrapper.addChild(tileDisplay);
				tileDisplay.y = tempY * tileSize * scale;
				tileDisplay.scaleX = tileDisplay.scaleY = scale;
				
				
				tileDisplay.addEventListener(MouseEvent.MOUSE_UP, onUsedTileLibRelease);
				
				tempY++;
			}
			usedTileWindow.redrawWindow();
		}
		
		public function pushTile(tOb:Object):int{
			var id:int = 0;
			for each(var tar in jsonTileList){
				var bSame:Boolean = true;
				for(var foo in tar){
					if(tar[foo] != tOb[foo] && foo != "id" && foo != "tempID"){
						bSame = false;
						break;
					}
				}
				for(var bar in tOb){
					if(tOb[bar] != tar[bar] && bar != "id" && bar != "tempID"){
						bSame = false;
						break;
					}
				}
				if(bSame){
					id = tar.id;
					break;
				}
			}
			if(id == 0){
				id = jsonTileList.length + 1;
				var tTile:Object = {};
				for(var field in tOb){
					tTile[field] = tOb[field];
				}
				tTile.id = id;
				
				if (tTile.hasOwnProperty("tempID"))
				{
					delete tTile.tempID;
				}
				jsonTileList.push(tTile);
				curTileData = tTile;
				popUsedTileSet();
			}
			//trace("in pushtile");
			return id;
		}
		
		
		
		// starting from element 0, creates new arrays in the given array for the length provided
		public function set2DMap(map:Array, length:int):void{
			for(var i:int = 0; i<length;i++){
				map[i] = [];
			}
		}
		
		public function updateInputID():void{
			for(var i:int = 0;i<tileVars.length;i++){
				for(var j:int =0;j< tileVars[i].numChildren; j++){
					if(tileVars[i].getChildAt(j).name == "btn")tileVars[i].getChildAt(j).id = i;
				}
				tileVars[i].y = 300 + (i * 24);
			} 
			addInput.x = 10;
			addInput.y = 300 + (tileVars.length* 24);
			if(tileVars.length >0){
				this.addChild(saveTile);
				this.addChild(updateTile);
				saveTile.x = 10;
				updateTile.x = 80;
				saveTile.y = updateTile.y = tileVars[tileVars.length-1].y + 60;
			}else{
				this.removeChild(saveTile);
				this.removeChild(updateTile);
			}
		}
		
		public function updateKeyInput():void{
		}
		
		public function tileByID(id:int):Object{
			var tOb:Object = new Object();
			if(id == 0){
				
			}
			for each(var tar in jsonTileList){
				if(tar.id == id){
					tOb = tar;
					break;
				}
			}
			return tOb;
		}
		
		public function updateFullMap():void
		{
			sceneBMD.lock();
			trace(sceneBMD.height)
			sceneBMD.copyPixels(new BitmapData(sceneBMD.width,sceneBMD.height,false,0xFFFFFF),sceneBMD.rect,new Point(0,0),null,null,true);
			var tempTile:Object;
			for (var lay in mapLayers)
			{
				trace(mapLayers[lay].map.length);
				for (var k:int = 0; k < mapSize.w; k++)
				{
					
					for (var j:int = 0; j < mapLayers[lay].map.length; j++)
					{
						if (mapLayers[lay].map[j][k] != undefined)
						{
							if (mapLayers[lay].map[j][k] == 0)
							{
								sceneBMD.copyPixels(new BitmapData(tileSize,tileSize,true,0x00000000),new Rectangle(0,0,tileSize,tileSize),new Point(k * tileSize,j * tileSize));
							}else if (lay != curLayer)
							{
								tempTile = tileByID(mapLayers[lay].map[j][k]);
								//sceneBMD.copyPixels(tileSheet, new Rectangle(tempTile.frames[0].framePosition[0],tempTile.frames[0].framePosition[1],tileSize,tileSize),new Point(k * tileSize,j * tileSize),new BitmapData(tileSize, tileSize, true, 0x59FFFFFF),null,true);
								sceneBMD.copyPixels(createBitmapData(tileSheet, tempTile.frames[0].framePosition[0], tempTile.frames[0].framePosition[1], tileSize, tileSize,tempTile.frames[0].flip), new Rectangle(0,0,tileSize,tileSize), new Point(k * tileSize, j * tileSize));
							}else
							{
								if (mapLayers[lay].map[j][k] == 0)
								{
									sceneBMD.copyPixels(new BitmapData(tileSize,tileSize,true,0x00000000),new Rectangle(0,0,tileSize,tileSize),new Point(k * tileSize,j * tileSize));
								}else
								{
									tempTile = tileByID(mapLayers[lay].map[j][k]);
									sceneBMD.copyPixels(tileSheet, new Rectangle(tempTile.frames[0].framePosition[0],tempTile.frames[0].framePosition[1],tileSize,tileSize),new Point(k * tileSize,j * tileSize));
								}								
							}							
						}
					}
				}
			}	
			if (gridLines)
			{
				sceneBMD.copyPixels(gridBMD,gridBMD.rect,new Point(0,0),null,null,true);
			}
			sceneBMD.unlock();
		}
		
		public function updateCurTile():void{
			curTileBMD.copyPixels(new BitmapData(tileSize,tileSize,false,0xffffff), new Rectangle(0,0,tileSize,tileSize),new Point(0,0));
			curTileBMD.copyPixels(tileSheet, new Rectangle(curTileData.frames[0].framePosition[0],curTileData.frames[0].framePosition[1],tileSize,tileSize),new Point(0,0));
		}
		
		public function updateTool():void{
			updatePositions();	
			toolState.update(this);	
			updateFullMap();
		}
		
		
		
		
		public function onAddInput(e:MouseEvent):void{
			if (tileVars.length == 0 || !tileVars[tileVars.length -1].hasOwnProperty("fieldName") || tileVars[tileVars.length -1].fieldName != "")
			{
				addTileInput();
			}
			
		}
		
		public function onCanvasClick(e:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveCanvas);
			stage.addEventListener(MouseEvent.MOUSE_UP, onCanvasRelease);
			updatePositions();
			updateTool();
		}
		
		public function onCanvasRelease(e:MouseEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveCanvas);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onCanvasRelease);
		}
		
		public function onKeyboardDown(e:KeyboardEvent):void{
			if (inputs[e.keyCode] == undefined || inputs[e.keyCode] == false)
			{
				inputs[e.keyCode] = true;
				switch(e.keyCode)
				{
					case 32:
						lastState = toolState;
						toolState = new Translate();
						inputs[32] = true;						
						break;
					case 66:
						toolState = new Brush();
						break;
					case 69:
						toolState = new Eraser();
						break;
					case 71:
						flipGrid();
						break;
					case 76:
						if (e.ctrlKey)
						{
							loadXML();
						}
						break;
					case 83:
						if (e.ctrlKey)
						{
							saveXML();
						}
						break;
				}
				buttonUpdate();
			}
			
		}
		
		public function onKeyboardUp(e:KeyboardEvent):void{
			inputs[e.keyCode] = false;
			switch(e.keyCode)
			{
				case 32:
					toolState = lastState;
					break;
			}
			buttonUpdate();
		}
		
		public function onMouseMoveCanvas(e:MouseEvent):void
		{
			updateTool();
		}
		private function updatePositions():void
		{
			targetTilePos.x = Math.floor(sceneBM.mouseX / tileSize);
			targetTilePos.y = Math.floor(sceneBM.mouseY / tileSize);
			
			lastMousePos.x = curMousePos.x;
			lastMousePos.y = curMousePos.y;
			curMousePos.x = mouseX;
			curMousePos.y = mouseY;
		}
		
		public function onMouseClick(e:Event):void{
			trace(e.target.name);
			switch(e.target.name)
			{
				case "toolScroll":
					toolState = new Translate();
					break;
					
				case "toolBrush":
					toolState = new Brush();
					break;
					
				case "toolEraser":
					toolState = new Eraser();
					break;
			}
			buttonUpdate();
		}
		
		private function buttonUpdate():void
		{	
			toolBrush.pressed = toolScroll.pressed = toolEraser.pressed = false;
			
			if (toolState is Brush)
			{
				toolBrush.pressed = true;
			}
			if (toolState is Eraser)
			{
				toolEraser.pressed = true;
			}
			if (toolState is Translate)
			{
				toolScroll.pressed = true;
			}
		}
		
		public function onMouseScroll(e:MouseEvent):void{
			zoomSlider.setCurrent((e.delta >0)?zoomSlider.curVal + 0.1:zoomSlider.curVal - 0.1);
		}
		
		private function onSliderUpdate(e:Event):void{
			adjustZoom();
		}
		
		public function onTileLibRelease(e:MouseEvent):void{
			if (!defTileWindow.scrolled){
				trace(e.target.name);
				curTileData = defTileList[int(e.target.name)];
				populateTileInputs(curTileData);			
			}
		}
		
		public function onUsedTileLibRelease(e:MouseEvent):void{
			if(!usedTileWindow.scrolled){
				curTileData = jsonTileList[int(e.target.name)];
				trace("onUsedtileLibRelease " + curTileData.id);
				populateTileInputs(curTileData);			
			}
		}
		
		public function onTileMove(e:MouseEvent):void{
			
			lastMousePos.y = curMousePos.y;
			curMousePos.y = mouseY;
			var dif:Number = curMousePos.y - lastMousePos.y;
			
			if(curTileBM.y + dif < -(curTileBM.height - 386)){
			   	curTileBM.y = -(curTileBM.height - 386);
			}else if(curTileBM.y + dif > 0){
				curTileBM.y = 0;
			}else{
				curTileBM.y += dif;
			}
			//tileIndicator.y = curTileBM.y + (indY * tileSize);
			tileScroll = true;			
			
		}
		
		public function saveTileFromInputs(e:MouseEvent):void{
			if(inputsNotBlank()){
				var tTile:Object = new Object();
				for(var field in curTileData){
					if(field == "frames" || field == "hitbox"){
						tTile[field] = curTileData[field];
					}
				}
				
				for each(var tInput in tileVars){
					if (tInput is MC_Button)
					{
						tTile[tInput.labelTxt] = tInput.isPressed;
					}else{
						tTile[tInput.fieldName] = tInput.currentValue;
					}
					
				}
				pushTile(tTile);
			}
			
		}
		
		public function updateTileFromInputs(e:MouseEvent):void{
			if(inputsNotBlank()){
				for(var field:String in curTileData){
					if(field != "frames" && field != "hitbox" && field != "id"){
						delete curTileData[field];
					}
				}
				for each(var tInput in tileVars){
					trace((tInput is MC_Button) + " button");
					if (tInput is MC_Button)
					{
						curTileData[tInput.labelTxt] = tInput.isPressed;
					}
					if (tInput is PairedInput)
					{
						curTileData[tInput.fieldName] = tInput.currentValue;
					}
					
				}
				if(curTileData.id != undefined) jsonTileList[curTileData.id] = curTileData;
			}
			
		}
		
		private function createBitmapData(sheet:BitmapData,x:int,y:int,width:int,height:int,reverse:Boolean):BitmapData{
			var sprite:BitmapData = new BitmapData(width,height,true);
			sprite.copyPixels(sheet,new Rectangle(x,y,width,height),new Point(0,0));
			if(reverse){
				var newSprite:BitmapData = new BitmapData(sprite.width,sprite.height,true,0x00ffffff);
				var mx:Matrix = new Matrix();
				mx.scale(-1,1);
				mx.translate(sprite.width,0);
				newSprite.draw(sprite,mx);
				sprite = newSprite;
			}
			return sprite;
		}
				
		private function initialize(e:Event = null):void{
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			startGame();
		}
	}
}