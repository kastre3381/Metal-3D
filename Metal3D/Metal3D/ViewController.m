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
    [self.view addSubview:self.metalView];
    // Do any additional setup after loading the view.
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
    self.pipelineState = [self.device newRenderPipelineStateWithDescriptor:_pipelineDescriptor error:&error];
    
    
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
    translation[2] = [self.m_TransZSlider floatValue]/100.;
    
    [self updateMatrixValues];
        
    self.vertexBuffer = [self.device newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceStorageModeShared];
    
    id<MTLCommandBuffer> commandBuffer = [self.device newCommandQueue].commandBuffer;
    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [renderEncoder setRenderPipelineState:self.pipelineState];
    [renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:MainBuffer];
    [renderEncoder setVertexBytes:angles length:sizeof(angles) atIndex:RotationAngles];
    [renderEncoder setVertexBytes:scale length:sizeof(scale) atIndex:ScaleFactors];
    [renderEncoder setVertexBytes:translation length:sizeof(translation) atIndex:TranslationFactors];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:36];
    [renderEncoder endEncoding];
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
    
}

@end
