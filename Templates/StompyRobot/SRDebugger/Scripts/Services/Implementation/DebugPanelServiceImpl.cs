namespace SRDebugger.Services.Implementation
{
    using System;
    using Internal;
    using SRF;
    using SRF.Service;
    using UI;
    using UnityEngine;

    [Service(typeof (IDebugPanelService))]
    public class DebugPanelServiceImpl : ScriptableObject, IDebugPanelService
    {
        private DebugPanelRoot _debugPanelRootObject;
        public event Action<IDebugPanelService, bool> VisibilityChanged;

        private bool _isVisible;

        private bool? _cursorWasVisible;
#if UNITY_4_7
        private bool? _cursorWasLocked;
#else
        private CursorLockMode? _cursorLockMode;
#endif

        public DebugPanelRoot RootObject
        {
            get { return _debugPanelRootObject; }
        }

        public bool IsLoaded
        {
            get { return _debugPanelRootObject != null; }
        }

        public bool IsVisible
        {
            get { return IsLoaded && _isVisible; }
            set
            {
                if (_isVisible == value)
                {
                    return;
                }

                if (value)
                {
                    if (!IsLoaded)
                    {
                        Load();
                    }

                    SRDebuggerUtil.EnsureEventSystemExists();

                    _debugPanelRootObject.CanvasGroup.alpha = 1.0f;
                    _debugPanelRootObject.CanvasGroup.interactable = true;
                    _debugPanelRootObject.CanvasGroup.blocksRaycasts = true;
#if !UNITY_4_7
                    _cursorWasVisible = Cursor.visible;
                    _cursorLockMode = Cursor.lockState;
#else
					_cursorWasVisible = Screen.showCursor;
                    _cursorWasLocked = Screen.lockCursor;
#endif
                    if (Settings.Instance.AutomaticallyShowCursor)
                    {
#if !UNITY_4_7
                        Cursor.visible = true;
                        Cursor.lockState = CursorLockMode.None;
#else
                        Screen.showCursor = true;
                        Screen.lockCursor = false;
#endif
                    }
                }
                else
                {
                    if (IsLoaded)
                    {
                        _debugPanelRootObject.CanvasGroup.alpha = 0.0f;
                        _debugPanelRootObject.CanvasGroup.interactable = false;
                        _debugPanelRootObject.CanvasGroup.blocksRaycasts = false;
                    }

#if UNITY_4_7
                    if (_cursorWasVisible.HasValue)
                    {
                        Screen.showCursor = _cursorWasVisible.Value;
                        _cursorWasVisible = null;
                    }
                    if (_cursorWasLocked.HasValue)
                    {
                        Screen.lockCursor = _cursorWasLocked.Value;
                        _cursorWasLocked = null;
                    }
#else
                    if (_cursorWasVisible.HasValue)
                    {
                        Cursor.visible = _cursorWasVisible.Value;
                        _cursorWasVisible = null;
                    }
                    if (_cursorLockMode.HasValue)
                    {
                        Cursor.lockState = _cursorLockMode.Value;
                        _cursorLockMode = null;
                    }
#endif
                }

                _isVisible = value;

                if (VisibilityChanged != null)
                {
                    VisibilityChanged(this, _isVisible);
                }
            }
        }

        public DefaultTabs? ActiveTab
        {
            get
            {
                if (_debugPanelRootObject == null)
                {
                    return null;
                }

                return _debugPanelRootObject.TabController.ActiveTab;
            }
        }

        public void OpenTab(DefaultTabs tab)
        {
            if (!IsVisible)
            {
                IsVisible = true;
            }

            _debugPanelRootObject.TabController.OpenTab(tab);
        }

        public void Unload()
        {
            if (_debugPanelRootObject == null)
            {
                return;
            }

            IsVisible = false;

            _debugPanelRootObject.CachedGameObject.SetActive(false);
            Destroy(_debugPanelRootObject.CachedGameObject);

            _debugPanelRootObject = null;
        }

        private void Load()
        {
            var prefab = Resources.Load<DebugPanelRoot>(SRDebugPaths.DebugPanelPrefabPath);

            if (prefab == null)
            {
                Debug.LogError("[SRDebugger] Error loading debug panel prefab");
                return;
            }

            _debugPanelRootObject = SRInstantiate.Instantiate(prefab);
            _debugPanelRootObject.name = "Panel";

            DontDestroyOnLoad(_debugPanelRootObject);

            _debugPanelRootObject.CachedTransform.SetParent(Hierarchy.Get("SRDebugger"), true);

            SRDebuggerUtil.EnsureEventSystemExists();
        }
    }
}
