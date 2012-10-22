/*
   Tests For GPUToneCurveFilter
*/

#import "GPUToneCurveFilterTest.h"


@implementation GPUToneCurveFilterTest




/*
   List of curves we use for the tests
*/
static NSDictionary * horizontal128Curve;
static NSDictionary * horizontal200Curve;

-(void) setUp {
  horizontal128Curve = @{ @"name"   : @"Horizontal-128-curve",
                          @"points" : @[[NSValue valueWithCGPoint:CGPointMake(0.0,   128.0/255.0)],
                                        [NSValue valueWithCGPoint:CGPointMake(255.0, 128.0/255.0)]]
                        };
  
  horizontal200Curve = @{ @"name"   : @"Horizontal-128-curve",
                          @"points" : @[[NSValue valueWithCGPoint:CGPointMake(0.0,   200.0/255.0)],
                                        [NSValue valueWithCGPoint:CGPointMake(255.0, 200.0/255.0)]]
                       };
}


-(void) setUpTestWithSelector:(SEL)testMethod {
  [super setUpTestWithSelector:testMethod];
  redPoints = nil;
  greenPoints = nil;
  bluePoints = nil;
  rgbCompositePoints = nil;
}




-(void) performFilterTestWithInput:(u_char *)pixel expected:(u_char *)expectedOutput {
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8,  4, colorSpace, kCGImageAlphaPremultipliedLast);
  CGImageRef input_img = CGBitmapContextCreateImage(context);
  CFRelease(colorSpace);
  CFRelease(context);
  
  NSArray *red = [redPoints objectForKey:@"points"];
  NSArray *green = [greenPoints objectForKey:@"points"];
  NSArray *blue = [bluePoints objectForKey:@"points"];
  NSArray *composite = [rgbCompositePoints objectForKey:@"points"];
  
  NSArray *redName = [redPoints objectForKey:@"name"];
  NSArray *greenName = [greenPoints objectForKey:@"name"];
  NSArray *blueName = [bluePoints objectForKey:@"name"];
  NSArray *compositeName = [rgbCompositePoints objectForKey:@"name"];
  
  
  GPUImageToneCurveFilter *filter = [[GPUImageToneCurveFilter alloc] init];
  if (red) {
    [filter setRedControlPoints:red];
  }
  if (green) {
    [filter setGreenControlPoints:green];
  }
  if (blue) {
    [filter setBlueControlPoints:blue];
  }
  if (composite) {
    [filter setRgbCompositeControlPoints:composite];
  }
  
  CGImageRef output_img = [filter newCGImageByFilteringCGImage:input_img];
  CFRelease(input_img);
  CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(output_img));
  const u_char * out_pixel =  CFDataGetBytePtr(data);
  CFRelease(output_img);
  CFRelease(data);
  
  NSString *secenerio = @"Given ";
  secenerio = [secenerio stringByAppendingFormat:@"a '%@' curve is applied to the red channel, ",redName];
  secenerio = [secenerio stringByAppendingFormat:@"a '%@' curve is applied to the green channel, ",greenName];
  secenerio = [secenerio stringByAppendingFormat:@"a '%@' curve is applied to the blue channel, ",blueName];
  secenerio = [secenerio stringByAppendingFormat:@"and a '%@' curve is applied to the rgb-composite channel:  ",compositeName];
  
  NSString *redTest =   [NSString stringWithFormat:@"%@ Then The Output Value on the red channel should be %d. The actual output was %d",secenerio, (int)expectedOutput[0], (int)out_pixel[0]];
  NSString *greenTest = [NSString stringWithFormat:@"%@ Then The Output Value on the green channel should be %d. The actual output was %d",secenerio, (int)expectedOutput[0],(int)out_pixel[1]];
  NSString *blueTest =  [NSString stringWithFormat:@"%@ Then The Output Value on the blue channel should be %d. The actual output was %d",secenerio, (int)expectedOutput[0],(int)out_pixel[2]];
  
  STAssertTrue(out_pixel[0] == expectedOutput[0], redTest);
  STAssertTrue(out_pixel[1] == expectedOutput[1], greenTest);
  STAssertTrue(out_pixel[2] == expectedOutput[2], blueTest);
}









/*
   Actual tests start here:
*/

#define set_input u_char input[] =
#define set_expected u_char expected[] =
#define run_test [self performFilterTestWithInput:input expected:expected];

- (void)testRedChannelHorizontal128 {
  redPoints = horizontal128Curve;
  set_input    {255,255,255};
  set_expected {128,255,255};
  run_test
}


- (void)testGreenChannelHorizontal128 {
  greenPoints = horizontal128Curve;
  set_input {255,255,255};
  set_expected {255,128,255};
  run_test
}


- (void)testBlueChannelHorizontal128 {
  set_input {255,255,255};
  set_expected {255,255,128};
  bluePoints = horizontal128Curve;
  run_test
}


- (void)testRGBCompositeChannelHorizontal128 {
  set_input {255,255,255};
  set_expected {128,128,128};
  rgbCompositePoints = horizontal128Curve;
  run_test
}


-(void) testDefaultCurve {
  set_input {255,255,255};
  set_expected {255,255,255};
  run_test
}

- (void)testRGBCompositeChannelHorizontal200 {
  set_input {255,255,255};
  set_expected {200,200,200};
  rgbCompositePoints = horizontal200Curve;
  run_test
}


/* Set a horizontal curve at 128 output on the red channel,
   and another horizontal curve at the 200 output on the rgb composite channel.
   the output should be 200 across the board.
*/
- (void)testRedHorizontal128CompositeHorizontail200 {
  set_input {255,255,255};
  set_expected {200,200,200};
  redPoints = horizontal128Curve;
  rgbCompositePoints = horizontal200Curve;
  run_test
}



@end
