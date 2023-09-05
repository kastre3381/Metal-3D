#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.device = MTLCreateSystemDefaultDevice();
    self.metalView = [[MTKView alloc] initWithFrame:CGRectMake(44, 20, 766, 766) device:self.device];
    self.metalView.delegate = self;
    self.metalView.clearColor = MTLClearColorMake(1., 1., 1., 1.);
    _metalView.clearDepth = 1.;
    _metalView.depthStencilPixelFormat = MTLPixelFormatDepth16Unorm;
    
    [self.comboBox setStringValue:@"Cube"];
    [self.comboBox addItemWithObjectValue:@"Cube"];
    [self.comboBox addItemWithObjectValue:@"Sphere"];
    [self.comboBox addItemWithObjectValue:@"Floor"];

    
    [self.comboboxLightOnOff setStringValue:@"Off"];
    [self.comboboxLightOnOff addItemWithObjectValue:@"Off"];
    [self.comboboxLightOnOff addItemWithObjectValue:@"On"];
    
    [self.comboboxLightType setStringValue:@"Punctual"];
    [self.comboboxLightType addItemWithObjectValue:@"Punctual"];
    [self.comboboxLightType addItemWithObjectValue:@"Directional"];
    [self.comboboxLightType setHidden:YES];
    
    MTLTextureDescriptor *destinationTextureDescriptor = [[MTLTextureDescriptor alloc] init];
    destinationTextureDescriptor.pixelFormat = self.metalView.colorPixelFormat;
    destinationTextureDescriptor.width = 766;
    destinationTextureDescriptor.height = 766;
    destinationTextureDescriptor.usage = MTLTextureUsageShaderWrite | MTLTextureUsageShaderRead | MTLTextureUsageRenderTarget;

    _texture = [_device newTextureWithDescriptor:destinationTextureDescriptor];
    
    
    [self.view addSubview:self.metalView];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (IBAction)showLightOptionBox:(id)sender {
    if([[self.comboboxLightOnOff stringValue] isEqualToString:@"On"]) [self.comboboxLightType setHidden:NO];
    else [self.comboboxLightType setHidden:YES];
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
    translation[0] = [self.m_TransXSlider floatValue]/10.;
    translation[1] = [self.m_TransYSlider floatValue]/10.;
    translation[2] = [self.m_TransZSlider floatValue]/10.;
    
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
    [self.m_TransZSlider setFloatValue:-40.];
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
    [self.m_projFar setFloatValue:100.];
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
        {{-1000., 0., 0.}, {0., 0., 0.}, {0.,0.,1.,1.}},
        {{1000., 0., 0.}, {0., 0., 0.}, {0.,0.,1.,1.}},

        {{0., -1000., 0.}, {0., 0., 0.}, {0.,0.,1.,1.}},
        {{0., 1000., 0.}, {0., 0., 0.}, {0.,0.,1.,1.}},

        {{0., 0., -1000.}, {0., 0., 0.}, {0.,0.,1.,1.}},
        {{0., 0., 1000.}, {0., 0., 0.}, {0.,0.,1.,1.}},
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
    translation[0] = [self.m_TransXSlider floatValue]/10.;
    translation[1] = [self.m_TransYSlider floatValue]/10.;
    translation[2] = [self.m_TransZSlider floatValue]/10;
    
    
    float projPos[4];
    projPos[0] = [self.m_projLeft floatValue]/100.;
    projPos[1] = [self.m_projRight floatValue]/100.;
    projPos[2] = [self.m_projBottom floatValue]/100.;
    projPos[3] = [self.m_projTop floatValue]/100.;
    float nearFar[2];
    nearFar[0] = [self.m_projNear floatValue]/10.;
    nearFar[1] = [self.m_projFar floatValue]/10.;
    [self updateMatrixValues];
        
    
    
    bool isPlot = true;
    
    MTLDepthStencilDescriptor *depthDescriptor = [MTLDepthStencilDescriptor new];
    depthDescriptor.depthCompareFunction = MTLCompareFunctionLessEqual;
    depthDescriptor.depthWriteEnabled = YES;
    id<MTLDepthStencilState> depthState = [_device newDepthStencilStateWithDescriptor:depthDescriptor];
    
    id<MTLCommandBuffer> commandBuffer = [self.device newCommandQueue].commandBuffer;
    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
//    renderPassDescriptor.colorAttachments[0].texture = self.texture;
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
    
    if([[self.comboBox stringValue] isEqualToString:@"Cube"])
    {
        Vertex vertices[] =
        {
            {{-0.5, -0.5, 0.5}, {0., 0., 1.}, {1., 0., 0., 1.}},
            {{ 0.5, -0.5, 0.5}, {0., 0., 1.}, {1., 0., 0., 1.}},
            {{ 0.5,  0.5, 0.5}, {0., 0., 1.}, {1., 0., 0., 1.}},
            
            {{-0.5, -0.5, 0.5}, {0., 0., 1.}, {1., 0., 0., 1.}},
            {{ -0.5, 0.5, 0.5}, {0., 0., 1.}, {1., 0., 0., 1.}},
            {{ 0.5,  0.5, 0.5}, {0., 0., 1.}, {1., 0., 0., 1.}},
            
            
            {{-0.5, -0.5, -0.5}, {0., 0., -1.}, {1., 0., 0., 1.}},
            {{ 0.5, -0.5, -0.5}, {0., 0., -1.}, {1., 0., 0., 1.}},
            {{ 0.5,  0.5, -0.5}, {0., 0., -1.}, {1., 0., 0., 1.}},
            
            {{-0.5, -0.5, -0.5}, {0., 0., -1.}, {1., 0., 0., 1.}},
            {{ -0.5, 0.5, -0.5}, {0., 0., -1.}, {1., 0., 0., 1.}},
            {{ 0.5,  0.5, -0.5}, {0., 0., -1.}, {1., 0., 0., 1.}},
            
            
            {{ 0.5, -0.5,  0.5}, {1., 0., 0.}, {0., 1., 0., 1.}},
            {{ 0.5, -0.5, -0.5}, {1., 0., 0.}, {0., 1., 0., 1.}},
            {{ 0.5,  0.5, -0.5}, {1., 0., 0.}, {0., 1., 0., 1.}},
            
            {{ 0.5, -0.5,  0.5}, {1., 0., 0.}, {0., 1., 0., 1.}},
            {{ 0.5,  0.5,  0.5}, {1., 0., 0.}, {0., 1., 0., 1.}},
            {{ 0.5,  0.5, -0.5}, {1., 0., 0.}, {0., 1., 0., 1.}},
            
            
            {{ -0.5, -0.5,  0.5}, {-1., 0., 0.}, {0., 1., 0., 1.}},
            {{ -0.5, -0.5, -0.5}, {-1., 0., 0.}, {0., 1., 0., 1.}},
            {{ -0.5,  0.5, -0.5}, {-1., 0., 0.}, {0., 1., 0., 1.}},
            
            {{ -0.5, -0.5, 0.5}, {-1., 0., 0.}, {0., 1., 0., 1.}},
            {{ -0.5, 0.5,  0.5}, {-1., 0., 0.}, {0., 1., 0., 1.}},
            {{ -0.5, 0.5, -0.5}, {-1., 0., 0.}, {0., 1., 0., 1.}},
            
            
            {{ 0.5,  0.5,  0.5}, {0., 1., 0.}, {0., 0., 1., 1.}},
            {{ 0.5,  0.5, -0.5}, {0., 1., 0.}, {0., 0., 1., 1.}},
            {{ -0.5, 0.5, -0.5}, {0., 1., 0.}, {0., 0., 1., 1.}},
            
            {{ 0.5,  0.5,  0.5}, {0., 1., 0.}, {0., 0., 1., 1.}},
            {{ -0.5, 0.5,  0.5}, {0., 1., 0.}, {0., 0., 1., 1.}},
            {{ -0.5, 0.5, -0.5}, {0., 1., 0.}, {0., 0., 1., 1.}},
            
            
            {{ 0.5, -0.5,   0.5}, {0., -1., 0.}, {0., 0., 1., 1.}},
            {{ 0.5, -0.5,  -0.5}, {0., -1., 0.}, {0., 0., 1., 1.}},
            {{ -0.5, -0.5, -0.5}, {0., -1., 0.}, {0., 0., 1., 1.}},
            
            {{  0.5, -0.5,  0.5}, {0., -1., 0.}, {0., 0., 1., 1.}},
            {{ -0.5, -0.5,  0.5}, {0., -1., 0.}, {0., 0., 1., 1.}},
            {{ -0.5, -0.5, -0.5}, {0., -1., 0.}, {0., 0., 1., 1.}},
        };
        self.vertexBuffer = [self.device newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceStorageModeShared];
        [renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:MainBuffer];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:36];
        
        [renderEncoder setTriangleFillMode:MTLTriangleFillModeLines];
        Vertex vertices2[11*36];
        
        for(int i=0; i<11; i++)
        {
            for(int j=0; j<36; j++)
            {
                vertices2[i*36+j] = {vertices[j].position-vector_float3(5./1500.)+vector_float3(i*1./1500.), vertices[j].normals, {0.,0.,0.,1.}};
            }
        }
        
        
        self.vertexBuffer = [self.device newBufferWithBytes:vertices2 length:sizeof(vertices2) options:MTLResourceStorageModeShared];
        [renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:MainBuffer];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:11*36];
    }
    else if([[self.comboBox stringValue] isEqualToString:@"Sphere"])
    {
        Vertex vertices2[10201];
        
        float radius = 0.5;
        float x, y, z, xy, nx, ny, nz, lengthInv = 1.0f / radius;
        float sectorCount = 100., stackCount = 100.;
        
        float sectorStep = 2 * M_PI / sectorCount;
        float stackStep = M_PI / stackCount;
        float sectorAngle, stackAngle;

        for(int i = 0; i <= stackCount; ++i)
        {
            stackAngle = M_PI / 2 - i * stackStep;
            xy = radius * cosf(stackAngle);
            z = radius * sinf(stackAngle);

            for(int j = 0; j <= sectorCount; ++j)
            {
                sectorAngle = j * sectorStep;
                x = xy * cosf(sectorAngle);
                y = xy * sinf(sectorAngle);
                
                nx = x * lengthInv;
                ny = y * lengthInv;
                nz = z * lengthInv;
                
                vertices2[101*i + j] = {{x,y,z}, {nx, ny, nz}, {100*x,100*y,100*z,1.}};
            }
        }
        self.vertexBuffer = [self.device newBufferWithBytes:vertices2 length:sizeof(vertices2) options:MTLResourceStorageModeShared];
        [renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:MainBuffer];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:10201];
    }
    else if([[self.comboBox stringValue] isEqualToString:@"Floor"])
    {
        Vertex vertices[] =
        {
            {{ 0., -1., -1.}, {0., 0., 1.}, {1., 1., 0., 1.}},
            {{ 0., -1., 1.}, {0., 0., 1.}, {1., 0., 1., 1.}},
            {{ 0.,  1., 1.}, {0., 0., 1.}, {1., 1., 0., 1.}},
            
            {{ 0., -1., -1.}, {0., 0., 1.}, {1., 1., 0., 1.}},
            {{ 0., 1., -1.}, {0., 0., 1.}, {0., 1., 1., 1.}},
            {{ 0., 1., 1.}, {0., 0., 1.}, {1., 1., 0., 1.}}
        };
        
        self.vertexBuffer = [self.device newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceStorageModeShared];
        [renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:MainBuffer];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
    }
    
