#import "GridClock.h"

static NSString * const gridClockModule = @"com.chrstphrknwtn.grid-clock";

static NSString * const gridClockRows[] = {
    @"onetwothreefours", @"atfivesixsevenbe", @"eightninetensoon",
    @"eleventwelvehalf", @"quarterminutesto", @"twentythirteenat",
    @"fourteenfifteens", @"pasttosixteenckn", @"seventeentwentya",
    @"eighteennineteen", @"thirtyfortyfifty", @"oclockonetwomoon",
    @"threefourfivesix", @"seveneightnineio", @"teneleventwelves"
};

static const NSInteger gridClockPrefixStarts[] = { -1, 0, 3, 6, 11, 18, 22, 25, 32, 37, 41, 48, 54 };
static const NSInteger gridClockPrefixLengths[] = { 0, 3, 3, 5, 4, 4, 3, 5, 5, 4, 3, 6, 6 };
static const NSInteger gridClockSuffixStarts[] = { -1, 182, 185, 192, 197, 201, 205, 208, 213, 218, 224, 227, 233 };

static void GridClockSetRange(BOOL *lit, NSInteger start, NSInteger length) {
    for (NSInteger index = start; index < start + length; index++) {
        lit[index] = YES;
    }
}

static void GridClockSetPrefix(BOOL *lit, NSInteger number) {
    GridClockSetRange(lit, gridClockPrefixStarts[number], gridClockPrefixLengths[number]);
}

static void GridClockSetSuffix(BOOL *lit, NSInteger number) {
    if (number == 13) number = 1;
    GridClockSetRange(lit, gridClockSuffixStarts[number], gridClockPrefixLengths[number]);
}

static void GridClockLightCurrentTime(BOOL *lit) {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
    NSInteger hour = components.hour;
    NSInteger minutes = components.minute;

    if (hour >= 13) hour -= 12;
    if (hour == 0) hour = 12;

    if (minutes == 1) {
        GridClockSetRange(lit, 0, 3);       // one
        GridClockSetRange(lit, 71, 6);      // minute
        GridClockSetRange(lit, 112, 4);     // past
        GridClockSetSuffix(lit, hour);
        return;
    }

    if (minutes >= 2 && minutes <= 12) {
        GridClockSetPrefix(lit, minutes);
        GridClockSetRange(lit, 71, 7);      // minutes
        GridClockSetRange(lit, 112, 4);     // past
        GridClockSetSuffix(lit, hour);
        return;
    }

    switch (minutes) {
        case 0:  GridClockSetPrefix(lit, hour); GridClockSetRange(lit, 176, 6); return; // o'clock
        case 13: GridClockSetPrefix(lit, hour); GridClockSetRange(lit, 86, 8); return;
        case 14: GridClockSetPrefix(lit, hour); GridClockSetRange(lit, 96, 8); return;
        case 15: GridClockSetRange(lit, 64, 7); GridClockSetRange(lit, 112, 4); GridClockSetSuffix(lit, hour); return;
        case 16: GridClockSetPrefix(lit, hour); GridClockSetRange(lit, 118, 7); return;
        case 17: GridClockSetPrefix(lit, hour); GridClockSetRange(lit, 128, 9); return;
        case 18: GridClockSetPrefix(lit, hour); GridClockSetRange(lit, 144, 8); return;
        case 19: GridClockSetPrefix(lit, hour); GridClockSetRange(lit, 152, 8); return;
        case 20: GridClockSetRange(lit, 80, 6); GridClockSetRange(lit, 112, 4); GridClockSetSuffix(lit, hour); return;
        case 30: GridClockSetRange(lit, 60, 4); GridClockSetRange(lit, 112, 4); GridClockSetSuffix(lit, hour); return;
        case 40: GridClockSetRange(lit, 80, 6); GridClockSetRange(lit, 116, 2); GridClockSetSuffix(lit, hour + 1); return;
        case 45: GridClockSetRange(lit, 64, 7); GridClockSetRange(lit, 116, 2); GridClockSetSuffix(lit, hour + 1); return;
        case 50: GridClockSetRange(lit, 41, 3); GridClockSetRange(lit, 116, 2); GridClockSetSuffix(lit, hour + 1); return;
        case 55: GridClockSetRange(lit, 18, 4); GridClockSetRange(lit, 116, 2); GridClockSetSuffix(lit, hour + 1); return;
        default:
            GridClockSetPrefix(lit, hour);
            if (minutes / 10 == 2) GridClockSetRange(lit, 137, 6);
            if (minutes / 10 == 3) GridClockSetRange(lit, 160, 6);
            if (minutes / 10 == 4) GridClockSetRange(lit, 166, 5);
            if (minutes / 10 == 5) GridClockSetRange(lit, 171, 5);
            if (minutes % 10 != 0) GridClockSetSuffix(lit, minutes % 10);
    }
}

