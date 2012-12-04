package wit.net
{
	/**
	 * @author lei.zhang@kunlun-inc.com
	 */
	public class CSctHeader 
	{
		public static const SIZE:int     = 4;		
		public static const MAX_SIZE:int = 65536;
		public var m_size:int            = 0;
		public var m_isZip:int           = 0;
		
		public function is_valid():Boolean
		{
			if( m_size > MAX_SIZE || m_size < SIZE )
				return false;
			return true;
		} 
	} // class end
} // pack end
