#import "UIKit/UIKit.h"
#import <AVFoundation/AVFoundation.h>

extern "C" {
    void PhoneUtility_setCanSleep(BOOL value);
    BOOL PhoneUtility_canSleep();
    float PhoneUtility_getVolumeValue();
    int PhoneUtility_getLocalTimeOffset();
}

void PhoneUtility_setCanSleep(BOOL value)
{
    [UIApplication sharedApplication].idleTimerDisabled = !value;
}

BOOL PhoneUtility_canSleep()
{
    return ![UIApplication sharedApplication].idleTimerDisabled;
}

float PhoneUtility_getVolumeValue() {
    return [[AVAudioSession sharedInstance] outputVolume];
}

int PhoneUtility_getLocalTimeOffset() {
    return [[NSTimeZone localTimeZone] secondsFromGMT];
}
