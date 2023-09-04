//
//  ViewController.m
//  Metal3D
//
//  Created by MotionVFX on 01/09/2023.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.device = MTLCreateSystemDefaultDevice();
    self.metalView = [[MTKView alloc] initWithFrame:CGRectMake(264, 325, 458, 455) device:self.device];
    self.metalView.delegate = self;
    self.metalView.clearColor = MTLClearColorMake(0., 0., 0., 1.);
    _metalView.clearDepth = 1.;
    _metalView.depthStencilPixelFormat = MTLPixelFormatDepth16Unorm;
    
    
    [self.view addSubview:self.metalView];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

-(void)updateMatrixValues
{
    float angles[3];
    angles[0] = 2.*M_PI/360.*[self.m_RotationXSlider floatValue];
    angles[1] = 2.*M_PI/360.*[self.m_RotationYSlider floatValue];
    angles[2] = 2.*M_PI/360.*[self.m_RotationZSlider floatValue];
    
    [self.rotLeftTop  setStringValue:[NSString stringWithUTF8String:std::to_string(cos(angles[1])*cos(angles[2])).substr(0,6).c_str()]];
    [self.rotLeftMid  setStringValue:[NSString stringWithUTF8String:std::to_string(cos(angles[1])*cos(angles[2])).substr(0,6).c_str()]];
    [self.rotLeftBot  setStringValue:[NSString stringWithUTF8String:std::to_string((sin(angles[0])*sin(angles[1])*cos(angles[2]) - cos(angles[0])*sin(angles[2]))).substr(0,6).c_str()]];
    [self.rotMidTop   setStringValue:[NSString stringWithUTF8String:std::to_string((cos(angles[0])*sin(angles[1])*cos(angles[2]) + sin(angles[0])*sin(angles[2]))).substr(0,6).c_str()]];
    [self.rotMidMid   setStringValue:[NSString stringWithUTF8String:std::to_string(cos(angles[1])*sin(angles[2])).substr(0,6).c_str()]];
    [self.rotMidBot   setStringValue:[NSString stringWithUTF8String:std::to_string((sin(angles[0])*sin(angles[1])*sin(angles[2]) + cos(angles[0])*cos(angles[2]))).substr(0,6).c_str()]];
    [self.rotRightTop setStringValue:[NSString stringWithUTF8String:std::to_string((cos(angles[0])*sin(angles[1])*sin(angles[2]) - sin(angles[0])*cos(angles[2]))).substr(0,6).c_str()]];
    [self.rotRightMid setStringValue:[NSString stringWithUTF8String:std::to_string(-sin(angles[1])).substr(0,6).c_str()]];
    [self.rotRightBot setStringValue:[NSString stringWithUTF8String:std::to_string(cos(angles[0])*cos(angles[1])).substr(0,6).c_str()]];
    
    
    float scale[3];
    scale[0] = [self.m_ScaleXSlider floatValue]/100.;
    scale[1] = [self.m_ScaleYSlider floatValue]/100.;
    scale[2] = [self.m_ScaleZSlider floatValue]/100.;
    
    [self.scaleLeftTop setStringValue:[NSString stringWithUTF8String:std::to_string(scale[0]).substr(0,6).c_str()]];
    [self.scaleMidMid setStringValue:[NSString stringWithUTF8String:std::to_string(scale[1]).substr(0,6).c_str()]];
    [self.scaleRightBot setStringValue:[NSString stringWithUTF8String:std::to_string(scale[2]).substr(0,6).c_str()]];
    
    float translation[3];
    translation[0] = [self.m_TransXSlider floatValue]/100.;
    translation[1] = [self.m_TransYSlider floatValue]/100.;
    translation[2] = [self.m_TransZSlider floatValue]/100.;
    
    [self.transX setStringValue:[NSString stringWithUTF8String:std::to_string(translation[0]).substr(0,6).c_str()]];
    [self.transY setStringValue:[NSString stringWithUTF8String:std::to_string(translation[1]).substr(0,6).c_str()]];
    [self.transZ setStringValue:[NSString stringWithUTF8String:std::to_string(translation[2]).substr(0,6).c_str()]];
    
    float projPos[4];
    projPos[0] = [self.m_projLeft floatValue]/100.;
    projPos[1] = [self.m_projRight floatValue]/100.;
    projPos[2] = [self.m_projBottom floatValue]/100.;
    projPos[3] = [self.m_projTop floatValue]/100.;
    
    float nearFar[2];
    nearFar[0] = [self.m_projNear floatValue]/10.;
    nearFar[1] = [self.m_projFar floatValue]/10.;
    
    [self.projLeftTop setStringValue:[NSString stringWithUTF8String:std::to_string(2.*nearFar[0]/(projPos[0]-projPos[1])).substr(0,6).c_str()]];
    [self.projMidLeftTop setStringValue:[NSString stringWithUTF8String:std::to_string(2.*nearFar[0]/(projPos[3]-projPos[2])).substr(0,6).c_str()]];
    [self.projMidRightTop setStringValue:[NSString stringWithUTF8String:std::to_string((projPos[0]+projPos[1])/(projPos[1]-projPos[0])).substr(0,6).c_str()]];
    [self.projMidRightMid setStringValue:[NSString stringWithUTF8String:std::to_string((projPos[2]+projPos[3])/(projPos[2]-projPos[3])).substr(0,6).c_str()]];
    [self.projMidRightBot setStringValue:[NSString stringWithUTF8String:std::to_string(-(nearFar[0]+nearFar[1])/(nearFar[1]-nearFar[0])).substr(0,6).c_str()]];
    [self.projRightMidBot setStringValue:[NSString stringWithUTF8String:std::to_string(-2.*nearFar[0]*nearFar[1]/(projPos[1]-projPos[0])).substr(0,6).c_str()]];
}
- (IBAction)resetParameters:(id)sender {
    [self.m_TransXSlider setFloatValue:0.];
    [self.m_TransYSlider setFloatValue:0.];
    [self.m_TransZSlider setFloatValue:0.];
    [self.m_ScaleXSlider setFloatValue:100.];
    [self.m_ScaleYSlider setFloatValue:100.];
    [self.m_ScaleZSlider setFloatValue:100.];
    [self.m_ScaleXSlider setFloatValue:100.];
    [self.m_RotationXSlider setFloatValue:0.];
    [self.m_RotationYSlider setFloatValue:0.];
    [self.m_RotationZSlider setFloatValue:0.];
    [self.m_projLeft setFloatValue:-50.];
    [self.m_projRight setFloatValue:50.];
    [self.m_projBottom setFloatValue:-50.];
    [self.m_projTop setFloatValue:50.];
    [self.m_projNear setFloatValue:10.];
    [self.m_projFar setFloatValue:0.];
}

