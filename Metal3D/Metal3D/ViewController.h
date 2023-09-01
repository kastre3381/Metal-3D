#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AppKit/AppKit.h>


@interface ViewController : NSViewController<MTKViewDelegate>

@property (weak) IBOutlet NSSlider *m_RotationXSlider;
@property (weak) IBOutlet NSSlider *m_RotationYSlider;
@property (weak) IBOutlet NSSlider *m_RotationZSlider;
@property (weak) IBOutlet NSSlider *m_ScaleXSlider;
@property (weak) IBOutlet NSSlider *m_ScaleYSlider;
@property (weak) IBOutlet NSSlider *m_ScaleZSlider;

@property (nonatomic, strong) MTKView* metalView;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) MTLRenderPipelineDescriptor* pipelineDescriptor;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;


@end

