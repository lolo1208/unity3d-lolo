using System.ComponentModel;
using SRDebugger.Internal;
using SRF.Service;
using UnityEngine;

public delegate void SROptionsPropertyChanged(object sender, string propertyName);

public partial class SROptions : INotifyPropertyChanged
{
    private static readonly SROptions _current = new SROptions();

    public static SROptions Current
    {
        get { return _current; }
    }

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
    public static void OnStartup()
    {
        SRServiceManager.GetService<InternalOptionsRegistry>().AddOptionContainer(Current);
    }

    public event SROptionsPropertyChanged PropertyChanged;
    
#if UNITY_EDITOR
    [JetBrains.Annotations.NotifyPropertyChangedInvocator]
#endif
    public void OnPropertyChanged(string propertyName)
    {
        if (PropertyChanged != null)
        {
            PropertyChanged(this, propertyName);
        }

        if (InterfacePropertyChangedEventHandler != null)
        {
            InterfacePropertyChangedEventHandler(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    private event PropertyChangedEventHandler InterfacePropertyChangedEventHandler;

    event PropertyChangedEventHandler INotifyPropertyChanged.PropertyChanged
    {
        add { InterfacePropertyChangedEventHandler += value; }
        remove { InterfacePropertyChangedEventHandler -= value; }
    }
}