- (void)drawInMTKView:(MTKView *)view
{
    NSError* error = nil;
    id<MTLLibrary> library = [self.device newDefaultLibrary];
    id<MTLFunction> vertexFunction = [library newFunctionWithName:@"vertexMain"];
    id<MTLFunction> fragmentFunction = [library newFunctionWithName:@"fragmentMain"];
    _pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    _pipelineDescriptor.fragmentFunction = fragmentFunction;
    _pipelineDescriptor.vertexFunction = vertexFunction;
    _pipelineDescriptor.colorAttachments[0].pixelFormat = self.metalView.colorPixelFormat;
    _pipelineDescriptor.depthAttachmentPixelFormat = self.metalView.depthStencilPixelFormat;
    
    self.pipelineState = [self.device newRenderPipelineStateWithDescriptor:_pipelineDescriptor error:&error];
    
    
    Vertex lines[] =
    {
        {{-1000., 0., 0.}, {1.,1.,1.,1.}},
        {{1000., 0., 0.}, {1.,1.,1.,1.}},

        {{0., -1000., 0.}, {1.,1.,1.,1.}},
        {{0., 1000., 0.}, {1.,1.,1.,1.}},

        {{0., 0., -1000.}, {1.,1.,1.,1.}},
        {{0., 0., 1000.}, {1.,1.,1.,1.}},
    };
    
//    Vertex lines[3*2*3*25];
//
//    for(int k=0; k<5; k++)
//    {
//        for(int j=0; j<5; j++)
//        {
//            float alfa = 0.5;
//            float step = 2./7., start = -6./7.;
//            if(-6./7.+k*2./7. == 0 && -6./7.+j*2./7. == 0) alfa = 1.;
//
//            lines[3*(2*(5*k + j))] = {{-10., -(start+k*step), start+j*step}, {1.,1.,1.,alfa}};
//            lines[3*(2*(5*k + j)+1)] = {{ 10., start+k*step, start+j*step}, {1.,1.,1.,alfa}};
//        }
//    }
//
//    for(int k=0; k<5; k++)
//    {
//        for(int j=0; j<5; j++)
//        {
//            float alfa = 0.5;
//            float step = 2./7., start = -6./7.;
//            if(-6./7.+k*2./7. == 0 && -6./7.+j*2./7. == 0) alfa = 1.;
//
//            lines[3*(2*(5*k + j)) + 2*3*25] = {{start+k*step,  -10., start+j*step}, {1.,1.,1.,alfa}};
//            lines[3*(2*(5*k + j)+1) + 2*3*25] = {{start+k*step, 10., start+j*step}, {1.,1.,1.,alfa}};
//        }
//    }
//
//    for(int k=0; k<5; k++)
//    {
//        for(int j=0; j<5; j++)
//        {
//            float alfa = 0.5;
//            float step = 2./7., start = -6./7.;
//            if(-6./7.+k*2./7. == 0 && -6./7.+j*2./7. == 0) alfa = 1.;
//
//            lines[3*(2*(5*k + j)) + 2*2*3*25] = {{start+k*step, start+j*step, -10.}, {1.,1.,1.,alfa}};
//            lines[3*(2*(5*k + j)+1) + 2*2*3*25] = {{start+k*step, start+j*step, 10.}, {1.,1.,1.,alfa}};
//        }
//    }
    
    //cube vertices, the walls that are opposite to each other hhave the same colors
    Vertex vertices[] =
    {
        {{-0.5, -0.5, 0.5}, {1., 0., 0., 1.}},
        {{ 0.5, -0.5, 0.5}, {1., 0., 0., 1.}},
        {{ 0.5,  0.5, 0.5}, {1., 0., 0., 1.}},
        
        {{-0.5, -0.5, 0.5}, {1., 0., 0., 1.}},
        {{ -0.5, 0.5, 0.5}, {1., 0., 0., 1.}},
        {{ 0.5,  0.5, 0.5}, {1., 0., 0., 1.}},
        
        
        {{-0.5, -0.5, -0.5}, {1., 0., 0., 1.}},
        {{ 0.5, -0.5, -0.5}, {1., 0., 0., 1.}},
        {{ 0.5,  0.5, -0.5}, {1., 0., 0., 1.}},
        
        {{-0.5, -0.5, -0.5}, {1., 0., 0., 1.}},
        {{ -0.5, 0.5, -0.5}, {1., 0., 0., 1.}},
        {{ 0.5,  0.5, -0.5}, {1., 0., 0., 1.}},
        
        
        {{ 0.5, -0.5, 0.5}, {0., 1., 0., 1.}},
        {{ 0.5, -0.5, -0.5}, {0., 1., 0., 1.}},
        {{ 0.5,  0.5, -0.5}, {0., 1., 0., 1.}},
        
        {{ 0.5, -0.5, 0.5}, {0., 1., 0., 1.}},
        {{ 0.5, 0.5, 0.5}, {0., 1., 0., 1.}},
        {{ 0.5,  0.5, -0.5}, {0., 1., 0., 1.}},
        
        
        {{ -0.5, -0.5, 0.5}, {0., 1., 0., 1.}},
        {{ -0.5, -0.5, -0.5}, {0., 1., 0., 1.}},
        {{ -0.5,  0.5, -0.5}, {0., 1., 0., 1.}},
        
        {{ -0.5, -0.5, 0.5}, {0., 1., 0., 1.}},
        {{ -0.5, 0.5, 0.5}, {0., 1., 0., 1.}},
        {{ -0.5,  0.5, -0.5}, {0., 1., 0., 1.}},
        
        
        {{ 0.5, 0.5, 0.5}, {0., 0., 1., 1.}},
        {{ 0.5, 0.5, -0.5}, {0., 0., 1., 1.}},
        {{ -0.5, 0.5, -0.5}, {0., 0., 1., 1.}},
        
        {{ 0.5, 0.5, 0.5}, {0., 0., 1., 1.}},
        {{ -0.5, 0.5, 0.5}, {0., 0., 1., 1.}},
        {{ -0.5, 0.5, -0.5}, {0., 0., 1., 1.}},
        
        
        {{ 0.5, -0.5, 0.5}, {0., 0., 1., 1.}},
        {{ 0.5, -0.5, -0.5}, {0., 0., 1., 1.}},
        {{ -0.5, -0.5, -0.5}, {0., 0., 1., 1.}},
        
        {{ 0.5, -0.5, 0.5}, {0., 0., 1., 1.}},
        {{ -0.5, -0.5, 0.5}, {0., 0., 1., 1.}},
        {{ -0.5, -0.5, -0.5}, {0., 0., 1., 1.}},
    };

    float angles[3];
    angles[0] = 2.*M_PI/360.*[self.m_RotationXSlider floatValue];
    angles[1] = 2.*M_PI/360.*[self.m_RotationYSlider floatValue];
    angles[2] = 2.*M_PI/360.*[self.m_RotationZSlider floatValue];
    
    float scale[3];
    scale[0] = [self.m_ScaleXSlider floatValue]/100.;
    scale[1] = [self.m_ScaleYSlider floatValue]/100.;
    scale[2] = [self.m_ScaleZSlider floatValue]/100.;
    
    float translation[3];
    translation[0] = [self.m_TransXSlider floatValue]/100.;
    translation[1] = [self.m_TransYSlider floatValue]/100.;
    translation[2] = [self.m_TransZSlider floatValue]/10;
    
    printf("| translation[2] = %f\n", translation[2]);
    
    float projPos[4];
    projPos[0] = [self.m_projLeft floatValue]/100.;
    projPos[1] = [self.m_projRight floatValue]/100.;
    projPos[2] = [self.m_projBottom floatValue]/100.;
    projPos[3] = [self.m_projTop floatValue]/100.;
    printf("| projPos = %f, %f, %f, %f\n", projPos[0], projPos[1], projPos[2], projPos[3]);
    float nearFar[2];
    nearFar[0] = [self.m_projNear floatValue]/10.;
    nearFar[1] = [self.m_projFar floatValue]/10.;
    printf("| nearFar = %f, %f\n", nearFar[0], nearFar[1]);
    [self updateMatrixValues];
        
    self.vertexBuffer = [self.device newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceStorageModeShared];
    
    bool isPlot = true;
    
    MTLDepthStencilDescriptor *depthDescriptor = [MTLDepthStencilDescriptor new];
    depthDescriptor.depthCompareFunction = MTLCompareFunctionLessEqual;
    depthDescriptor.depthWriteEnabled = YES;
    id<MTLDepthStencilState> depthState = [_device newDepthStencilStateWithDescriptor:depthDescriptor];
    
    id<MTLCommandBuffer> commandBuffer = [self.device newCommandQueue].commandBuffer;
    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    
//    view.currentRenderPassDescriptor.depthAttachment.storeAction = MTLStoreActionStore;
    
    renderPassDescriptor.depthAttachment.storeAction = MTLStoreActionStore;
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [renderEncoder setRenderPipelineState:self.pipelineState];
    [renderEncoder setDepthStencilState:depthState];
    
    [renderEncoder setVertexBytes:angles length:sizeof(float)*4 atIndex:RotationAngles];
    [renderEncoder setVertexBytes:scale length:sizeof(float)*4 atIndex:ScaleFactors];
    [renderEncoder setVertexBytes:translation length:sizeof(float)*4 atIndex:TranslationFactors];
    [renderEncoder setVertexBytes:projPos length:sizeof(float)*4 atIndex:ProjectionDirections];
    [renderEncoder setVertexBytes:nearFar length:sizeof(float)*2 atIndex:NearFar];
    
    [renderEncoder setVertexBytes:&isPlot length:sizeof(bool) atIndex:PlotOnOff];
    [renderEncoder setVertexBuffer:[self.device newBufferWithBytes:lines length:sizeof(lines) options:MTLResourceStorageModeShared] offset:0 atIndex:MainBuffer];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeLine vertexStart:0 vertexCount:6];
    
    isPlot = false;
    [renderEncoder setVertexBytes:&isPlot length:sizeof(isPlot) atIndex:PlotOnOff];
    [renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:MainBuffer];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:36];
    
    [renderEncoder endEncoding];
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
    
}

@end
