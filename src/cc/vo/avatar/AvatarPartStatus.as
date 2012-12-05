package cc.vo.avatar
{
    public class AvatarPartStatus
	{
		public var resourceType:String; // swf | sprite sheet 部位(身体/手) 的某个动作定义
        public var type:String;			// see AvatarPartType
        public var frame:int;
        public var delay:int;
        public var repeat:int;
		public var only1Angle:int;
        public var width:int;
        public var height:int;
        public var tx:int;				// 中心点, 在位图中的坐标
        public var ty:int;
        public var classNamePrefix:String;
		public var tClass:Class;
    }
}