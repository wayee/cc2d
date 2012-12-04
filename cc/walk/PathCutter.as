package cc.walk
{
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import cc.CCCharacter;
	import cc.events.CCEvent;
	import cc.events.CCEventActionWalk;
	import wit.event.EventDispatchCenter;

	/**
	 * 莫非传说中的碰撞检测
	 * 	<li> 引用: WalkData.walk_pathCutter
	 */
    public class PathCutter 
	{
        public var sceneCharacter:CCCharacter;
        private var sourcePath:Array;
        private var movePaths:Array;				// 路径
        private var currentMovetag:int = 0;			// 当前位置

        public function PathCutter(sceneChar:CCCharacter)
		{
            sceneCharacter = sceneChar;
        }
		
        public function clear():void
		{
            sourcePath = null;
            movePaths = null;
            currentMovetag = 0;
        }
		
		/**
		 * 移动一格
		 */
        public function walkNext(tx:int, ty:int):void {
            if (movePaths == null || movePaths.length == 0) {
                return;
            }
			
            var paths:Array = movePaths[currentMovetag];
			// if: paths[ last ] == [tx, ty]
            if (paths[(paths.length - 1)][0] == tx && paths[(paths.length - 1)][1] == ty){
                currentMovetag++;	// 下一个路径
                paths = movePaths[currentMovetag];
                if (paths == null || paths.length == 1) {
                    return;
                }
                sendPathMsg(paths);		// 新路径
            } else {
                if (tx == -1 && ty == -1) {
                    if (paths.length == 1) {
                        sendPathMsg(paths);
                    } else {
                        sendPathMsg(paths);
                    }
                }
            }
        }
		
        public function cutMovePath(paths:Array):void {
            var index:int;
            if (paths.length < 1) {
                return;
            }
            movePaths = [];
            currentMovetag = 0;
            sourcePath = paths;
            var pathLength:int = sourcePath.length;
            var num:int = 5;
            var tmpPaths:Array = [];
            var tmpPath:Array = [];
            index = 0;
            while (index < pathLength) {
                tmpPaths[tmpPaths.length] = [sourcePath[index][0], sourcePath[index][1]];
                if (index != 0 && index % 5 == 0 || index == pathLength - 1) {
                    if (movePaths.length != 0) {
                        tmpPaths.splice(0, 0, [tmpPath[0], tmpPath[1]]);
                    }
                    tmpPath = [sourcePath[index][0], sourcePath[index][1]];
                    movePaths[movePaths.length] = tmpPaths;
                    tmpPaths = [];
                }
                index++;
            }
        }
		
		/**
		 * 到达下一个路径, 发送路径
		 */
        public function sendPathMsg(path:Array):void {
            if (path.length < 2) {
                return;
            }
            var bytePath:ByteArray = PathConverter.convertToVector(path);
            var event:CCEvent = new CCEvent(CCEvent.WALK, CCEventActionWalk.SEND_PATH, [sceneCharacter, bytePath]);
            EventDispatchCenter.getInstance().dispatchEvent(event);
        }
		
        private function convertPath(_arg1:Array):Array {
            var index:int;
            var _local2:Array = [];
            _local2[_local2.length] = [_arg1[0][0], _arg1[0][1]];
            var _local4:int = _arg1.length;
            index = 0;
            while (index < _local4) {
                _local2[_local2.length] = getVectorBy2Point(new Point(_arg1[index][0], _arg1[index][0]), new Point(_arg1[(index + 1)][0], _arg1[(index + 1)][0]));
                index++;
            }
            return _local2;
        }
		
        private function getVectorBy2Point(p1:Point, p2:Point):int {
            var xDistance:int = p2.x - p1.x;
            var yDistance:int = p2.y - p1.y;
            if (xDistance == 0 && yDistance == 1) {
                return 0;
            }
            if (xDistance == -1 && yDistance == 1) {
                return 1;
            }
            if (xDistance == -1 && yDistance == 0) {
                return 2;
            }
            if (xDistance == -1 && yDistance == -1) {
                return 3;
            }
            if (xDistance == 0 && yDistance == -1) {
                return 4;
            }
            if (xDistance == 1 && yDistance == -1) {
                return 5;
            }
            if (xDistance == 1 && yDistance == 0) {
                return 6;
            }
            if (xDistance == 1 && yDistance == 1) {
                return 7;
            }
            return -1;
        }
    }
}