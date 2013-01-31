package cc.vo.avatar
{
    public class AvatarPartData
	{
        public var angle:int;
        public var frame:int;
        public var sx:int;
        public var sy:int;
        public var width:int;
        public var height:int;
        public var tx:int;
        public var ty:int;

        public function AvatarPartData(p_partData:XML) {
            this.angle = p_partData.@a;
            this.frame = p_partData.@f;
            this.sx = p_partData.@sx; // scale
            this.sy = p_partData.@sy;
            this.width = p_partData.@w;
            this.height = p_partData.@h;
            this.tx = (parseInt(p_partData.@tx) + parseInt(p_partData.@ox));
            this.ty = (parseInt(p_partData.@ty) + parseInt(p_partData.@oy));
        }
    }
}