@implementation GridClock

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    if (!(self = [super initWithFrame:frame isPreview:isPreview])) return nil;

    // ScreenSaverView owns the refresh timer. Unlike WebView timers, it is
    // supported by the screen saver host on current macOS releases.
    self.animationTimeInterval = 1.0;
    
    // Preference Defaults
    ScreenSaverDefaults *defaults;
    defaults = [ScreenSaverDefaults defaultsForModuleWithName:gridClockModule];
    
    [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
        @"0", @"screenDisplayOption", // Default to show only on primary display
        nil]];
    
    // Show on screens based on preferences
    NSArray* screens = [NSScreen screens];
    NSScreen* primaryScreen = [screens objectAtIndex:0];
    
    switch ([defaults integerForKey:@"screenDisplayOption"]) {
        // Primary screen (System Preferences > Displays).
        // The screen the menubar is shown on under 'arrangement'
        case 0:
            shouldDrawClock = (primaryScreen.frame.origin.x == frame.origin.x) || isPreview;
            break;
        // Last Focussed Screen
        // This _sometimes_ results in nothing being shown when previewing in system prefs.
        case 1:
            shouldDrawClock = ([NSScreen mainScreen].frame.origin.x == frame.origin.x) || isPreview;
            break;
        // All Screens
        case 2:
            shouldDrawClock = YES;
            break;
        default:
            shouldDrawClock = YES;
            break;
    }

    return self;
}

#pragma mark - ScreenSaverView

- (void)animateOneFrame {
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor blackColor] setFill];
    NSRectFill(self.bounds);
    if (!shouldDrawClock) return;

    BOOL lit[240] = { NO };
    GridClockLightCurrentTime(lit);

    CGFloat side = MIN(self.bounds.size.width, self.bounds.size.height) * 0.92;
    CGFloat cellSize = side / 16.0;
    CGFloat originX = NSMidX(self.bounds) - side / 2.0;
    CGFloat originY = NSMidY(self.bounds) - side / 2.0;
    NSFont *font = [NSFont systemFontOfSize:cellSize * 0.45 weight:NSFontWeightLight];
    NSColor *offColor = [NSColor colorWithCalibratedWhite:0.13 alpha:1.0];

    for (NSInteger row = 0; row < 15; row++) {
        NSString *letters = gridClockRows[row];
        for (NSInteger column = 0; column < 16; column++) {
            NSInteger index = row * 16 + column;
            NSColor *color = lit[index] ? [NSColor whiteColor] : offColor;
            NSDictionary *attributes = @{ NSFontAttributeName: font, NSForegroundColorAttributeName: color };
            NSString *letter = [letters substringWithRange:NSMakeRange(column, 1)];
            NSSize textSize = [letter sizeWithAttributes:attributes];
            CGFloat x = originX + column * cellSize + (cellSize - textSize.width) / 2.0;
            CGFloat y = originY + (15 - row) * cellSize + (cellSize - textSize.height) / 2.0;
            [letter.uppercaseString drawAtPoint:NSMakePoint(x, y) withAttributes:attributes];
        }
    }
}

#pragma mark - Config
// http://cocoadevcentral.com/articles/000088.php

- (BOOL)hasConfigureSheet { return YES; }

- (NSWindow *)configureSheet
{
    ScreenSaverDefaults *defaults;
    defaults = [ScreenSaverDefaults defaultsForModuleWithName:gridClockModule];
    
    if (!configSheet)
    {
        if (![NSBundle loadNibNamed:@"ConfigureSheet" owner:self])
        {
            NSLog( @"Failed to load configure sheet." );
        }
    }
    
    [screenDisplayOption selectItemAtIndex:[defaults integerForKey:@"screenDisplayOption"]];

    return configSheet;
}

- (IBAction)cancelClick:(id)sender
{
    [[NSApplication sharedApplication] endSheet:configSheet];
}

- (IBAction) okClick: (id)sender
{
    ScreenSaverDefaults *defaults;
    defaults = [ScreenSaverDefaults defaultsForModuleWithName:gridClockModule];
    
    // Update our defaults
    [defaults setInteger:[screenDisplayOption indexOfSelectedItem]
               forKey:@"screenDisplayOption"];
    
    // Save the settings to disk
    [defaults synchronize];
    
    // Close the sheet
    [[NSApplication sharedApplication] endSheet:configSheet];
}

#pragma mark Focus Overrides

- (NSView *)hitTest:(NSPoint)aPoint {return self;}
//- (void)keyDown:(NSEvent *)theEvent {return;}
//- (void)keyUp:(NSEvent *)theEvent {return;}
- (void)mouseDown:(NSEvent *)theEvent {return;}
- (void)mouseUp:(NSEvent *)theEvent {return;}
- (void)mouseDragged:(NSEvent *)theEvent {return;}
- (void)mouseEntered:(NSEvent *)theEvent {return;}
- (void)mouseExited:(NSEvent *)theEvent {return;}
- (BOOL)acceptsFirstResponder {return YES;}
- (BOOL)resignFirstResponder {return NO;}

@end
