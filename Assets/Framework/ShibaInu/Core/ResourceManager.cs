using System;


namespace ShibaInu
{
	public class ResourceManager
	{




		private ResourceManager ()
		{
		}





		// static

		private static ResourceManager _instance;

		public static ResourceManager instance
		{
			get {
				if (_instance == null)
					_instance = new ResourceManager ();
				return _instance;
			}
		}


		//
	}
}

