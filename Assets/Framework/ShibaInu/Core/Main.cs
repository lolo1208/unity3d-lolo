using UnityEngine;


namespace ShibaInu
{
    public class Main : MonoBehaviour
    {
        private static bool s_initialized = false;


        void Awake()
        {
            if (!s_initialized)
            {
                s_initialized = true;

                Common.go = new GameObject(Constants.GameObjectName);
                DontDestroyOnLoad(Common.go);
                Common.go.AddComponent<Launcher>();
            }

            Destroy(this.gameObject);
        }


    }
}

