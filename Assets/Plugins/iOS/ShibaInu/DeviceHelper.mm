#include "UnityAppController.h"
#include "UI/UnityView.h"
#include "UIKit/UIFeedbackGenerator.h"
#include "AudioToolbox/AudioServices.h"



extern "C" bool IsNotchScreenImpl()
{
    if (@available(iOS 11.0, *)) {
        UIView *view = GetAppController().unityView;
        return !UIEdgeInsetsEqualToEdgeInsets(view.safeAreaInsets, UIEdgeInsetsZero);
    }
    return false;
}


extern "C" void GetSafeInsetsImpl(float* top, float* bottom, float* left, float* right)
{
    UIView *view = GetAppController().unityView;
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


extern "C" void VibrateImpl(int style)
{
    if (@available(iOS 10.0, *)) {
        UIImpactFeedbackStyle s;
        switch (style) {
            case 1:
                s = UIImpactFeedbackStyleLight;
                break;
            case 2:
                s = UIImpactFeedbackStyleMedium;
                break;
            case 3:
                s = UIImpactFeedbackStyleHeavy;
                break;
        }
        UIImpactFeedbackGenerator *impactFeedBack = [[UIImpactFeedbackGenerator alloc] initWithStyle:s];
        [impactFeedBack impactOccurred];
    }
    else {
        switch (style) {
            case 1:
                AudioServicesPlaySystemSound(1519);
                break;
            case 2:
                AudioServicesPlaySystemSound(1520);
                break;
            case 3:
                AudioServicesPlaySystemSound(1521);
                break;
        }
    }
}