//    library = [self.device newDefaultLibrary];
//    vertexFunction = [library newFunctionWithName:@"vertex2D"];
//    fragmentFunction = [library newFunctionWithName:@"fragment2D"];
//    _pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
//    _pipelineDescriptor.fragmentFunction = fragmentFunction;
//    _pipelineDescriptor.vertexFunction = vertexFunction;
//    _pipelineDescriptor.colorAttachments[0].pixelFormat = self.metalView.colorPixelFormat;
//    _pipelineDescriptor.depthAttachmentPixelFormat = self.metalView.depthStencilPixelFormat;
//    self.pipelineState = [self.device newRenderPipelineStateWithDescriptor:_pipelineDescriptor error:&error];
//    [renderEncoder setRenderPipelineState:self.pipelineState];
//    [renderEncoder setDepthStencilState:depthState];
//
//    _texture = renderPassDescriptor.colorAttachments[0].texture;
//    [renderEncoder setFragmentTexture:self.texture atIndex:FragmentTexture];
//    Vertex vertices[] = {
//        {{-1., -1., 0.}, {0.,0.,0.}, {0., 0.,0., 0.}},
//        {{-1., 1., 0.}, {0.,0.,0.}, {0., 0.,0., 0.}},
//        {{ 1., 1., 1.}, {0.,0.,0.}, {0., 0.,0., 0.}},
//
//        {{-1., -1., 0.}, {0.,0.,0.}, {0., 0.,0., 0.}},
//        {{ 1., -1., 0.}, {0.,0.,0.}, {0., 0.,0., 0.}},
//        {{ 1., 1., 0.}, {0.,0.,0.}, {0., 0.,0., 0.}}
//    };
//    self.vertexBuffer = [self.device newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceStorageModeShared];
//    [renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:MainBuffer];
//    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
    
    
    [renderEncoder endEncoding];
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
    
}

