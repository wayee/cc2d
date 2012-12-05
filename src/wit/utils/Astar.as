package wit.utils
{
	/**
	 * 寻路
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class Astar
	{
        public function Astar():void
		{
        }
		
		/**
		 * 寻径, map[ "x_y" ] = 0 表示可通过
		 * @param map SceneCache.mapSolids
		 * @param x0 起点x
		 * @param y0 起点y
		 * @param x1 终点x
		 * @param y1 终点y
		 */
        public static function search(map:Object, x0:int, y0:int, x1:int, y1:int, _arg6:int=-1):Array
		{
            var _local16:Object;
            var _local17:Object;
            var _local18:int;
            var _local19:int;
            var _local20:int;
            var _local21:int;
            var _local22:Object;
            var _local23:int;
			
			// 地图快速判断
            if (!map) {
                return (null);
            }
            if (x0 == x1 && y0 == y1) {
                return null;
            }
            if (map[x0 + "_" + y0] != 0) {			// 起点不可移动, !=0 表示障碍
                return null;
            }
            if (map[x1 + "_" + y1] != 0) {			// 终点不可移动
                return null;
            }
			
            var _local7:Array = new Array();
            var _local8:Array = new Array();
            var _local9:Array = new Array();
            var posGrid:Object = new Object();
            posGrid.r1 = [-1, -1];			// 左上
            posGrid.r2 = [0, -1];			// 上
            posGrid.r3 = [1, -1];			// 右上
            posGrid.r4 = [1, 0];			// 右
            posGrid.r5 = [1, 1];			// 右下
            posGrid.r6 = [0, 1];			// 下
            posGrid.r7 = [-1, 1];			// 左下
            posGrid.r8 = [-1, 0];			// 左
			
            var _local11:Object = new Object();
            _local11.x = x0;
            _local11.y = y0;
            _local11.g = 0;
			
            var dist_x:int = (((x0 - x1) < 0)) ? ((x0 - x1) * -1) : (x0 - x1);
            var dist_y:int = (((y0 - y1) < 0)) ? ((y0 - y1) * -1) : (y0 - y1);
            _local11.h = ((dist_x + dist_y) * 10);			// (距离X + 距离Y) * 10
            _local11.f = (_local11.g + _local11.h);			// f = g + h
            _local11.parentPoint = 0;
			
            var _local14:int;
            var _temp1:int = _local14;
            _local14 = (_local14 + 1);
            updatePoint(_local8, _local11, _temp1);
			
            _local8[        ((_local11.x + "_") + _local11.y)    ] = _local11;		// [x_y] = _local11
            var _local15:int;
            _local15++;
            if (_arg6 > 0){
                if (_local15 > _arg6){
                    return (null);
                }
            }
            if (_local8.length == 0){
                return (null);
            }
            var _temp2:int = _local14;
            _local14 = (_local14 - 1);
            _local16 = delPoint(_local8, _temp2);
            _local9.push(_local16);
            _local9[((_local16.x + "_") + _local16.y)] = _local16;
            if ((((_local16.x == x1)) && ((_local16.y == y1)))){
                _local17 = _local16;
                _local7.push([_local17.x, _local17.y]);
                while (true) {
                    if (_local17.parentPoint == 0){
                        return (_local7);
                    }
                    _local17 = _local17.parentPoint;
                    _local7.push([_local17.x, _local17.y]);
                }
            }
            _local18 = 1;
            while (_local18 <= 8) {
                _local19 = (_local16.x + posGrid[("r" + _local18)][0]);
                _local20 = (_local16.y + posGrid[("r" + _local18)][1]);
                if (((!((map[((_local19 + "_") + _local20)] == 0))) || (!((_local9[((_local19 + "_") + _local20)] == undefined))))){
                } else {
                    _local21 = (_local18 % 2);
                    if ((((_local21 == 1)) && (((!((map[((_local16.x + "_") + _local20)] == 0))) || (!((map[((_local19 + "_") + _local16.y)] == 0))))))){
                    } else {
                        _local22 = _local8[((_local19 + "_") + _local20)];
                        _local23 = (_local16.g + ((_local21 == 0)) ? 10 : 14);
                        if (_local22 != null){
                            if (_local23 < _local22.g){
                                _local22.g = _local23;
                                _local22.f = (_local22.g + _local22.h);
                                _local22.parentPoint = _local16;
                                updatePoint(_local8, _local22, _local8.indexOf(_local22));
                            }
                        } else {
                            _local22 = new Object();
                            _local22.x = _local19;
                            _local22.y = _local20;
                            _local22.g = _local23;
                            dist_x = (((_local19 - x1) < 0)) ? ((_local19 - x1) * -1) : (_local19 - x1);
                            dist_y = (((_local20 - y1) < 0)) ? ((_local20 - y1) * -1) : (_local20 - y1);
                            _local22.h = ((dist_x + dist_y) * 10);
                            _local22.f = (_local22.g + _local22.h);
                            _local22.parentPoint = _local16;
                            var _temp3:int = _local14;
                            _local14 = (_local14 + 1);
                            updatePoint(_local8, _local22, _temp3);
                            _local8[((_local22.x + "_") + _local22.y)] = _local22;
                        }
                    }
                }
                _local18++;
            }
			return _local8;
        }
		
		/**
		 * 把 obj 放入到 arr[index] 位置中, 并对 arr 进行排序<br>
		 * arr 类似一个 open_list, 每次插入新对象 obj, 都维持它的次序<br>
		 * 这是大部分游戏中对 A* 的优化算法, 但是还是不够优化.
		 */
        private static function updatePoint(arr:Array, obj:Object, index:int):void
		{
            var a:Object;
            var b:Object;
            arr[index] = obj;
            var next:int = (index + 1);
            var mid:int = (next / 2);
            while (mid > 0) {
                a = arr[(next - 1)];
                b = arr[(mid - 1)];
                if (a.f < b.f){
                    arr[(next - 1)] = b;
                    arr[(mid - 1)] = a;
                    next = mid;
                    mid = (next / 2);
                } else {
                    break;
                }
            }
        }
		
        private static function delPoint(_arg1:Array, _arg2:int):Object
		{
            var _local6:int;
            var _local7:int;
            var _local8:Object;
            var _local9:Object;
            var _local10:Object;
            var _local3:Object = _arg1[0];
            var _local4:int = (_arg2 - 1);
            _arg1[0] = _arg1[_local4];
            _arg1.pop();
            var _local5:int;
            while (((_local5 + 1) * 2) < _local4) {
                _local8 = _arg1[_local5];
                _local6 = ((_local5 + 1) * 2);
                _local7 = (_local6 + 1);
                _local9 = _arg1[(_local6 - 1)];
                _local10 = ((_local7)!=_local4) ? _arg1[(_local7 - 1)] : null;
                if (_local10 != null){
                    if ((((_local8.f < _local9.f)) && ((_local8.f < _local10.f)))){
                        break;
                    }
                    if (_local9.f <= _local10.f){
                        if (_local8.f > _local9.f){
                            _arg1[_local5] = _local9;
                            _arg1[(_local6 - 1)] = _local8;
                            _local5 = (_local6 - 1);
                        } else {
                            _arg1[_local5] = _local10;
                            _arg1[(_local7 - 1)] = _local8;
                            _local5 = (_local7 - 1);
                        }
                    } else {
                        if (_local8.f > _local10.f){
                            _arg1[_local5] = _local10;
                            _arg1[(_local7 - 1)] = _local8;
                            _local5 = (_local7 - 1);
                        } else {
                            _arg1[_local5] = _local9;
                            _arg1[(_local6 - 1)] = _local8;
                            _local5 = (_local6 - 1);
                        }
                    }
                } else {
                    if (_local8.f > _local9.f){
                        _arg1[_local5] = _local9;
                        _arg1[(_local6 - 1)] = _local8;
                        _local5 = (_local6 - 1);
                    } else {
                        break;
                    }
                }
            }
            return (_local3);
        }
    }
}
