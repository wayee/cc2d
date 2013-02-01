package cc.utils
{
	import flash.geom.Point;
	
	import cc.vo.map.SceneInfo;
	import cc.CCNode;
	import cc.CCScene;
	import cc.vo.map.MapTile;
	import cc.tools.SceneCache;
	import cc.utils.Transformer;
	import wit.utils.math;

    public class SceneUtil
	{
		/**
		 * 可视范围内左右偏移中点位置的块数
		 */
        public static function GetViewTileRangeXY(scene:CCScene):Point {
            var range:Point = new Point();
            range.x = Math.ceil((scene.sceneConfig.width/SceneInfo.TILE_WIDTH - 1) / 2) + 1;
            range.y = Math.ceil((scene.sceneConfig.height/SceneInfo.TILE_HEIGHT - 1) / 2) + 1;
            return range;
        }
		
		/**
		 * 可视范围内左右偏移中点位置的块族数
		 */
        public static function GetViewZoneRangeXY(scene:CCScene):Point {
            var range:Point = new Point();
            range.x = Math.ceil((scene.sceneConfig.width/SceneInfo.ZONE_WIDTH - 1) / 2) + 1;
            range.y = Math.ceil((scene.sceneConfig.height/SceneInfo.ZONE_HEIGHT - 1) / 2) + 1;
            return range;
        }
		
		/**
		 * 返回  pos.x +/- width, pos.y +/- height 范围内的坐标点 [Point]
		 */
        public static function FindViewZonePoints(pos:Point, width:int, height:int):Array {
            var x:int;
            var y:int;
            var ret:Array = [];
            if (width < 0 || height < 0) {
                return [pos];
            }
            var left:int = pos.x - width;
            var right:int = pos.x + width;
            var top:int = pos.y - height;
            var bottom:int = pos.y + height;
            x = left;
            while (x <= right) {
                y = top;
                while (y <= bottom) {
                    ret.push(new Point(x, y));
                    y++;
                }
                x++;
            }
            return ret;
        }
		
        public static function GetMapTile(x:int, y:int):MapTile {
            return SceneCache.MapTiles[x + "_" + y] as MapTile;
        }
		
        public static function IsSolid(x:int, y:int):Boolean {
            var mapTile:MapTile = GetMapTile(x, y);
            if (mapTile == null || mapTile.isSolid) {
                return true;
            }
            return false;
        }
		
        public static function IsIsland(x:int, y:int):Boolean {
            var mapTile:MapTile = GetMapTile(x, y);
            if (mapTile != null && mapTile.isIsland) {
                return true;
            }
            return false;
        }
		
        public static function IsMask(x:int, y:int):Boolean {
            var mapTile:MapTile = GetMapTile(x, y);
            if (mapTile != null && mapTile.isMask) {
                return true;
            }
            return false;
        }
		
        public static function HasSolidBetween2MapTile(mapTile1:MapTile, mapTile2:MapTile):Boolean {
            var mapTile:MapTile;
            var pos1:Point = new Point(mapTile1.PixelX, mapTile1.PixelY);
            var pos2:Point = new Point(mapTile2.PixelX, mapTile2.PixelY);
            var angle:Number = math.getTwoPointsAngle(pos1, pos2);
            var logicAngle:Number = (angle * Math.PI) / 180;
            var opposieSide:Number = Math.cos(logicAngle);
            var neighborSide:Number = Math.sin(logicAngle);
            var dist:Number = Point.distance(pos1, pos2);
            var pos2Ele:CCNode = new CCNode();
            pos2Ele.PixelX = pos2.x;
            pos2Ele.PixelY = pos2.y;
            if (Math.abs(mapTile1.TileX - pos2Ele.TileX) <= 1 && Math.abs(mapTile1.TileY - pos2Ele.TileY) <= 1) {
                return false;
            }
            mapTile = SceneCache.MapTiles[pos2Ele.TileX + "_" + pos2Ele.TileY];
            if (mapTile.isSolid) {
                return true;
            }
            pos2Ele.PixelX = pos2Ele.PixelX - (SceneInfo.TILE_WIDTH * opposieSide);
            pos2Ele.PixelY = pos2Ele.PixelY - (SceneInfo.TILE_HEIGHT * neighborSide);
			
			return false;
        }
		
        public static function GetLineMapTile(mapTile1:MapTile, mapTile2:MapTile, customDist:Number=0):MapTile {
            var mapTile:MapTile;
            var pos1:Point = new Point(mapTile1.PixelX, mapTile1.PixelY);
            var pos2:Point = new Point(mapTile2.PixelX, mapTile2.PixelY);
            var angle:Number = math.getTwoPointsAngle(pos1, pos2);
            var logicAngle:Number = ((angle * Math.PI) / 180);
            var opposieSide:Number = Math.cos(logicAngle);
            var neighborSide:Number = Math.sin(logicAngle);
            var dist:Number = Point.distance(pos1, pos2);
            var pos3:Point = new Point();
            if (customDist > 0 && customDist < dist) {
                pos3.x = (mapTile1.PixelX + (customDist * opposieSide));
                pos3.y = (mapTile1.PixelY + (customDist * neighborSide));
            } else {
                pos3.x = pos2.x;
                pos3.y = pos2.y;
            }
            var pos2Ele:CCNode = new CCNode();
            pos2Ele.PixelX = pos3.x;
            pos2Ele.PixelY = pos3.y;
            if (Math.abs(mapTile1.TileX - pos2Ele.TileX) <= 1 && Math.abs(mapTile1.TileY - pos2Ele.TileY) <= 1) {
                return mapTile1;
            }
            mapTile = SceneCache.MapTiles[pos2Ele.TileX + "_" + pos2Ele.TileY];
            if (!mapTile.isSolid) {
                return (mapTile);
            }
            pos2Ele.PixelX = (pos2Ele.PixelX - (SceneInfo.TILE_WIDTH * opposieSide));
            pos2Ele.PixelY = (pos2Ele.PixelY - (SceneInfo.TILE_HEIGHT * neighborSide));
			
			return mapTile;
        }
        
		public static function GetRoundMapTile(mapTile1:MapTile, mapTile2:MapTile):MapTile {
            var _local7:Point;
            var _local8:Point;
            var _local9:MapTile;
            var _local10:int;
            var _local11:Array;
            var _local12:int;
            if (!mapTile2.isSolid) {
                return mapTile2;
            }
            var pxPoint:Point = new Point(mapTile2.PixelX, mapTile2.PixelY);
            var tilePoint:Point = new Point(mapTile2.TileX, mapTile2.TileY);
            var _local5:Point = new Point(tilePoint.x, tilePoint.x);
            var _local6:Point = new Point(tilePoint.y, tilePoint.y);
            _local5.x = (_local5.x - 1);
            _local5.y = (_local5.y + 1);
            _local6.x = (_local6.x - 1);
            _local6.y = (_local6.y + 1);
            _local11 = [];
            _local10 = _local5.x;
            while (_local10 <= _local5.y) {
                _local11.push(new Point(_local10, _local6.x), new Point(_local10, _local6.y));
                _local10++;
            }
            _local10 = (_local6.x + 1);
            while (_local10 < (_local6.y - 1)) {
                _local11.push(new Point(_local5.x, _local10), new Point(_local5.y, _local10));
                _local10++;
            }
            _local12 = _local11.length;
            _local10 = 0;
            while (_local10 < _local12) {
                _local7 = _local11[_local10];
                _local8 = Transformer.TransTilePoint2PixelPoint(_local7);
                if (mapTile1 == null || mapTile1.TileX == _local7.x && mapTile1.TileY == _local7.y) {
                    return mapTile1;
                }
                _local9 = SceneCache.MapTiles[_local7.x + "_" + _local7.y];
                if (_local9 == null) {
                } else {
                    if (!_local9.isSolid) {
                        return _local9;
                    }
                }
                _local10++;
            }
			return _local9;
        }
		
        public static function GetRoundMapTile2(mapTile1:MapTile, mapTile2:Number=0):MapTile {
            var _local7:Point;
            var _local8:Point;
            var _local9:MapTile;
            var _local10:int;
            var _local11:Array;
            var _local12:int;
            if (!mapTile1.isSolid){
                return (mapTile1);
            }
            var pxPoint:Point = new Point(mapTile1.PixelX, mapTile1.PixelY);
            var tilePoint:Point = new Point(mapTile1.TileX, mapTile1.TileY);
            var _local5:Point = new Point(tilePoint.x, tilePoint.x);
            var _local6:Point = new Point(tilePoint.y, tilePoint.y);
            _local5.x = (_local5.x - 1);
            _local5.y = (_local5.y + 1);
            _local6.x = (_local6.x - 1);
            _local6.y = (_local6.y + 1);
            _local11 = [];
            _local10 = _local5.x;
            while (_local10 <= _local5.y) {
                _local11.push(new Point(_local10, _local6.x), new Point(_local10, _local6.y));
                _local10++;
            }
            _local10 = (_local6.x + 1);
            while (_local10 < (_local6.y - 1)) {
                _local11.push(new Point(_local5.x, _local10), new Point(_local5.y, _local10));
                _local10++;
            }
            _local12 = _local11.length;
            _local10 = 0;
            while (_local10 < _local12) {
                _local7 = _local11[_local10];
                _local8 = Transformer.TransTilePoint2PixelPoint(_local7);
                if (Point.distance(pxPoint, _local8) >= mapTile2){
                    return null;
                }
                _local9 = SceneCache.MapTiles[_local7.x + "_" + _local7.y];
                if (_local9 == null){
                } else {
                    if (!_local9.isSolid){
                        return _local9;
                    }
                }
                _local10++;
            }
			return _local9;
        }
    }
}