-(void)mouseDragged:(NSEvent *)event
{
    NSLog(@"|x drag");
    if(true)
    {
        float tx =  [event locationInWindow].x, ty =  [event locationInWindow].y;
        if(tx>=44. && tx<=44.+766. && ty>=20. && ty<=20.+766.)
        {
            NSPoint currentMouseLocation = [event locationInWindow];
            float deltaX = currentMouseLocation.x - self.lastMousePosition.x;
            float deltaY = currentMouseLocation.y - self.lastMousePosition.y;

            [self.m_RotationXSlider setFloatValue:[self.m_RotationXSlider floatValue]+deltaX];
            [self.m_RotationYSlider setFloatValue:[self.m_RotationYSlider floatValue]+deltaY];
            
            self.lastMousePosition = currentMouseLocation;
        }
    }
    if(true)
    {
        float tx =  [event locationInWindow].x, ty =  [event locationInWindow].y;
        if(tx>=44. && tx<=44.+766. && ty>=20. && ty<=20.+766.)
        {
            tx = (tx-766./2.)/766.*50.;
            ty = (ty-766./2.)/766.*50.;
            [self.m_TransXSlider setFloatValue:tx];
            [self.m_TransYSlider setFloatValue:ty];
        }
    }
}

- (void)keyDown:(NSEvent *)event {
    NSString *characters = [event characters];
    unichar character = [characters characterAtIndex:0];
    
    NSLog(@"|x down");
    if(character == 'w' || character == 'W')
    {
        _isTranslate = true;
    }
    if(character == 'f' || character == 'F')
    {
        _isRotate = true;
    }
}

- (void)keyUp:(NSEvent *)event {
    NSString *characters = [event characters];
    unichar character = [characters characterAtIndex:0];
    
    NSLog(@"|x up");
    
    if(character == 'w' || character == 'W')
    {
        _isTranslate = false;
    }
    if(character == 'f' || character == 'F')
    {
        _isRotate = false;
    }
}


@end
