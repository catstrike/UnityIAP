using System.Runtime.InteropServices;
using System.Collections.Generic;
using System;
using AOT;
using Plugins.StoreCommon;

#if UNITY_ANDROID && !UNITY_EDITOR
namespace Plugins.StoreKitPlugin
{   
    public class StoreKitBridge 
    {


#region - Events

#endregion



#region - Public Methods
        public static void init()
        {
        }
        
        public static void validateProductIdentifiers(IList<string> ids, Action<IList<StoreProduct>> onDone, Action<string> onError)
        {
            onDone(new List<StoreProduct>());
        }
        
        public static void purchaseProduct(string productId)
        {
        }
        
        public static void finishTransaction(string transactionId)
        {
        }


#endregion
    }
}
#endif