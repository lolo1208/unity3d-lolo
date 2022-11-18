//
// 设备相关工具类
// Created by LOLO on 2019/03/07.
//

#import "AudioToolbox/AudioServices.h"



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

