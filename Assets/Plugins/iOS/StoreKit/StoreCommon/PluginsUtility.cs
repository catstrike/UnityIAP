using System;
using System.Runtime.InteropServices;

namespace Plugins
{
	public static class PluginsUtility
	{
		public static T[] marshalArray<T>(IntPtr source, int length) where T: new()
		{
			if (source == IntPtr.Zero || length == 0) {
				return new T[0];
			}

			var array = new T[length];
			var structSize = Marshal.SizeOf(typeof(T));
			
			for (int i = 0; i < length; i++) {
				var offset = structSize * i;
				array[i] = (T)Marshal.PtrToStructure(new IntPtr(source.ToInt64() + offset), typeof(T));
			}

			return array;
		}
	}
}
