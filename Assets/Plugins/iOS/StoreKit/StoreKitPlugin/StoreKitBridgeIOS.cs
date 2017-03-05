using System.Runtime.InteropServices;
using System.Collections.Generic;
using System;
using AOT;
using Plugins.StoreCommon;

#if UNITY_IOS // && !UNITY_EDITOR
namespace Plugins.StoreKitPlugin
{	
	public class StoreKitBridge 
	{
		#region - Types
		class Callback {
			public Action<IList<StoreProduct>> onProducts;
			public Action<string> onError;
		}
		
		delegate void ProductsCallback(int tag, IntPtr productInterop, int count);
		delegate void TransactionStatePurchasedCallback(string transactionId, string productId, string receipt);
		delegate void TransactionStateErrorCallback(string transactionId, string productId, string error);
		#endregion
		
		#region - Events
		public static event Action<string, string, string> onPurchased;
		public static event Action<string, string, string> onError;
		#endregion
		
		#region - State
		static Dictionary<int, Callback> _callbacks = new Dictionary<int, Callback>();
		static int _tag;
        static bool _initialized;
		#endregion
		
		#region - Interop
		[DllImport("__Internal")]
		static extern void storeKit_validateProductIdentifiers(int tag, string[] ids, int count, ProductsCallback onDone);
		
		[DllImport("__Internal")]
		static extern void storeKit_purchase(string productId);
		
		[DllImport("__Internal")]
		static extern void storeKit_finishTransaction(string transactionId);
		
		[DllImport("__Internal")]
		static extern void storeKit_setTransactionStatePurchasedCallback(TransactionStatePurchasedCallback callback);

		[DllImport("__Internal")]
		static extern void storeKit_setTransactionStateErrorCallback(TransactionStateErrorCallback callback);

		[DllImport("__Internal")]
		static extern void storeKit_triggerUnfinishedTransactions();
		
		[MonoPInvokeCallback(typeof(ProductsCallback))]
		static void validateProductIdentifiersCallbackHandler(int tag, IntPtr productInteropArray, int count)
		{	
			var products = PluginsUtility.marshalArray<StoreProduct>(productInteropArray, count);
			
			var callback = popCallback(tag);
			
			if (callback == null) {
				UnityEngine.Debug.LogError("[StoreKitBridge] Internal error!");
				return;
			}
			
			callback.onProducts(products);
		}
		
		[MonoPInvokeCallback(typeof(TransactionStatePurchasedCallback))]
		static void transactionStatePurchasedCallback(string transactionId, string productId, string receipt)
		{
			if (onPurchased != null) {
				onPurchased(transactionId, productId, receipt);
			}
		}
		
		[MonoPInvokeCallback(typeof(TransactionStateErrorCallback))]
		static void transactionStateErrorCallback(string transactionId, string productId, string error)
		{
			if (onError != null) {
				onError(transactionId, productId, error);
			}
		}
		#endregion
		
		#region - Public Methods
		public static void init()
		{
            if (_initialized) {
                return;
            }
            
            storeKit_setTransactionStatePurchasedCallback(transactionStatePurchasedCallback);
            storeKit_setTransactionStateErrorCallback(transactionStateErrorCallback);

            _initialized = true;
		}
		
		public static void validateProductIdentifiers(IList<string> ids, Action<IList<StoreProduct>> onDone, Action<string> onError)
		{
			var idsArray = new string[ids.Count];
			ids.CopyTo(idsArray, 0);
			
			var tag = setCallback(new Callback {
				onError = onError,
				onProducts = onDone
			});
			
			storeKit_validateProductIdentifiers(tag, idsArray, count:idsArray.Length,
														      onDone:validateProductIdentifiersCallbackHandler);
		}
		
		public static void purchaseProduct(string productId)
		{
			storeKit_purchase(productId);
		}
		
		public static void finishTransaction(string transactionId)
		{
			storeKit_finishTransaction(transactionId);
		}

		public static void triggerUnfinishedTransactions()
		{
			storeKit_triggerUnfinishedTransactions();
		}
		#endregion
		
		#region - Message System
		static int setCallback(Callback callback)
		{
			_tag += 1;
			_callbacks.Add(_tag, callback);
			
			return _tag;
		}
		
		static Callback popCallback(int tag)
		{
			Callback result;
			
			if (!_callbacks.TryGetValue(tag, out result)) {
				return default(Callback);
			}
			
			_callbacks.Remove(tag);
			return result;
		}
		#endregion
	}
}
#endif