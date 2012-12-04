package cc.walk
{
	import flash.utils.ByteArray;

	/**
	 * 路径转换
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class PathConverter
	{
        public static function convertToVector(p_arr:Array):ByteArray {
            var _local8:int;
            var _local2:ByteArray = new ByteArray();
            if (p_arr.length < 2){
                return (_local2);
            }
            _local2.writeShort(p_arr[0][0]);
            _local2.writeShort(p_arr[0][1]);
            var _local3:int = p_arr[0][0];
            var _local4:int = p_arr[0][1];
            var _local5:int = (p_arr.length - 1);
            _local2.writeByte(_local5);
            var _local6:int;
            var _local7:int;
            while (_local7 < _local5) {
                _local8 = getNextDirection(_local3, _local4, p_arr[(_local7 + 1)][0], p_arr[(_local7 + 1)][1]);
                _local3 = p_arr[(_local7 + 1)][0];
                _local4 = p_arr[(_local7 + 1)][1];
                if ((_local7 % 2) == 0){
                    _local6 = (_local8 << 4);
                } else {
                    _local6 = (_local6 | _local8);
                    _local2.writeByte(_local6);
                }
                _local7++;
            }
            if ((_local5 % 2) == 1){
                _local2.writeByte(_local6);
            }
            _local2.position = 0;
            return _local2;
        }
		
        public static function convertToPoint(_arg1:ByteArray):Array {
            var _local9:int;
            var _local10:int;
            var _local2:int = _arg1.readShort();
            var _local3:int = _arg1.readShort();
            var _local4:int = _arg1.readByte();
            var _local5:Array = new Array();
            _local5[0] = [_local2, _local3];
            var _local6:int = 1;
            var _local7:int = _local4 % 2 == 0 ? _local4 / 2 : _local4 / 2 + 1;
            var _local8:int;
            while (_local8 < _local7) {
                _local9 = _arg1.readByte();
                _local10 = ((_local9 & 240) >> 4);
                _local5[_local6] = [getNextDirectionX(_local2, _local10), getNextDirectionY(_local3, _local10)];
                _local2 = _local5[_local6][0];
                _local3 = _local5[_local6][1];
                _local6++;
                if (_local6 < (_local4 + 1)){
                    _local10 = (_local9 & 15);
                    _local5[_local6] = [getNextDirectionX(_local2, _local10), getNextDirectionY(_local3, _local10)];
                    _local2 = _local5[_local6][0];
                    _local3 = _local5[_local6][1];
                    _local6++;
                }
                _local8++;
            }
            return _local5;
        }
		
        private static function getNextDirectionX(_arg1:int, _arg2:int):int {
            if (_arg2 == 0 || _arg2 == 6 || _arg2 == 7) {
                return _arg1 - 1;
            }
            if (_arg2 == 1 || _arg2 == 5) {
                return _arg1;
            }
            if (_arg2 == 2 || _arg2 == 3 || _arg2 == 4) {
                return _arg1 + 1;
            }
            return -1;
        }
		
        private static function getNextDirection(_arg1:int, _arg2:int, _arg3:int, _arg4:int):int {
            if (_arg3 < _arg1) {
                if (_arg4 < _arg2) {
                    return 0;
                }
                if (_arg4 == _arg2) {
                    return 7;
                }
                return 6;
            }
            if (_arg3 == _arg1){
                if (_arg4 < _arg2){
                    return 1;
                }
                return 5;
            }
            if (_arg4 < _arg2){
                return 2;
            }
            if (_arg4 == _arg2){
                return 3;
            }
            return 4;
        }
		
        private static function getNextDirectionY(_arg1:int, _arg2:int):int {
            if (_arg2 == 0 || _arg2 == 1 || _arg2 == 2) {
                return _arg1 - 1;
            }
            if (_arg2 == 3 || _arg2 == 7) {
                return _arg1;
            }
            if (_arg2 == 4 || _arg2 == 5 || _arg2 == 6) {
                return _arg1 + 1;
            }
            return -1;
        }
    }
}