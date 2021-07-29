using System;

public partial class SROptions
{
    // For compatibility with older versions of SRDebugger, this simply inherits from the component model version.

    [AttributeUsage(AttributeTargets.Property | AttributeTargets.Method)]
    public sealed class DisplayNameAttribute : System.ComponentModel.DisplayNameAttribute
    {
        public DisplayNameAttribute(string displayName) : base(displayName)
        {
        }
    }

    // These attributes are used when using SROptions. Options added via SRDebug.Instance.AddOptionsContainer can use the attribute defined in SRDebugger namespace.

    [AttributeUsage(AttributeTargets.Property)]
    public sealed class IncrementAttribute : SRDebugger.IncrementAttribute {
        public IncrementAttribute(double increment) : base(increment)
        {
        }
    }

    [AttributeUsage(AttributeTargets.Property)]
    public sealed class NumberRangeAttribute : SRDebugger.NumberRangeAttribute
    {
        public NumberRangeAttribute(double min, double max) : base(min, max)
        {
        }
    }
    
    [AttributeUsage(AttributeTargets.Property | AttributeTargets.Method)]
    public sealed class SortAttribute : SRDebugger.SortAttribute
    {
        public SortAttribute(int priority) : base(priority)
        {
        }
    }
}