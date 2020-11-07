using System;
using System.ComponentModel;
using UnityEngine.UI;

namespace SRDebugger.UI.Other
{
    using Internal;
    using SRF;
    using UnityEngine;

    [RequireComponent(typeof (Canvas))]
    public class ConfigureCanvasFromSettings : SRMonoBehaviour
    {
        private Canvas _canvas;
        private CanvasScaler _canvasScaler;

        private float _originalScale;
        private float _lastSetScale;

        private void Start()
        {
            _canvas = GetComponent<Canvas>();
            _canvasScaler = GetComponent<CanvasScaler>();

            SRDebuggerUtil.ConfigureCanvas(_canvas);

            _originalScale = _canvasScaler.scaleFactor;
            _canvasScaler.scaleFactor = _originalScale * SRDebug.Instance.Settings.UIScale;

            // Track the last set scale in case it is modified by the retina scaler.
            _lastSetScale = _canvasScaler.scaleFactor;

            SRDebug.Instance.Settings.PropertyChanged += SettingsOnPropertyChanged;
        }

        private void SettingsOnPropertyChanged(object sender, PropertyChangedEventArgs propertyChangedEventArgs)
        {
            // If the last set scale does not match the current scale factor, then it is likely the retina scaler has applied a change.
            // Treat the new value as the original scale.
            if (_canvasScaler.scaleFactor != _lastSetScale) _originalScale = _canvasScaler.scaleFactor;

            _canvasScaler.scaleFactor = _originalScale * SRDebug.Instance.Settings.UIScale;
            _lastSetScale = _canvasScaler.scaleFactor;
        }
    }
}
