package cc
{
	import cc.define.AvatarPartID;
	import cc.define.AvatarPartType;
	import cc.define.CharType;
	import cc.graphics.layers.SceneAvatarLayer;
	import cc.graphics.layers.SceneGrid;
	import cc.graphics.layers.SceneHeadLayer;
	import cc.graphics.layers.SceneInteractiveLayer;
	import cc.graphics.layers.SceneMapLayer;
	import cc.graphics.layers.SceneSmallMapLayer;
	import cc.loader.MapLoader;
	import cc.tools.SceneCache;
	import cc.vo.avatar.AvatarParamData;
	import cc.vo.map.MapInfo;
	import cc.vo.map.SceneInfo;
	
	import com.greensock.TweenLite;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import wit.draw.DrawHelper;

	/**
	 * 游戏场景
	 * <br> 所有玩家能看到的对象都在场景中渲染
	 * <br> 所以场景对象管理着所有这些对象
	 * <br> 还包括场景自身的场景图的加载和卸载管理
	 */
    public class CCScene extends Sprite
	{
		public static var eventCenter:Sprite = new Sprite;
        private static const floor:Function = Math.floor;
        private static const TILE_WIDTH:Number = SceneInfo.TILE_WIDTH;
        private static const TILE_HEIGHT:Number = SceneInfo.TILE_HEIGHT;
        private static const MAX_AVATARBD_WIDTH:Number = SceneAvatarLayer.MAX_AVATARBD_WIDTH;
        private static const MAX_AVATARBD_HEIGHT:Number = SceneAvatarLayer.MAX_AVATARBD_HEIGHT;

        public var sceneConfig:SceneInfo;							// 场景定义
        public var mapConfig:MapInfo;								// 地图定义
        public var sceneCamera:CCCamera;							// 摄像机
        public var sceneRender:CCRender;							// 渲染器, 自己建立侦听器负责定时渲染
		
        public var mainChar:CCCharacter;							// 主玩家
        public var renderCharacters:Array;							// 可见的角色列表  = CCCharacters + _sceneDummies
        public var sceneCharacters:Array;							// 场景内角色列表
        private var _sceneDummies:Array;							// 场景傀儡
        private var _mouseChar:CCCharacter;							// 鼠标当前对象
		
        public var sceneSmallMapLayer:SceneSmallMapLayer;			// 小地图层
//        public var sceneMapLayer:SceneSingleMapLayer;				// 背景层
        public var sceneMapLayer:SceneMapLayer;						// 背景层
        public var sceneAvatarLayer:SceneAvatarLayer;				// 角色层
		public var sceneHeadLayer:SceneHeadLayer;					// 昵称/称号层
        public var sceneInteractiveLayer:SceneInteractiveLayer;		// 交互层
		public var sceneGrid:SceneGrid;
		
        private var _mask:Shape;									// 尺寸遮罩
        private var _mouseOnCharacter:CCCharacter;					// 当前鼠标所在的角色
        private var _selectedCharacter:CCCharacter;					// 当前选中的角色 
		private var _selectedAvatarParamData:AvatarParamData;		// 选中角色的数据
		public var blankAvatarParamData:AvatarParamData;			// 空对象（加载中显示的形象）
		public var shadowAvatarParamData:AvatarParamData;			// 影子
		
        private var _charVisible:Boolean = true;					// 对象全局可见标志
        private var _charHeadVisible:Boolean = true;				// 昵称/称号层全局可见标志
        private var _charAvatarVisible:Boolean = true;				// 角色全局可见标志

		/**
		 * 初始化场景
		 * 	小地图层：sceneSmallMapLayer
		 * 	地图层: sceneMapLayer
		 * 	人物层: sceneAvatarLayer
		 * 	昵称/称号层: sceneHeadLayer
		 * 	事件交互层: sceneInteractiveLayer
		 * 	摄像机: sceneCamera 负责定位需要渲染的地图区域
		 * 	渲染器: sceneRender 负责定期渲染地图
		 * 
		 * @param _width width
		 * @param _height height
		 */
        public function CCScene(_width:Number, _height:Number) {
			super();
            
            if ( !CCDirector.IsReady ) {
                throw new Error("Scene::Engine must be initialized.");
            }
			
            renderCharacters = [];
            sceneCharacters = [];
            _sceneDummies = [];
			
			// 每个场景可以有不同的大小
            sceneConfig = new SceneInfo(_width, _height);
			
			// 小地图
            sceneSmallMapLayer = new SceneSmallMapLayer(this);
            addChild(sceneSmallMapLayer);
			
			// 地图
            sceneMapLayer = new SceneMapLayer(this);
            addChild(sceneMapLayer);
			
			// 网格 
			sceneGrid = new SceneGrid();
			addChild(sceneGrid);
			
			// 人物层
            sceneAvatarLayer = new SceneAvatarLayer(this);
            addChild(sceneAvatarLayer);
			
			// 文字层
			sceneHeadLayer = new SceneHeadLayer(this);
			addChild(sceneHeadLayer);
			
			// 交互层, 侦听鼠标消息, 检测命中了哪个对象
            sceneInteractiveLayer = new SceneInteractiveLayer(this);
            addChild(sceneInteractiveLayer);
			
			// 摄像头
            sceneCamera = new CCCamera(this);
			
			// 渲染器
            sceneRender = new CCRender(this);
			
            addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
        }
		
		/**
		 * 场景完成初始化并加入到舞台后
		 * <br>  设置场景可显示区域（遮罩）resize()
		 * <br>  监听场景事件 enableInteractiveHandle()
		 */
		private function onAddToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			
			// 设置遮罩，resize中会根据场景尺寸重新设置遮罩的尺寸
			if (!_mask) {
				_mask = new Shape();
				DrawHelper.drawRect(_mask, new Point(0, 0), new Point(10, 10));
				parent.addChild(_mask);
				mask = _mask;
			}
			
			// 扩展宽度，同时遮罩的大小也修改为场景的大小
			resize(sceneConfig.width, sceneConfig.height);
			
			// 设置遮罩和监听场景事件(SceneInteractiveLayer负责)
			// 事件接受的区域: sceneConfig.width, sceneConfig.height
			enableInteractiveHandle();
		}
		
		/**
		 * 获取对象可见标志
		 * <li> 除了玩家、英雄/宠物和坐骑外，其他默认显示
		 * <li> PLAYER, MOUNT, PET 
		 */
        public function getCharVisible(charType:int):Boolean {
            if ( charType != CharType.PLAYER && charType != CharType.PET 
				&& charType != CharType.MOUNT ) {
                return true;
            }
			
            return _charVisible;
        }
		
		public function setCharVisible(b:Boolean=false):void {
            var sceneChar:CCCharacter;
            _charVisible = b;
			
            for each (sceneChar in sceneCharacters) {
                if ( (sceneChar.type != CharType.PLAYER && sceneChar.type != CharType.MOUNT
					&& sceneChar.type != CharType.PET) || sceneChar == mainChar ) {
                	//
				} else {
                    sceneChar.visible = _charVisible;
                }
            }
        }
		
		public function getCharHeadVisible(charType:int):Boolean {
			if ( charType != CharType.PLAYER && charType != CharType.PET && charType != CharType.MOUNT ) {
				return true;
			}
			
			return _charHeadVisible;
		}
		
		public function setCharHeadVisible(b:Boolean=false):void {
			var sceneChar:CCCharacter;
			this._charHeadVisible = b;
			for each (sceneChar in this.sceneCharacters) {
				if ( (sceneChar.type != CharType.PLAYER && sceneChar.type != CharType.MOUNT
					&& sceneChar.type != CharType.PET) || sceneChar == mainChar ) {
					//
				} else {
					if (sceneChar.UseContainer) {
						if (this._charHeadVisible) {
							sceneChar.showContainer.ShowHeadFaceContainer();
						} else {
							sceneChar.showContainer.HideHeadFaceContainer();
						}
					}
				}
			}
		}
		
        public function getCharAvatarVisible(charType:int):Boolean {
			if ( charType != CharType.PLAYER && charType != CharType.PET && charType != CharType.MOUNT ) {
				return true;
			}
			
            return _charAvatarVisible;
        }
		
        public function setCharAvatarVisible(b:Boolean=false):void {
            var sceneChar:CCCharacter;
            _charAvatarVisible = b;
			
            for each (sceneChar in sceneCharacters) {
				if ( (sceneChar.type != CharType.PLAYER && sceneChar.type != CharType.MOUNT
					&& sceneChar.type != CharType.PET) || sceneChar == mainChar ) {
                	//
				} else {
                    sceneChar.avatar.visible = _charAvatarVisible;
                }
            }
        }
		
        public function resize(width:Number, height:Number):void {
			// 场景配置
            sceneConfig.width = width;
            sceneConfig.height = height;
			
			// 遮罩
            _mask.x = 0;
            _mask.y = 0;
            _mask.width = sceneConfig.width;
            _mask.height = sceneConfig.height;
			
			// 更新摄像机，很想知道这时候摄像机做了些什么事吧？
            sceneCamera.UpdateRangeXY();
            updateCameraNow();
        }
		
		/**
		 * 切换场景
		 *   停止走动
		 *   加载配置
		 * 
		 * @param mapId 地图ID
		 * @param mapPicId 地图图片id
		 * @param completehandler 加载完成回调
		 * @param updateHandler 加载过程回调
		 */
        public function switchScene(mapId:int, mapPicId:int, completehandler:Function=null, 
									updateHandler:Function=null):void {
            var scene:CCScene = null;
			
			// mapConf => mapConfig
			// mapTileInfo => [ x_y ] = MapTile
			// mapSolids => [ x_y ] = isSolid
			var newOnComplete:Function = function(mapConf:MapInfo, mapTileInfo:Object, mapSolids:Object):void
			{
                var slipcovers:Object;
                var sceneChar:CCCharacter;
                mapConfig = mapConf;
                SceneCache.MapTiles = mapTileInfo;		// 保存到 场景缓存
                SceneCache.MapSolids = mapSolids;
                if (mapConfig.slipcovers != null && mapConfig.slipcovers.length > 0) {		// 覆盖物信息
                    for each (slipcovers in mapConfig.slipcovers) {
                        sceneChar = createSceneCharacter(CharType.DUMMY);		// 建立傀儡
                        sceneChar.PixelX = slipcovers.pixel_x;
                        sceneChar.PixelY = slipcovers.pixel_y;
						sceneChar.loadAvatarPart(new AvatarParamData(slipcovers.sourcePath));
                    }
                }
				
                MapLoader.LoadSmallMap(scene);			// 加载地图缩略图
//                sceneMapLayer.initMap();				// 设置背景图（整图显示），加载地图在 sceneMaplayer.run()
				sceneMapLayer.InitMapZones();			// 设置背景图（分割显示）
				sceneAvatarLayer.creatAllAvatarBD();	// 清空对象层
                sceneInteractiveLayer.InitRange();		// 重新设置事件接受区域
				
                if (mainChar) {
                    mainChar.stopWalk(false);			// 停止走动
                    mainChar.updateNow = true;
                    sceneCamera.LookAt(mainChar);
                }
				
                if (_mouseChar) {
                    _mouseChar.visible = false;
                }
                
				/**
				 * see sceneRender.render()
				 * scene.sceneCamera.run();				// 相机跟随 
				 * scene.sceneMapLayer.run();			// 地图跟随，这里会加载地图
				 * scene.sceneAvatarLayer.run();		// 绘制人物
				 */
				sceneRender.StartRender(true);
				
                enableInteractiveHandle();
                if (completehandler != null) {
                    completehandler();
                }
            }
			
            disableInteractiveHandle();			// 禁止交互
            sceneRender.StopRender();			// 暂停渲染
            dispose();							// 释放
			
            MapLoader.LoadMapConfig(mapPicId, this, newOnComplete, updateHandler);	// 加载当前地图的配置信息
            scene = this;
        }
		
		/**
		 * 更新摄像机
		 * <br> 移动摄像机位置, 跟随玩家, 并保持在场景之内
		 */
        public function updateCameraNow():void {
            sceneCamera.Run(false);
        }
		
		public function showGrid():void {
			MapInfo.showGrid = true;
			sceneGrid.show(mapConfig.mapData.tiles, mapConfig.mapGridX, mapConfig.mapGridY, SceneInfo.TILE_WIDTH, SceneInfo.TILE_HEIGHT);
		}
		
		public function fill( fillGrids:Array ):void {
			sceneGrid.fillTiles( fillGrids, mapConfig.mapGridX, mapConfig.mapGridY, SceneInfo.TILE_WIDTH, SceneInfo.TILE_HEIGHT );			
		}
		
		public function hideGrid():void {
			MapInfo.showGrid = false;
			sceneGrid.hide();
		}
		
        public function createSceneCharacter(type:int=1, tx:int=0, ty:int=0, 
											 showIndex:int=0):CCCharacter {
            var sceneChar:CCCharacter = CCCharacter.createSceneCharacter(type, this, tx, ty, showIndex);
            addCharacter(sceneChar);
			
			// 非傀儡和掉落包
            if (sceneChar.type != CharType.DUMMY && sceneChar.type != CharType.BAG) {
                
				// 场景空白人物形象
				if (blankAvatarParamData != null) {
                    sceneChar.loadAvatarPart(blankAvatarParamData);
                }
				
				// 除了传送点和建筑，显示影子
                if (sceneChar.type != CharType.TRANSPORT
					&& shadowAvatarParamData != null) {
                    sceneChar.loadAvatarPart(shadowAvatarParamData);
                }
            }
            return sceneChar;
        }
		
        public function setMainChar(sceneChar:CCCharacter):void {
            mainChar = sceneChar;
			if (mainChar != null) {
				if (mainChar.UseContainer) {
					mainChar.showContainer.visible = true;
					mainChar.showContainer.ShowHeadFaceContainer();
				}
			}
        }
		
        public function setMouseChar(sceneChar:CCCharacter):void {
            _mouseChar = sceneChar;
        }
		
		public function setSelectedAvatarParamData(avatarParamData:AvatarParamData):void {
			avatarParamData.Id_noCheckValid = AvatarPartID.SELECTED;
			avatarParamData.avatarPartType = AvatarPartType.MAGIC;
			avatarParamData.depth = (-(int.MAX_VALUE) + 1);
			avatarParamData.useType = 0;
			avatarParamData.clearSameType = false;
			var sceneChar:CCCharacter = this._selectedCharacter;
			setSelectedCharacter(null);
			_selectedAvatarParamData = avatarParamData;
			setSelectedCharacter(sceneChar);
		}
		
		public function setBlankAvatarParamData(avatarParamData:AvatarParamData):void {
			avatarParamData.Id_noCheckValid = AvatarPartID.BLANK;
			avatarParamData.avatarPartType = AvatarPartType.BODY;
			avatarParamData.depth = AvatarPartType.GetDefaultDepth(AvatarPartType.BODY);
			avatarParamData.useType = 0;
			avatarParamData.clearSameType = false;
			blankAvatarParamData = avatarParamData;
		}
		
		public function setShadowAvatarParamData(avatarParamData:AvatarParamData):void {
			avatarParamData.Id_noCheckValid = AvatarPartID.SHADOW;
			avatarParamData.avatarPartType = AvatarPartType.MAGIC;
			avatarParamData.depth = -(int.MAX_VALUE);
			avatarParamData.useType = 0;
			avatarParamData.clearSameType = false;
			shadowAvatarParamData = avatarParamData;
		}
		
        public function addCharacter(sceneChar:CCCharacter):void {
            if (sceneChar == null) {
                return;
            }
			
			// 非傀儡
            if (sceneChar.type != CharType.DUMMY) {
                if (sceneCharacters.indexOf(sceneChar) != -1) {
                    return;
                }
                sceneCharacters.push(sceneChar);
                renderCharacters.push(sceneChar);
//                Log4J.Info("###场景其他角色数量：" + sceneCharacters.length + " 虚拟体数量：" + _sceneDummies.length);
            }
			// 傀儡
			else {
                if (_sceneDummies.indexOf(sceneChar) != -1) {
                    return;
                }
                _sceneDummies.push(sceneChar);
                renderCharacters.push(sceneChar);
//                Log4J.Info("###场景其他角色数量：" + sceneCharacters.length + " 虚拟体数量：" + _sceneDummies.length);
            }
			
            sceneChar.visible = ( sceneChar == mainChar || getCharVisible(sceneChar.type) );
            sceneChar.updateNow = true;
        }
		
        public function removeCharacter(sceneChar:CCCharacter, recycle:Boolean=true):void {
            var index:int;
            if (sceneChar == null) {
                return;
            }
			
			// 非傀儡
            if (sceneChar.type != CharType.DUMMY) {
                index = sceneCharacters.indexOf(sceneChar);
                if (index != -1) {
                    sceneCharacters.splice(index, 1);
                    renderCharacters.splice(renderCharacters.indexOf(sceneChar), 1);
					
					// TODO TweenLite.killTweensOf可以在任何时候终止缓动
					// 如果想强制终止缓动，可以传递一个 true 做为第二个参数
                    TweenLite.killTweensOf(sceneChar);
					
                    if (_mouseOnCharacter == sceneChar) {
                        setMouseOnCharacter(null);
                    }
                    if (_selectedCharacter == sceneChar) {
                        setSelectedCharacter(null);
                    }
					
                    if (recycle) {
                        CCCharacter.recycleSceneCharacter(sceneChar);
                    } else {
                        sceneChar.clearMe();
                    }
                }
//                Log4J.Info("###场景其他角色数量：" + sceneCharacters.length + " 虚拟体数量：" + _sceneDummies.length);
            }
			// 傀儡
			else {
                index = _sceneDummies.indexOf(sceneChar);
                if (index != -1) {
                    _sceneDummies.splice(index, 1);
                    renderCharacters.splice(renderCharacters.indexOf(sceneChar), 1);
                   
					TweenLite.killTweensOf(sceneChar);
					
					// 回收到对象池
                    if (recycle) {
                        CCCharacter.recycleSceneCharacter(sceneChar);
                    } else {
                        sceneChar.clearMe();
                    }
                }
//                Log4J.Info("###场景其他角色数量：" + sceneCharacters.length + " 虚拟体数量：" + _sceneDummies.length);
            }
        }
		
        public function removeCharacterByIDAndType(ID:int, type:int=1, recycle:Boolean=true):void {
            var sceneChar:CCCharacter = getCharByID(ID, type);
            if (sceneChar != null) {
                removeCharacter(sceneChar, recycle);
            }
        }
		
        public function getCharByID(ID:int, type:int=1):CCCharacter {
            var sceneChar:CCCharacter;
            for each (sceneChar in sceneCharacters) {
                if (sceneChar.id == ID && sceneChar.type == type) {
                    return sceneChar;
                }
            }
            return null;
        }
		
        public function getCharsByType(type:int=1):Array {
            var sceneChar:CCCharacter;
            var arr:Array = [];
            for each (sceneChar in sceneCharacters) {
                if (sceneChar.type == type) {
					arr.push(sceneChar);
                }
            }
            return arr;
        }
		
        public function dispose():void {
            var sceneChar:CCCharacter;
			
			// TODO SceneCache
            SceneCache.MapImgCache.dispose();
            SceneCache.InViewMapZones = {};
            SceneCache.MapTiles = {};
            SceneCache.MapSolids = {};
            SceneCache.MapZones = {};
            SceneCache.removeWaitingAvatar(null, null, null, [mainChar, _mouseChar]);
			
			// this & Scene
            mapConfig = null;
            sceneSmallMapLayer.Dispose();
            sceneMapLayer.Dispose();
            sceneAvatarLayer.Dispose();
            sceneHeadLayer.Dispose();
			
            var len:int;
            while (renderCharacters.length > len) {
                sceneChar = renderCharacters[len];
                if (sceneChar != mainChar && sceneChar != _mouseChar) {
                    removeCharacter(sceneChar);
                } else {
                    len++;
                }
            }
            hideMouseChar();
            setMouseOnCharacter(null);
            setSelectedCharacter(null);
            renderCharacters = [];
            sceneCharacters = [];
            _sceneDummies = [];
            _mouseOnCharacter = null;
            _selectedCharacter = null;
			
			// TODO sceneCamera.lookAt
            sceneCamera.LookAt(null);
            
			if (mainChar) {
                mainChar.stopWalk();
                addCharacter(mainChar);
				if (mainChar.showContainer) {
					sceneHeadLayer.addChild(mainChar.showContainer);
				}
            }
			
            if (_mouseChar) {
                addCharacter(_mouseChar);
            }
        }
		
        public function sceneDispatchEvent(event:Event):void {
            if (mapConfig != null) {
                sceneInteractiveLayer.dispatchEvent(event);
            }
        }
        
		public function enableInteractiveHandle():void {
            sceneInteractiveLayer.EnableInteractiveHandle();
        }
		
        public function disableInteractiveHandle():void {
            sceneInteractiveLayer.DisableInteractiveHandle();
        }
		
        public function showMouseChar(tx:Number, ty:Number):void {
            if (_mouseChar != null) {
                _mouseChar.TileX = tx;
                _mouseChar.TileY = ty;
                _mouseChar.visible = true;
            }
        }
		
        public function hideMouseChar():void {
            if (_mouseChar != null) {
                _mouseChar.visible = false;
            }
        }
		
        public function setMouseOnCharacter(sceneChar:CCCharacter):void {
            if (_mouseOnCharacter == sceneChar) {
                return;
            }
            if (_mouseOnCharacter != null && _mouseOnCharacter.usable) {
                _mouseOnCharacter.isMouseOn = false;
            }
			
            _mouseOnCharacter = sceneChar;
			
            if (_mouseOnCharacter != null && _mouseOnCharacter.usable) {
                _mouseOnCharacter.isMouseOn = true;
            } else {
                _mouseOnCharacter = null;
            }
        }
		
        public function getMouseOnCharacter():CCCharacter {
            return _mouseOnCharacter;
        }
		
        public function setSelectedCharacter(sceneChar:CCCharacter):void {
            if (_selectedCharacter == sceneChar) {
                return;
            }
			
            if (_selectedCharacter != null && _selectedCharacter.usable) {
                _selectedCharacter.removeAvatarPartByID(AvatarPartID.SELECTED);
                _selectedCharacter.isSelected = false;
            }
			
            _selectedCharacter = sceneChar;
			
            if (_selectedCharacter != null && _selectedCharacter.usable) {
                if (_selectedAvatarParamData != null) {
                    _selectedCharacter.loadAvatarPart(_selectedAvatarParamData);
                }
                _selectedCharacter.isSelected = true;
            } else {
                _selectedCharacter = null;
            }
        }
		
        public function getSelectedCharacter():CCCharacter {
            return _selectedCharacter;
        }
		
		/**
		 * 获得鼠标位置下的所有对象列表
		 * @return array [[MapTile, ...], [ElfCharacter, ...]]
		 */
        public function getSceneObjectsUnderPoint(mousePos:Point):Array {
            var sceneChar:CCCharacter;
            var resultArray:Array = [];
            var tilePosX:int = floor((mousePos.x / TILE_WIDTH));
            var tilePosY:int = floor((mousePos.y / TILE_HEIGHT));
			
			// 超出地图的范围
			if (tilePosX < 0 || tilePosY < 0 || tilePosX >= mapConfig.mapGridX || tilePosY >= mapConfig.mapGridY) {
                return resultArray;
            }
            var dH:int = floor((mousePos.x / MAX_AVATARBD_WIDTH));
            var dV:int = floor((mousePos.y / MAX_AVATARBD_HEIGHT));
            var bm:BitmapData = sceneAvatarLayer.getAvatarBD(dH, dV);
			if (!bm) {
                return resultArray;
            }
            resultArray.push(SceneCache.MapTiles[tilePosX + "_" + tilePosY]);
			
            var sceneCharList:Array;
            var color:uint = bm.getPixel32(mousePos.x - (dH * MAX_AVATARBD_WIDTH), mousePos.y - (dV * MAX_AVATARBD_HEIGHT));
            if (color != 0){
                sceneCharList = [];
                for each (sceneChar in sceneCharacters) {
                    if (sceneChar == mainChar){
						// 主角不需要处理
                    } else {
						// 鼠标坐标落在场景角色的范围
                        if (sceneChar.mouseRect != null && sceneChar.mouseRect.containsPoint(mousePos)) {
                            sceneCharList.push(sceneChar);
                        }
                    }
                }
                sceneCharList.sortOn("PixelY", (Array.DESCENDING | Array.NUMERIC));
                resultArray.push(sceneCharList);
            }
			
            return resultArray;
        }
		
		/**
		 * 获得鼠标位置下的所有对象列表
		 * @return array [[MapTile, ...], [ElfCharacter, ...]]
		 */
		public function getSceneObjectsUnderPointEx(mousePos:Point):Array {
			var sceneChar:CCCharacter;
			var resultArray:Array = [];
			var tilePosX:int = floor((mousePos.x / TILE_WIDTH));
			var tilePosY:int = floor((mousePos.y / TILE_HEIGHT));
			
			// 超出地图的范围
			if (tilePosX < 0 || tilePosY < 0 || tilePosX >= mapConfig.mapGridX || tilePosY >= mapConfig.mapGridY) {
				return resultArray;
			}
			resultArray.push(SceneCache.MapTiles[tilePosX + "_" + tilePosY]);
			
			var mx:Number;
			var my:Number;
			
			var sceneCharList:Array = [];
			for each (sceneChar in sceneCharacters) {
				if (sceneChar == mainChar) {
					// 主角不需要处理
				} else {
					if (sceneChar && sceneChar.headFace && sceneChar.headFace.stage) {
						mx = sceneChar.showContainer.stage.mouseX;
						my = sceneChar.showContainer.stage.mouseY;
					}
					// 鼠标坐标落在场景角色的范围
					if (sceneChar.headFace && sceneChar.headFace && sceneChar.headFace.hitTestPoint(mx, my)) {
						sceneCharList.push(sceneChar);
					}
				}
			}
			sceneCharList.sortOn("PixelY", (Array.DESCENDING | Array.NUMERIC));
			resultArray.push(sceneCharList);
			
			return resultArray;
		}
    }
}