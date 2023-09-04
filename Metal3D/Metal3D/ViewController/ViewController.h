#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AppKit/AppKit.h>
#import "IndexEnum.h"
#import <string>

typedef struct
{
    vector_float3 position;
    vector_float4 color;
} Vertex;

typedef struct
{
    vector_float3 firstRow;
    vector_float3 secondRow;
    vector_float3 thirdRow;
} Matrix3x3;



@interface ViewController : NSViewController<MTKViewDelegate>

@property (weak) IBOutlet NSSlider *m_RotationXSlider;
@property (weak) IBOutlet NSSlider *m_RotationYSlider;
@property (weak) IBOutlet NSSlider *m_RotationZSlider;
@property (weak) IBOutlet NSSlider *m_ScaleXSlider;
@property (weak) IBOutlet NSSlider *m_ScaleYSlider;
@property (weak) IBOutlet NSSlider *m_ScaleZSlider;
@property (weak) IBOutlet NSSlider *m_TransXSlider;
@property (weak) IBOutlet NSSlider *m_TransYSlider;
@property (weak) IBOutlet NSSlider *m_TransZSlider;
@property (weak) IBOutlet NSSlider *m_projLeft;
@property (weak) IBOutlet NSSlider *m_projRight;
@property (weak) IBOutlet NSSlider *m_projTop;
@property (weak) IBOutlet NSSlider *m_projNear;
@property (weak) IBOutlet NSSlider *m_projFar;
@property (weak) IBOutlet NSSlider *m_projBottom;


@property (weak) IBOutlet NSTextField *rotLeftTop;
@property (weak) IBOutlet NSTextField *rotLeftMid;
@property (weak) IBOutlet NSTextField *rotLeftBot;
@property (weak) IBOutlet NSTextField *rotMidTop;
@property (weak) IBOutlet NSTextField *rotMidMid;
@property (weak) IBOutlet NSTextField *rotMidBot;
@property (weak) IBOutlet NSTextField *rotRightTop;
@property (weak) IBOutlet NSTextField *rotRightMid;
@property (weak) IBOutlet NSTextField *rotRightBot;

@property (weak) IBOutlet NSTextField *scaleLeftTop;
@property (weak) IBOutlet NSTextField *scaleMidMid;
@property (weak) IBOutlet NSTextField *scaleRightBot;

@property (weak) IBOutlet NSTextField *transX;
@property (weak) IBOutlet NSTextField *transY;
@property (weak) IBOutlet NSTextField *transZ;

@property (weak) IBOutlet NSTextField *projLeftTop;
@property (weak) IBOutlet NSTextField *projMidLeftTop;
@property (weak) IBOutlet NSTextField *projMidRightTop;
@property (weak) IBOutlet NSTextField *projMidRightMid;
@property (weak) IBOutlet NSTextField *projMidRightBot;
@property (weak) IBOutlet NSTextField *projRightMidBot;


@property (nonatomic, strong) MTKView* metalView;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) MTLRenderPipelineDescriptor* pipelineDescriptor;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;

@property (nonatomic) BOOL isRotate;
@property (nonatomic) BOOL isTranslate;
@property (nonatomic) NSPoint lastMousePosition;
@end

