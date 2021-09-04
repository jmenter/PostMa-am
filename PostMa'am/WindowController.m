
#import "WindowController.h"

@implementation WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    if (!self.window.zoomed) {
        [self.window zoom:self];
    }
}

@end
