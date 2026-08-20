#import <ScreenSaver/ScreenSaver.h>

@interface GridClock : ScreenSaverView
{
    IBOutlet id configSheet;
    IBOutlet id screenDisplayOption;
    BOOL shouldDrawClock;
}
@end
