package cc.utils
{
	import flash.geom.Point;
	
	import flashx.textLayout.formats.Float;

	/**
	 * 战斗寻路相关
	 *  
	 * @author zl <datuhao@gmail.com>
	 * 
	 */
	public class PathFind
	{
		private static const START_IDX:int = 1;
		
		private static const HESTIMATE:int    = 10;
		private static const INIT_STAT:int    = 0;
		private static const OPEN_STAT:int    = 1;
		private static const CLOSE_STAT:int   = 2;
		
		private static const SEARCH_LIMIT:int = 80000;
		
		public static var cossCoord:Array = [];
		private static const MAX_SLOPE:Number = 10000.0;
		private static const MIN_SLOPE:Number = 0.00001;
		
		private static var dirs:Object = { 				
			0:{ 'dx':0, 'dy': -1 },
			1:{ 'dx':1, 'dy':0 },
			2:{ 'dx':0, 'dy':1 },
			3:{ 'dx':-1, 'dy':0 },
			4:{ 'dx':1, 'dy':-1 },
			5:{ 'dx':1, 'dy':1 },
			6:{ 'dx':-1, 'dy':1 },
			7:{ 'dx':-1, 'dy':-1 }
		};	
		
		public static function isValid( bfMap:Object, p:Point ):Boolean
		{
			if( p.x < 1	|| p.x > bfMap['mapGridX'] || p.y < 1 || p.y > bfMap['mapGridY'] )
				return false;
			return true;
		}
		
		public static function isBlock( bfMap:Object, pos:int ):Boolean
		{
			if( ! bfMap['tiles'].hasOwnProperty( pos ) )
				return false;
			if( bfMap['tiles'][pos] != null && bfMap['tiles'][pos] != 0 && bfMap['tiles'][pos] != 2 )
				return true;
			return false;
		}

		public static function pos2Coord( bfMap:Object, pos:int ):Point
		{
			var coord:Point = new Point;
			coord.y = int( ( pos - 1 ) / bfMap['mapGridX'] ) + 1;
			coord.x = ( pos - 1 ) % bfMap['mapGridX'] + 1;
			return coord;
		}
		
		public static function coord2Pos( bfMap:Object, coord:Point ):int
		{
			return ( coord.y - 1 ) * bfMap['mapGridX'] + coord.x;
		}		
		
		public static function get_crossing( slope:Number, startCoord:Point, endCoord:Point ):void
		{
			var steps:int = Math.abs( endCoord.x - startCoord.x ) + 1;
			var step:int  = endCoord.x < startCoord.x ? -1 : 1;
			var cell_x:int = startCoord.x;
			var coord:Point;
			
			for( var i:int  = 0; i < steps; i++ )
			{
				if( cell_x )
				{
					coord = new Point;
					coord.x = cell_x;
					coord.y =  Math.round(( coord.x - startCoord.x ) * slope) + startCoord.y;
					cossCoord.push( coord );
				}
				cell_x += step;
			}
			
			steps = Math.abs( endCoord.y - startCoord.y ) + 1;
			step  = endCoord.y < startCoord.y ? -1 : 1;
			var cell_y:int = startCoord.y;
			for(  i  = 0; i < steps; i++ ) {
				if( cell_y ) {
					coord = new Point;
					coord.y = cell_y;
					coord.x =  Math.round(( coord.y - startCoord.y ) / slope) + startCoord.x;
					cossCoord.push( coord );
				}
				cell_y += step;
			}
		}

		public static function is_through( startCoord:Point, endCoord:Point, bfMap:Object ):Boolean
		{
			cossCoord = [];
			/// 获取与所有x,y轴的交叉点
			var slope:Number = 0;
			if( endCoord.x != startCoord.x )
				slope = ( endCoord.y - startCoord.y ) / ( endCoord.x - startCoord.x );
			else
				slope = ( endCoord.y - startCoord.y ) / MIN_SLOPE;
			
			get_crossing(slope,startCoord,endCoord);
			for each(var coord:Point in cossCoord){
				var pos:int = coord2Pos(bfMap, coord);
				if( isBlock( bfMap, pos ) )
					return false;
			} 
			return true;			
		}
		
		/**
		* @brief 获取两点间最小路径
		* @param 起始位置
		* @param 结束位置	
		* @param 地图阻挡信息
		* @param 是否只返回关键路径
		* @param 是否飞行寻路（地面阻挡无效，但是降落点不能阻挡）
		* @param simplified 是否优化路径
		*/
		public static function getPath( startPos:int, endPos:int, bfMap:Object, 
										keyPath:Boolean=false, isFly:Boolean=false, simplified:Boolean=true ):Array
		{
			var path:Array  = new Array();
			if( startPos == endPos )
				return path;
			
			if( isBlock( bfMap, endPos ) )
				return path;
			
			//两点间无阻挡则直接移动
			var startCoord:Point = pos2Coord( bfMap, startPos );
			var endCoord:Point   = pos2Coord( bfMap, endPos );
			if( simplified && is_through(startCoord, endCoord, bfMap) ){
				path[0] = coord2Pos(bfMap, cossCoord[1]);
				path[1] = endPos;
				return path;
			}				
			
			// 用一维数组索引所有节点
			var maxPos:int = bfMap['mapGridX'] * bfMap['mapGridY'];
			var nodeList:Object = new Object();
			for( var idx:int = START_IDX; idx <= maxPos; idx++ )
				nodeList[idx] = new Object;
			
			// 初始化起点数据
			nodeList[startPos]['f']      = HESTIMATE;
			nodeList[startPos]['x']      = startCoord.x;
			nodeList[startPos]['y']      = startCoord.y;
			nodeList[startPos]['pos']    = startPos;
			nodeList[startPos]['ppos']   = startPos;
			nodeList[startPos]['status'] = OPEN_STAT;
			
			// open表
			var openList:Array = new Array();
			openList.push( nodeList[startPos] );
			
			var found:Boolean = false;
			var pathNodeCounter:int = 0;
			while( openList.length )
			{
				// 弹出第一个open节点
				var currentNode:Object = openList.shift();
				var currentPos:int = currentNode['pos'];
				
				//若该节点已关闭，则忽略
				if( currentNode['status'] == CLOSE_STAT )
					continue;
				
				// 如果已经到达终点，则结束寻路
				if( currentNode['pos'] == endPos )
				{
					currentNode['status'] = CLOSE_STAT;
					found = true;
					break;
				}
				
				// 达到搜索上限，则结束寻路
				if( pathNodeCounter > SEARCH_LIMIT )
					return path;

				// 获取子节点
				for( var i:int = 0; i < 8; i++ )
				{
					var childX:int  = currentNode['x'] + dirs[i]['dx'];
					var childY:int = currentNode['y'] + dirs[i]['dy'];
					
					if( childX > bfMap['mapGridX'] || childY > bfMap['mapGridY'] || childX < START_IDX || childY < START_IDX )
						continue;
					
					var childPos:int = coord2Pos( bfMap, new Point( childX, childY ) );
					
					// 若已经关闭，则忽略
					if( nodeList[childPos]['status'] == CLOSE_STAT )
						continue;
					
					//阻挡则跳过
					if( !isFly && isBlock( bfMap, childPos ) )
						continue;
					
					// 计算新的g值
					var g:int = 0;
					if( i > 3 )
					{
						if( !isFly )
						{
							// 步行斜移时，相邻的格子中任意一个有阻挡，则忽略
							var rb:int   = currentNode['x'] + dirs[i]['dx'];
							var rPos:int = coord2Pos( bfMap, new Point( rb, currentNode['y'] ) );
							var lb:int   = currentNode['y'] + dirs[i]['dy'];
							var lPos:int = coord2Pos( bfMap, new Point( currentNode['x'], lb ) );
							if( isBlock( bfMap, lPos ) && isBlock( bfMap, rPos ) )
								continue;
						}
						g = currentNode['g'] + 14;
					}
					else
						g = currentNode['g'] + 10;
					
					// 如果已在open列表，且新计算出的G值大于子节点的G值，则忽略
					if( nodeList[childPos]['status'] == OPEN_STAT && nodeList[childPos]['g'] <= g )
						continue;
					
					// 如果新计算的G值小于原先的G值，则记录该子节点，并将当前节点设置为他的父节点，并重新计算h值和f值
					var h:int = HESTIMATE * ( Math.abs( childX - endCoord.x ) + Math.abs( childY - endCoord.y ) );			
					nodeList[childPos]['g']      = g;
					nodeList[childPos]['f']      = g + h;
					nodeList[childPos]['x']      = childX;
					nodeList[childPos]['y']      = childY;
					nodeList[childPos]['pos']    = childPos;
					nodeList[childPos]['ppos']   = currentPos;					
					nodeList[childPos]['status'] = OPEN_STAT;
					
					// 添加到open列表
					openList.push( nodeList[childPos] );
				}
				// 重新按f值排序
				openList.sortOn("f", Array.NUMERIC );
				
				// 关闭当前节点
				pathNodeCounter++;
				nodeList[currentPos]['status'] = CLOSE_STAT;
			}
			
			// 从终点遍历所有祖先节点，得到路径  
			if(found)
			{
				var node:Object     = nodeList[endPos];
				var lastNode:Object = node;
				var lastDir:Array  = new Array(0, 0);
				while( node['pos'] != node['ppos'] )
				{
					if( keyPath )
					{
						var dx:int = node['x'] - lastNode['x'];
						var dy:int = node['y'] - lastNode['y'];
						var dir:Array = new Array( dx, dy );
						if( dir[0] != lastDir[0] || dir[1] != lastDir[1] )
						{
							lastDir = dir;
							path.push( lastNode['pos'] );
						}
						lastNode = node;
					}
					else
						path.push( node['pos'] );
					node = nodeList[node['ppos']];
				}
			}
			path = path.reverse();
			return path;
		}
		
		public static function getRealPath( startPos:int, endPos:int, bfMap:Object, simplified:Boolean=true ):Array
		{
			if( !isBlock( bfMap, endPos ) )
				return getPath(startPos, endPos, bfMap, false, false, simplified);
			
			// 寻找8个方向上的最近的非阻塞点
			var endP:Point = pos2Coord( bfMap, endPos );
			var nearPoint:Point = new Point(0,0);
			var minSteps:uint = 0xFFFFFFFF;
			var steps:uint = 0;
			for( var idx:int=0; idx < 8; idx++ )
			{
				var point:Point = new Point(endP.x, endP.y);
				var pos:int = coord2Pos( bfMap, point );
				steps = 0;
				while( isValid( bfMap, point ) && isBlock( bfMap, pos ) )
				{
					point.x += dirs[idx].dx;
					point.y += dirs[idx].dy;
					pos = coord2Pos( bfMap, point );
					steps++;
				}
				if( isValid( bfMap, point ) )
				{
					if( steps < minSteps )
					{
						nearPoint = point;
						minSteps  = steps;
					}
				}
			}
			if( isValid( bfMap, nearPoint ) )
			{
				var nearPos:int = coord2Pos( bfMap, nearPoint );
				return getPath(startPos, nearPos, bfMap, false, false, simplified);
			}
			return [];
		}
		
		/**
		 * @brief 获取两点间最小路径，在战场中使用
		 * @param 起始位置
		 * @param 结束位置	
		 * @param 地图阻挡信息
		 * @param 是否只返回关键路径
		 * @param 是否飞行寻路（地面阻挡无效，但是降落点不能阻挡）
		 */
		public static function getPathInBattlefield( startPos:int, endPos:int, bfMap:Object, 
										keyPath:Boolean=false, isFly:Boolean=false ):Array
		{
			bfMap['mapGridX'] = 15;
			bfMap['mapGridY'] = 8;
			
			var path:Array;
			
			path = getPath(startPos, endPos, bfMap, keyPath, isFly);
			
			return path;
		}
		
		/**
		 * @brief 根据移动速度获取可到达的位置范围
		 * @param 地图阻挡信息
		 * @param 起始位置
		 * @param 可移动的最大距离
		*/
		public static function getMoveRange( bfMap:Object, startPos:int, speed:int, isFly:Boolean=false ):Object
		{
			var allPos:Object = new Object();
			var maxPos:int = bfMap['mapGridX'] * bfMap['mapGridY'];
			
			// 先排除位置上有阻挡或者站人的点
			for( var idx:int = START_IDX; idx <= maxPos; idx++ )
			{
				if( !isBlock( bfMap, idx ) )
					allPos[idx] = 1;
			}
			
			// 遍历每个点
			var posMap:Object = new Object();
			for( var pos:* in allPos )
			{
				var path:Array = getPath( startPos, pos, bfMap, false, isFly );
				if( path.length != 0 )
				{
					for( var order:* in path )
					{
						var pathPos:* = path[order];
						if( order >= speed )
							delete allPos[pathPos];
						else
						{
							if( !isBlock( bfMap, pathPos ) )
								posMap[pathPos] = 1;
						}
					}
				}
			}
			
			return posMap;
		}
		
		public static function isAdjacent( bfMap:Object, startPos:int, targetPos:int ):Boolean
		{
			var coord:Point = pos2Coord( bfMap, targetPos );
			var adjacent:Point = new Point;
			for( var i:int = 0; i < 8; i++ )
			{
				adjacent.x = coord['x'] + dirs[i]['dx'];
				adjacent.y = coord['y'] + dirs[i]['dy'];
				var pos:int = PathFind.coord2Pos( bfMap, adjacent );
				if( pos == startPos )
					return true;
			}
			return false;
		}

		/**
		 * @brief 获取到达某个目标格子的相邻位置的最短路径
		 * @param 地图阻挡信息
		 * @param 起始位置
		 * @param  目标位置
		 * @param 可移动的最大距离
		*/
		public static function getPathToTarget( bfMap:Object, startPos:int, targetPos:int, speed:int, isFly:Boolean ):Array
		{
			var coord:Point = pos2Coord( bfMap, targetPos );
			var adjacent:Point = new Point();
			var adjacentPos:Array = new Array();
			for( var i:int = 0; i < 8; i++ )
			{
				adjacent.x = coord['x'] + dirs[i]['dx'];
				adjacent.y = coord['y'] + dirs[i]['dy'];				
				if( adjacent.x > bfMap['mapGridX'] || adjacent.y > bfMap['mapGridY'] 
					|| adjacent.x < START_IDX || adjacent.y < START_IDX )
					continue;
				var pos:int = PathFind.coord2Pos( bfMap, adjacent );
				if( PathFind.isBlock( bfMap, pos ) )
					continue;
				adjacentPos.push( pos );
			}
			
			var path:Array = new Array();
			if( adjacentPos.length == 0 )
				return path;
			
			if( !isFly )
			{
				var posData:* = bfMap['tiles'][targetPos];
				delete bfMap['tiles'][targetPos];
				path = getPath( startPos, targetPos, bfMap, false, isFly );
				bfMap['tiles'][targetPos] = posData;
				if( path.length != 0 )
					path.pop();
			}
			else
			{
				var minPathLen:int = 9999;
				for( var j:int=0; j < adjacentPos.length; j++ )
				{
					var aPos:int = adjacentPos[j];
					var aPath:Array = getPath( startPos, aPos, bfMap, false, isFly );
					if( aPath.length == 0 )
						continue;
					if( aPath.length > speed )
						continue;
					if( isBlock( bfMap, aPath[aPath.length-1] ) )
						continue;
					if( aPath.length < minPathLen )
					{
						minPathLen = aPath.length;
						path = aPath;
					}
				}
			}			
			return path;
		}
	}
}