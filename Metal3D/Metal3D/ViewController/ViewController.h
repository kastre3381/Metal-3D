#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#import <QuartzCore/QuartzCore.h>
#import <AppKit/AppKit.h>
#import "IndexEnum.h"
#import <string>
#import <vector>

typedef struct
{
    vector_float3 position;
    vector_float3 normals;
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
@property (nonatomic, strong) id<MTLBuffer> vertexBufferCube;
@property (nonatomic, strong) id<MTLBuffer> vertexBufferCubeBlack;
@property (nonatomic, strong) id<MTLBuffer> vertexBufferSphere;
@property (nonatomic, strong) id<MTLBuffer> vertexBufferSphereBlack;
@property (nonatomic, strong) id<MTLBuffer> vertexBufferPlane;
@property (nonatomic, strong) id<MTLBuffer> vertexBufferPlaneBlack;
@property (nonatomic, strong) id<MTLBuffer> vertexBufferCyllinder;
@property (nonatomic, strong) id<MTLBuffer> vertexBufferCyllinderBlack;
@property (nonatomic, strong) id<MTLBuffer> vertexBufferTorus;
@property (nonatomic, strong) id<MTLBuffer> vertexBufferTorusBlack;
@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;
@property (nonatomic, strong) id<MTLBuffer> indexBuffer;
@property (nonatomic, strong) id<MTLBuffer> indexBufferBlack;
@property (nonatomic, strong) id<MTLBuffer> colorIndexBuffer;
@property (nonatomic, strong) id<MTLBuffer> normalsIndexBuffer;
@property (nonatomic, strong) id<MTLBuffer> textureIndexBufferCube;
@property (nonatomic, strong) id<MTLBuffer> textureIndexBufferSphere;
@property (nonatomic, strong) id<MTLSamplerState> sampler;
@property (nonatomic, retain) id<MTLTexture> textureCube;
@property (nonatomic, retain) id<MTLTexture> textureSphere;
@property (weak) IBOutlet NSComboBox *comboCubeTexture;


@property (nonatomic) BOOL isTranslate;
@property (nonatomic) BOOL isRotate;
@property (nonatomic) NSPoint lastMousePosition;
@property (weak) IBOutlet NSComboBox *comboBox;
@property (weak) IBOutlet NSComboBox *comboboxLightOnOff;
@property (weak) IBOutlet NSComboBox *comboboxLightType;
@property (weak) IBOutlet NSSwitch *verticesOnOff;
@property (weak) IBOutlet NSSwitch *testureOnOff;
@property (weak) IBOutlet NSProgressIndicator *progressCircle;
@property (weak) IBOutlet NSView *customView;
@property (weak) IBOutlet NSTextField *pointPosX;
@property (weak) IBOutlet NSTextField *pointPosY;
@property (weak) IBOutlet NSTextField *pointPosZ;
@property (weak) IBOutlet NSTextField *pointColR;
@property (weak) IBOutlet NSTextField *pointColG;
@property (weak) IBOutlet NSTextField *pointColB;
@property (weak) IBOutlet NSTextField *pointInten;
@property (weak) IBOutlet NSTextField *pointConst;
@property (weak) IBOutlet NSTextField *poinntLin;
@property (weak) IBOutlet NSTextField *pointQuad;
@property (weak) IBOutlet NSView *dirCustomView;

@property (weak) IBOutlet NSSlider *dirDX;
@property (weak) IBOutlet NSSlider *dirDY;
@property (weak) IBOutlet NSSlider *dirDZ;
@property (weak) IBOutlet NSTextField *dirCR;
@property (weak) IBOutlet NSTextField *dirCG;
@property (weak) IBOutlet NSTextField *dirCB;
@property (weak) IBOutlet NSTextField *dirACR;
@property (weak) IBOutlet NSTextField *dirACG;
@property (weak) IBOutlet NSTextField *dirACB;
@property (weak) IBOutlet NSTextField *dirDCR;
@property (weak) IBOutlet NSTextField *dirDCG;
@property (weak) IBOutlet NSTextField *dirDCB;
@property (weak) IBOutlet NSTextField *dirSCR;
@property (weak) IBOutlet NSTextField *dirSCG;
@property (weak) IBOutlet NSTextField *dirSCB;
@property (weak) IBOutlet NSTextField *dirInt;

@end

