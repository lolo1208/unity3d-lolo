#include "UnityAppController.h"
#include "UI/UnityView.h"


extern "C" bool IsNotchScreenImpl()
{
    if (@available(iOS 11.0, *)) {
        UIView* view = GetAppController().unityView;
        return !UIEdgeInsetsEqualToEdgeInsets(view.safeAreaInsets, UIEdgeInsetsZero);
    }
    return false;
}


extern "C" void GetSafeInsetsImpl(float* top, float* bottom, float* left, float* right)
{
    UIView* view = GetAppController().unityView;
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);
    if (@available(iOS 11.0, *))
        if ([view respondsToSelector: @selector(safeAreaInsets)])
            insets = [view safeAreaInsets];
    float scale = view.contentScaleFactor;
    *top = insets.top * scale;
    *bottom = insets.bottom * scale;
    *left = insets.left * scale;
    *right = insets.right * scale;
}
