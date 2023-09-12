#import "ViewController.h"

@implementation ViewController

vector_float3 calculateNormalToTorus(float rin, float rout, float iangle, float jangle)
{

    float tx = -sin(jangle);
    float ty = cos(jangle);
    float tz = 0;

    float sx = cos(jangle)*(-sin(iangle));
    float sy = sin(jangle)*(-sin(iangle));
    float sz = cos(iangle);

    float nx = ty*sz - tz*sy;
    float ny = tz*sx - tx*sz;
    float nz = tx*sy - ty*sx;

    float length = sqrt(nx*nx + ny*ny + nz*nz);
    nx /= length;
    ny /= length;
    nz /= length;
    
    return {nx,ny,nz};
}

- (id<MTLTexture>)loadTextureWithImageNamed:(NSString *)imageName {
    NSError *error = nil;
    
    MTKTextureLoader *textureLoader = [[MTKTextureLoader alloc] initWithDevice:self.device];
    
    id<MTLTexture> texture = [textureLoader newTextureWithName:imageName scaleFactor:1.0 bundle:nil options:nil error:&error];
    
    if (error) {
        NSLog(@"texture not work: %@", error);
        return nil;
    }
    
    NSLog(@"Texture loaded :D");
    return texture;
}

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
    [self.comboBox addItemWithObjectValue:@"Plane"];
    [self.comboBox addItemWithObjectValue:@"Cyllinder"];
    [self.comboBox addItemWithObjectValue:@"Torus"];
    [self.comboBox addItemWithObjectValue:@"Human"];
    
    [self.comboCubeTexture setHidden:YES];
    [self.comboCubeTexture setStringValue:@"Minecraft"];
    [self.comboCubeTexture addItemWithObjectValue:@"Minecraft"];
    [self.comboCubeTexture addItemWithObjectValue:@"Paradise"];
    [self.comboCubeTexture addItemWithObjectValue:@"Future"];
    [self.comboCubeTexture addItemWithObjectValue:@"White"];
    [self.comboCubeTexture addItemWithObjectValue:@"Gossling"];
    
    [self.comboboxLightOnOff setStringValue:@"Off"];
    [self.comboboxLightOnOff addItemWithObjectValue:@"Off"];
    [self.comboboxLightOnOff addItemWithObjectValue:@"On"];
    
    [self.comboboxLightType setStringValue:@"Punctual"];
    [self.comboboxLightType addItemWithObjectValue:@"Punctual"];
    [self.comboboxLightType addItemWithObjectValue:@"Directional"];
    [self.comboboxLightType setHidden:YES];
    
    [self.progressCircle setHidden:YES];
    
    [self.customView setHidden:YES];
    [self.pointPosX setFloatValue:0.0];
    [self.pointPosY setFloatValue:0.0];
    [self.pointPosZ setFloatValue:0.0];
    [self.pointColR setFloatValue:256.0];
    [self.pointColG setFloatValue:256.0];
    [self.pointColB setFloatValue:256.0];
    [self.pointInten setFloatValue:20.];
    [self.poinntLin setFloatValue:0.1];
    [self.pointConst setFloatValue:10.];
    [self.pointQuad setFloatValue:0.1];
    
    [self.dirCustomView setHidden:YES];
    [self.dirDX setFloatValue:0.0];
    [self.dirDY setFloatValue:0.0];
    [self.dirDZ setFloatValue:0.0];
    [self.dirCR setFloatValue:256.];
    [self.dirCG setFloatValue:256.];
    [self.dirCB setFloatValue:256.];
    [self.dirACR setFloatValue:50.];
    [self.dirACG setFloatValue:50.];
    [self.dirACB setFloatValue:50.];
    [self.dirDCR setFloatValue:200.];
    [self.dirDCG setFloatValue:200.];
    [self.dirDCB setFloatValue:200.];
    [self.dirSCR setFloatValue:256.];
    [self.dirSCG setFloatValue:256.];
    [self.dirSCB setFloatValue:256.];
    [self.dirInt setFloatValue:32.];
    
    
    uint indexes[] = {
        0, 1, 2, 0, 2, 3,
        4, 5, 7, 5, 6, 7,
        0, 1, 5, 1, 4, 5,
        2, 3, 6, 2, 6, 7,
        0, 5, 6, 0, 3, 6,
        1, 2, 4, 2, 4, 7
    };
    
    uint colorIndexes[] = {
        0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0,
        1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1,
        2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2
    };
    
    uint normalsIndexes[] = {
        0, 0, 0, 0, 0, 0,
        1, 1, 1, 1, 1, 1,
        3, 3, 3, 3, 3, 3,
        2, 2, 2, 2, 2, 2,
        4, 4, 4, 4, 4, 4,
        5, 5, 5, 5, 5, 5
    };
    
    vector_float2 textureCoords[] = {
        {1./4., 1./3.}, {1./2., 1./3.}, {1./2., 2./3.},
        {1./4., 1./3.}, {1./2., 2./3.}, {1./4., 2./3.}, //gora
        
        {3./4., 1./3.}, {2./2., 1./3.}, {3./4., 2./3.},
        {4./4., 1./3.}, {2./2., 2./3.}, {3./4., 2./3.}, //dol
        
        {1./4., 1./3.}, {1./2., 1./3.}, {1./4., 0./3.},
        {1./2., 1./3.}, {2./4., 0./.3}, {1./4., 0./3.}, //tyl
        
        {1./2., 2./3.}, {1./4., 2./3.}, {1./4., 3./3.},
        {1./2., 2./3.}, {1./4., 3./3.}, {2./4., 3./3.}, //przod
        
        {1./4., 1./3.}, {0./4., 1./3.}, {0./4., 2./3.},
        {1./4., 1./3.}, {1./4., 2./3.}, {0./4., 2./3.}, //lewo
        
        {1./2., 1./3.}, {1./2., 2./3.}, {3./4., 1./3.},
        {1./2., 2./3.}, {3./4., 1./3.}, {3./4., 2./3.}  //prawo
    };
    
    self.indexBuffer = [self.device newBufferWithBytes:indexes length:sizeof(indexes) options:MTLResourceStorageModeShared];
    self.colorIndexBuffer = [self.device newBufferWithBytes:colorIndexes length:sizeof(colorIndexes) options:MTLResourceStorageModeShared];
    self.normalsIndexBuffer = [self.device newBufferWithBytes:normalsIndexes length:sizeof(normalsIndexes) options:MTLResourceStorageModeShared];
    self.textureIndexBufferCube = [self.device newBufferWithBytes:textureCoords length:sizeof(textureCoords) options:MTLResourceStorageModeShared];
    
    //cube
    {
        Vertex vertices[] =
        {
            {{-0.5, -0.5, 0.5}, {0., 0., 1.}, {1., 0., 0., 1.}},    //0
            {{ 0.5, -0.5, 0.5}, {0., 0., -1.}, {0., 1., 0., 1.}},   //1
            {{ 0.5,  0.5, 0.5}, {0., 1., 0.}, {0., 0., 1., 1.}},    //2
            {{ -0.5, 0.5, 0.5}, {0., -1., 0.}, {1., 0., 0., 1.}},   //3
            
            {{ 0.5, -0.5, -0.5}, {1., 0., 0.}, {1., 0., 0., 1.}},   //4
            {{-0.5, -0.5, -0.5}, {-1., 0., 0.}, {1., 0., 0., 1.}},  //5
            {{ -0.5, 0.5, -0.5}, {0., 0., -1.}, {1., 0., 0., 1.}},  //6
            {{ 0.5,  0.5, -0.5}, {0., 0., -1.}, {1., 0., 0., 1.}},  //7
        };
        self.vertexBufferCube = [self.device newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceStorageModeShared];
        
        Vertex vertices2[11*36];
        uint indexes2[11*36];
        
        for(int i=0; i<11; i++)
        {
            for(int j=0; j<36; j++)
            {
                vertices2[i*36+j] = {vertices[j].position-vector_float3(5./1500.)+vector_float3(i*1./1500.), vertices[j].normals, {0.,0.,0.,1.}};
                indexes2[i*36+j] = indexes[j%36];
            }
        }
        self.vertexBufferCubeBlack = [self.device newBufferWithBytes:vertices2 length:sizeof(vertices2) options:MTLResourceStorageModeShared];
        self.indexBufferBlack = [self.device newBufferWithBytes:indexes2 length:sizeof(indexes2) options:MTLResourceStorageModeShared];
    }
    //sphere
    {
        Vertex vertices[45*120*2*3];
        
        float MAX_VAL = 45;
        float MAX_VAL_CIRCLE = 120;
        float r = 0.8;
        float MIN_ANGLE_CIRCLE = 2.*M_PI/MAX_VAL_CIRCLE;
        float MIN_ANGLE = 2.*M_PI/MAX_VAL;
        float FULL_ANGLE = 2.*M_PI;
        float HALF_ANGLE = M_PI;
        vector_float2 texCoords[45*120*2*3];
        
        for(int j=0; j<(MAX_VAL_CIRCLE)/12; j++)
        {
            for(int i=0; i<MAX_VAL; i++)
            {
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j] = {{(r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*cosf(MIN_ANGLE*(float)i),
                    (r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*sinf(MIN_ANGLE*(float)i),
                    r*cosf(6.*MIN_ANGLE_CIRCLE*(float)j)},
                    {(r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*cosf(MIN_ANGLE*(float)i),
                        (r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*sinf(MIN_ANGLE*(float)i),
                        r*cosf(6.*MIN_ANGLE_CIRCLE*(float)j)},
                    {(r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*cosf(MIN_ANGLE*(float)i), (r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*sinf(MIN_ANGLE*(float)i), r*cosf(6.*MIN_ANGLE_CIRCLE*(float)j), 1.}};
                texCoords[i*(int)MAX_VAL_CIRCLE + 6*j] = {(MIN_ANGLE*(float)(i))/FULL_ANGLE, (6*MIN_ANGLE_CIRCLE*(float)(j))/HALF_ANGLE};
                
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 1] = {{(r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*cosf(MIN_ANGLE*(float)i),
                    (r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*sinf(MIN_ANGLE*(float)i),
                    r*cosf(6.*MIN_ANGLE_CIRCLE*((float)j+1.))},
                    {(r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*cosf(MIN_ANGLE*(float)i),
                        (r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*sinf(MIN_ANGLE*(float)i),
                        r*cosf(6.*MIN_ANGLE_CIRCLE*((float)j+1.))},
                    {(r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*cosf(MIN_ANGLE*(float)i), (r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*sinf(MIN_ANGLE*(float)i), r*cosf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)), 1.}};
                texCoords[i*(int)MAX_VAL_CIRCLE + 6*j + 1] = {(MIN_ANGLE*(float)(i))/FULL_ANGLE, (6*MIN_ANGLE_CIRCLE*(float)(j+1))/HALF_ANGLE};
                
                
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 2] = {{(r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*cosf(MIN_ANGLE*((float)i+1.)),
                    (r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*sinf(MIN_ANGLE*((float)i+1.)),
                    r*cosf(6.*MIN_ANGLE_CIRCLE*(float)j)},
                    {(r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*cosf(MIN_ANGLE*((float)i+1.)),
                        (r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*sinf(MIN_ANGLE*((float)i+1.)),
                        r*cosf(6.*MIN_ANGLE_CIRCLE*(float)j)},
                    {(r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*cosf(MIN_ANGLE*((float)i+1.)), (r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*sinf(MIN_ANGLE*((float)i+1.)), r*cosf(6.*MIN_ANGLE_CIRCLE*(float)j), 1.}};
                texCoords[i*(int)MAX_VAL_CIRCLE + 6*j + 2] = {(MIN_ANGLE*(float)(i+1))/FULL_ANGLE, (6*MIN_ANGLE_CIRCLE*(float)(j))/HALF_ANGLE};
                
                
                
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 3] = {{(r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*cosf(MIN_ANGLE*((float)i+1.)),
                    (r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*sinf(MIN_ANGLE*((float)i+1.)),
                    r*cosf(6.*MIN_ANGLE_CIRCLE*(float)j)},
                    {(r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*cosf(MIN_ANGLE*((float)i+1.)),
                        (r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*sinf(MIN_ANGLE*((float)i+1.)),
                        r*cosf(6.*MIN_ANGLE_CIRCLE*(float)j)},
                    {(r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*cosf(MIN_ANGLE*((float)i+1.)), (r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*sinf(MIN_ANGLE*((float)i+1.)), r*cosf(6.*MIN_ANGLE_CIRCLE*(float)j), 1.}};
                texCoords[i*(int)MAX_VAL_CIRCLE + 6*j + 3] = {(MIN_ANGLE*(float)(i+1))/FULL_ANGLE, (6*MIN_ANGLE_CIRCLE*(float)(j))/HALF_ANGLE};
                
                
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 4] = {{(r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*cosf(MIN_ANGLE*(float)i),
                    (r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*sinf(MIN_ANGLE*(float)i),
                    r*cosf(6.*MIN_ANGLE_CIRCLE*((float)j+1.))},
                    {(r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*cosf(MIN_ANGLE*(float)i),
                        (r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*sinf(MIN_ANGLE*(float)i),
                        r*cosf(6.*MIN_ANGLE_CIRCLE*((float)j+1.))},
                    {(r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*cosf(MIN_ANGLE*(float)i), (r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*sinf(MIN_ANGLE*(float)i), r*cosf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)), 1.}};
                texCoords[i*(int)MAX_VAL_CIRCLE + 6*j + 4] = {(MIN_ANGLE*(float)(i))/FULL_ANGLE, (6*MIN_ANGLE_CIRCLE*(float)(j+1))/HALF_ANGLE};
                
                
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 5] = {{(r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*cosf(MIN_ANGLE*((float)i+1.)),
                    (r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*sinf(MIN_ANGLE*((float)i+1.)),
                    r*cosf(6.*MIN_ANGLE_CIRCLE*((float)j+1.))},
                    {(r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*cosf(MIN_ANGLE*((float)i+1.)),
                        (r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*sinf(MIN_ANGLE*((float)i+1.)),
                        r*cosf(6.*MIN_ANGLE_CIRCLE*((float)j+1.))},
                    {(r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*cosf(MIN_ANGLE*((float)i+1.)), (r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*sinf(MIN_ANGLE*((float)i+1.)), r*cosf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)), 1.}};
                texCoords[i*(int)MAX_VAL_CIRCLE + 6*j + 5] = {(MIN_ANGLE*(float)(i+1))/FULL_ANGLE, (6*MIN_ANGLE_CIRCLE*(float)(j+1))/HALF_ANGLE};
                
            }
        }
        
        self.textureIndexBufferSphere = [self.device newBufferWithBytes:texCoords length:sizeof(texCoords) options:MTLResourceStorageModeShared];
        self.vertexBufferSphere = [self.device newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceStorageModeShared];
        
        Vertex vertices2[45*120*2*3];
        
        for(int i=0; i<45*120*2*3; i++)
            vertices2[i] = {vertices[i].position, vertices[i].normals, {0.,0.,0.,1.}};
        
        self.vertexBufferSphereBlack = [self.device newBufferWithBytes:vertices2 length:sizeof(vertices2) options:MTLResourceStorageModeShared];
    }
    //plane
    {
        Vertex vertices[] =
        {
            {{ 0., -1., -1.}, {1., 0., 0.}, {1., 1., 0., 1.}},
            {{ 0., -1., 1.}, {1., 0., 0.}, {1., 0., 1., 1.}},
            {{ 0.,  1., 1.}, {1., 0., 0.}, {1., 1., 0., 1.}},
            
            {{ 0., -1., -1.}, {1., 0., 0.}, {1., 1., 0., 1.}},
            {{ 0., 1., -1.}, {1., 0., 0.}, {0., 1., 1., 1.}},
            {{ 0., 1., 1.}, {1., 0., 0.}, {1., 1., 0., 1.}}
        };
        
        self.vertexBufferPlane = [self.device newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceStorageModeShared];
        
        Vertex vertices2[11*6];
        
        for(int i=0; i<11; i++)
        {
            for(int j=0; j<6; j++)
            {
                vertices2[i*6+j] = {vertices[j].position-vector_float3(5./1500.)+vector_float3(i*1./1500.), vertices[j].normals, {0.,0.,0.,1.}};
            }
        }
        self.vertexBufferPlaneBlack = [self.device newBufferWithBytes:vertices2 length:sizeof(vertices2) options:MTLResourceStorageModeShared];
    }
    //cyllinder
    {
        Vertex vertices[12*12];
        
        for(int i=0; i<12; i++)
        {
            float cosVal = cosf(2.*M_PI/12.*(float)i), cosValNext = cosf(2.*M_PI/12.*(float)(i+1)), sinVal = sinf(2.*M_PI/12.*(float)i), sinValNext = sinf(2.*M_PI/12.*(float)(i+1));
            
            float pointX = cosVal*(0.5), pointY = sinVal*(0.5), pointXNext = cosValNext*(0.5), pointYNext = sinValNext*(0.5);
            
            vertices[12*i] = {{pointX, pointY, -1}, {0., 0., 0.}, {0., 1., 0., 1.}};
            vertices[12*i+1] = {{pointXNext, pointYNext, -1}, {0., 0., 0.}, {0., 1., 0., 1.}};
            vertices[12*i+2] = {{0., 0., -1}, {0., 0., -1.},{0., 1., 0., 1.}};
            
            vertices[12*i+3] = {{pointX, pointY, 1}, {0., 0., 0.}, {1., 0., 0., 1.}};
            vertices[12*i+4] = {{pointXNext, pointYNext, 1}, {0., 0., 0.}, {1., 0., 0., 1.}};
            vertices[12*i+5] = {{0., 0., 1}, {0., 0., 1.}, {1., 0., 0., 1.}};
            
            vertices[12*i+6] = {{pointX, pointY, 1}, {pointX, pointY, 0.}, {1., 0., 0., 1.}};
            vertices[12*i+7] = {{pointXNext, pointYNext, 1}, {pointXNext, pointYNext, 0.}, {1., 0., 0., 1.}};
            vertices[12*i+8] = {{pointX, pointY, -1}, {pointX, pointY, 0.}, {0., 1., 0., 1.}};
            
            vertices[12*i+9] = {{pointXNext, pointYNext, -1}, {pointXNext, pointYNext, 0.}, {0., 1., 0., 1.}};
            vertices[12*i+10] = {{pointXNext, pointYNext, 1}, {pointXNext, pointYNext, 0.}, {1., 0., 0., 1.}};
            vertices[12*i+11] = {{pointX, pointY, -1}, {pointX, pointY, 0.}, {0., 1., 0., 1.}};
            
        }
        
        self.vertexBufferCyllinder = [self.device newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceStorageModeShared];
        
        Vertex vertices2[11*12*12];
        
        for(int i=0; i<11; i++)
        {
            for(int j=0; j<144; j++)
            {
                vertices2[i*144+j] = {vertices[j].position-vector_float3(5./1500.)+vector_float3(i*1./1500.), vertices[j].normals, {0.,0.,0.,1.}};
            }
        }
        self.vertexBufferCyllinderBlack = [self.device newBufferWithBytes:vertices2 length:sizeof(vertices2) options:MTLResourceStorageModeShared];
    }
    //Torus
    {
        Vertex vertices[60*90*2*3];
        
        float MAX_VAL = 90;
        float MAX_VAL_CIRCLE = 90;
        
        float r = 0.5, R = 0.8;
        
        float MIN_THETA_ANGLE = M_PI/45., MIN_PHI_ANGLE = M_PI/45.;
        
        vector_float2 texCoords[60*90*2*3];
        float FULL_ANGLE = 2.*M_PI;
        
        for(int i=0; i<MAX_VAL; i++)
        {
            for(int j=0; j<(MAX_VAL_CIRCLE)/6; j++)
            {
                
                
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j] = {{(R+r*cosf(6.*MIN_THETA_ANGLE*(float)j))*cosf(MIN_PHI_ANGLE*(float)i),
                    (R+r*cosf(6.*MIN_THETA_ANGLE*(float)j))*sinf(MIN_PHI_ANGLE*(float)i),
                    r*sinf(6.*MIN_THETA_ANGLE*(float)j)},
                    calculateNormalToTorus(0.5, 0.8, 6.*MIN_THETA_ANGLE*(float)j, MIN_PHI_ANGLE*(float)i),
                    {1., 0., 0., 1.}};
                texCoords[i*(int)MAX_VAL_CIRCLE + 6*j + 0] = {MIN_PHI_ANGLE*(float)i/FULL_ANGLE, (float)6.*MIN_THETA_ANGLE*(float)j/FULL_ANGLE};
                
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 1] = {{(R+r*cosf(6.*MIN_THETA_ANGLE*((float)j+1.)))*cosf(MIN_PHI_ANGLE*(float)i),
                    (R+r*cosf(6.*MIN_THETA_ANGLE*((float)j+1.)))*sinf(MIN_PHI_ANGLE*(float)i),
                    r*sinf(6.*MIN_THETA_ANGLE*((float)j+1.))},
                    calculateNormalToTorus(0.5, 0.8, 6.*MIN_THETA_ANGLE*((float)j+1.), MIN_PHI_ANGLE*(float)i),
                    {1., 0., 0., 1.}};
                texCoords[i*(int)MAX_VAL_CIRCLE + 6*j + 1] = {MIN_PHI_ANGLE*(float)i/FULL_ANGLE, (float)6.*MIN_THETA_ANGLE*(float)(j+1)/FULL_ANGLE};
                
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 2] = {{(R+r*cosf(6.*MIN_THETA_ANGLE*(float)j))*cosf(MIN_PHI_ANGLE*((float)i+1.)),
                    (R+r*cosf(6.*MIN_THETA_ANGLE*(float)j))*sinf(MIN_PHI_ANGLE*((float)i+1.)),
                    r*sinf(6.*MIN_THETA_ANGLE*(float)j)},
                    calculateNormalToTorus(0.5, 0.8, 6.*MIN_THETA_ANGLE*(float)j, MIN_PHI_ANGLE*((float)i+1.)),
                    {1., 0., 0., 1.}};
                texCoords[i*(int)MAX_VAL_CIRCLE + 6*j + 2] = {MIN_PHI_ANGLE*(float)(i+1)/FULL_ANGLE, (float)6.*MIN_THETA_ANGLE*(float)j/FULL_ANGLE};
                
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 3] = {{(R+r*cosf(6.*MIN_THETA_ANGLE*(float)j))*cosf(MIN_PHI_ANGLE*((float)i+1.)),
                    (R+r*cosf(6.*MIN_THETA_ANGLE*(float)j))*sinf(MIN_PHI_ANGLE*((float)i+1.)),
                    r*sinf(6.*MIN_THETA_ANGLE*(float)j)},
                    calculateNormalToTorus(0.5, 0.8, 6.*MIN_THETA_ANGLE*(float)j, MIN_PHI_ANGLE*((float)i+1.)),
                    {0., 1., 0., 1.}};
                texCoords[i*(int)MAX_VAL_CIRCLE + 6*j + 3] = {MIN_PHI_ANGLE*(float)(i+1)/FULL_ANGLE, (float)6.*MIN_THETA_ANGLE*(float)j/FULL_ANGLE};
                
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 4] = {{(R+r*cosf(6.*MIN_THETA_ANGLE*((float)j+1.)))*cosf(MIN_PHI_ANGLE*(float)i),
                    (R+r*cosf(6.*MIN_THETA_ANGLE*((float)j+1.)))*sinf(MIN_PHI_ANGLE*(float)i),
                    r*sinf(6.*MIN_THETA_ANGLE*((float)j+1.))},
                    calculateNormalToTorus(0.5, 0.8, 6.*MIN_THETA_ANGLE*((float)j+1.), MIN_PHI_ANGLE*(float)i),
                    {0., 1., 0., 1.}};
                texCoords[i*(int)MAX_VAL_CIRCLE + 6*j + 4] = {MIN_PHI_ANGLE*(float)i/FULL_ANGLE, (float)6.*MIN_THETA_ANGLE*(float)(j+1)/FULL_ANGLE};
                
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 5] = {{(R+r*cosf(6.*MIN_THETA_ANGLE*((float)j+1.)))*cosf(MIN_PHI_ANGLE*((float)i+1.)),
                    (R+r*cosf(6.*MIN_THETA_ANGLE*((float)j+1.)))*sinf(MIN_PHI_ANGLE*((float)i+1.)),
                    r*sinf(6.*MIN_THETA_ANGLE*((float)j+1.))},
                    calculateNormalToTorus(0.5, 0.8, 6.*MIN_THETA_ANGLE*((float)j+1.), MIN_PHI_ANGLE*((float)i+1.)),
                    {0., 1., 0., 1.}};
                texCoords[i*(int)MAX_VAL_CIRCLE + 6*j + 5] = {MIN_PHI_ANGLE*(float)(i+1)/FULL_ANGLE, (float)6.*MIN_THETA_ANGLE*(float)(j+1)/FULL_ANGLE};
            }
        }
        
        self.textureIndexBufferTorus = [self.device newBufferWithBytes:texCoords length:sizeof(texCoords) options:MTLResourceStorageModeShared];
        self.vertexBufferTorus = [self.device newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceStorageModeShared];
        
        Vertex vertices2[60*90*2*3];
        
        for(int i=0; i<60*90*2*3; i++)
        {
            vertices2[i] = {vertices[i].position, vertices[i].normals, {0.,0.,0.,1.}};
        }
        
        self.vertexBufferTorusBlack = [self.device newBufferWithBytes:vertices2 length:sizeof(vertices2) options:MTLResourceStorageModeShared];
        
    }
    //Human
    {
        Vertex verticesHuman[10000];
        uint indexesHuman[10000];
    
        NSString *filePath = @"x.obj";
        NSError *error;
        NSString *objData = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];

        if (error) {
            NSLog(@"Failed to open the .obj file: %@", error.localizedDescription);
        }


        int vertex_count = 0;
        int triangle_count = 0;

        NSArray *lines = [objData componentsSeparatedByString:@"\n"];
        for (NSString *line in lines) {
            NSString *prefix;
            NSScanner *scanner = [NSScanner scannerWithString:line];
            [scanner scanUpToString:@" " intoString:&prefix];
            
            if ([prefix isEqualToString:@"v"]) {
                // Parse vertex coordinates
                if (vertex_count < 10000) {
                    float x, y, z;
                    [scanner scanFloat:&x];
                    [scanner scanFloat:&y];
                    [scanner scanFloat:&z];
                    verticesHuman[vertex_count] = {{x/(float)20., y/(float)20., z/(float)20.}, {1., 0., 0.}, {1., 0., 0., 1.}};
                    vertex_count++;
                }
            } else if ([prefix isEqualToString:@"f"]) {
                // Parse face data (indexes)
                if (triangle_count < 10000) {
                    int v1, v2, v3;
                    [scanner scanInt:&v1];
                    [scanner scanInt:&v2];
                    [scanner scanInt:&v3];
                    indexesHuman[3*triangle_count] = v1;
                    indexesHuman[3*triangle_count+1] = v2;
                    indexesHuman[3*triangle_count+2]= v3;
                    triangle_count++;
                }
            }
        }
        
        for(int i=0; i<sizeof(verticesHuman)/sizeof(*verticesHuman); i++)
        {
            verticesHuman[i].position.z /= 20.;
            verticesHuman[i].position.x /= 20.;
            verticesHuman[i].position.y /= 20.;
        }
        
        self.vertexBufferHuman = [self.device newBufferWithBytes:verticesHuman length:sizeof(verticesHuman) options:MTLResourceStorageModeShared];
        self.indexBufferHuman = [self.device newBufferWithBytes:indexesHuman length:sizeof(indexesHuman) options:MTLResourceStorageModeShared];
    }
    
    [self.view addSubview:self.metalView];
    self.textureCube = [self loadTextureWithImageNamed:@"minecraft_dirt"];
    self.textureSphere = [self loadTextureWithImageNamed:@"ball2"];
    self.textureTorus = [self loadTextureWithImageNamed:@"torus"];
}



- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (IBAction)showLightOptionBox:(id)sender {
    if([[self.comboboxLightOnOff stringValue] isEqualToString:@"On"]) [self.comboboxLightType setHidden:NO];
    else [self.comboboxLightType setHidden:YES];
}

- (IBAction)updateTexture:(id)sender {
    if([[self.comboCubeTexture stringValue] isEqualToString:@"Minecraft"]) self.textureCube = [self loadTextureWithImageNamed:@"minecraft_dirt"];
    if([[self.comboCubeTexture stringValue] isEqualToString:@"Gossling"]) self.textureCube = [self loadTextureWithImageNamed:@"gossling"];
    if([[self.comboCubeTexture stringValue] isEqualToString:@"Paradise"]) self.textureCube = [self loadTextureWithImageNamed:@"cubemap"];
    if([[self.comboCubeTexture stringValue] isEqualToString:@"Future"]) self.textureCube = [self loadTextureWithImageNamed:@"cubemap2"];
    if([[self.comboCubeTexture stringValue] isEqualToString:@"White"]) self.textureCube = [self loadTextureWithImageNamed:@"white"];
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
    [self.verticesOnOff setState:NO];
    [self.annimationOnOff setState:NO];
    [self.animTransOnOff setState:NO];
    [self.animScaleOnOff setState:NO];
    [self.testureOnOff setState:NO];
}


- (IBAction)animationActivated:(id)sender {
   
}

- (IBAction)textureActivated:(id)sender {
    if([self.testureOnOff state] == YES && [[self.comboBox stringValue] isEqualToString:@"Cube"]) [self.comboCubeTexture setHidden:NO];
    else [self.comboCubeTexture setHidden:YES];
}


static float factorX = 1.;
static float factorY = -1.;
static float factorZ = 1.;

static float factorScaleX = 1.;
static float factorScaleY = -1.;
static float factorScaleZ = 1.;

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
    
    float animSpeed = [self.animSpeed floatValue];
    
    if([self.annimationOnOff state] == YES)
    {
        if([self.m_RotationXSlider floatValue] >= 360.) [self.m_RotationXSlider setFloatValue:0.];
        if([self.m_RotationYSlider floatValue] <= 0.) [self.m_RotationYSlider setFloatValue:360.];
        if([self.m_RotationZSlider floatValue] >= 360.) [self.m_RotationZSlider setFloatValue:0.];
        
        [self.m_RotationXSlider setFloatValue:[self.m_RotationXSlider floatValue] + 0.5*animSpeed/10.];
        [self.m_RotationYSlider setFloatValue:[self.m_RotationYSlider floatValue] - 1.0*animSpeed/10.];
        [self.m_RotationZSlider setFloatValue:[self.m_RotationZSlider floatValue] + 0.7*animSpeed/10.];
    }
    
    if([self.animTransOnOff state] == YES)
    {
        if([self.m_TransXSlider floatValue] >= 18. || [self.m_TransXSlider floatValue] <= -18.) factorX *= -1;
        if([self.m_TransYSlider floatValue] >= 18. || [self.m_TransYSlider floatValue] <= -18.) factorY *= -1;
        if([self.m_TransZSlider floatValue] >= 18. || [self.m_TransZSlider floatValue] <= -18.) factorZ *= -1;
        
        [self.m_TransXSlider setFloatValue:[self.m_TransXSlider floatValue] + 0.5/20.*animSpeed*factorX];
        [self.m_TransYSlider setFloatValue:[self.m_TransYSlider floatValue] + 1.0/20.*animSpeed*factorY];
//        [self.m_TransZSlider setFloatValue:[self.m_TransZSlider floatValue] + 0.7/20.*animSpeed*factorZ];
    }
    
    if([self.animScaleOnOff state] == YES)
    {
        if([self.m_ScaleXSlider floatValue] >= 200. || [self.m_ScaleXSlider floatValue] <= 50.) factorScaleX *= -1;
        if([self.m_ScaleYSlider floatValue] >= 200. || [self.m_ScaleYSlider floatValue] <= 50.) factorScaleY *= -1;
        if([self.m_ScaleZSlider floatValue] >= 200. || [self.m_ScaleZSlider floatValue] <= 50.) factorScaleZ *= -1;
        
        [self.m_ScaleXSlider setFloatValue:[self.m_ScaleXSlider floatValue] + 0.5/20.*animSpeed*factorScaleX];
        [self.m_ScaleYSlider setFloatValue:[self.m_ScaleYSlider floatValue] + 0.5/20.*animSpeed*factorScaleY];
//        [self.m_ScaleZSlider setFloatValue:[self.m_ScaleZSlider floatValue] + 0.5/20.*animSpeed*factorScaleZ];
    }
    
    
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
        
    
    
    bool isPlot[2] = {true, false};
    
    MTLDepthStencilDescriptor *depthDescriptor = [MTLDepthStencilDescriptor new];
    depthDescriptor.depthCompareFunction = MTLCompareFunctionLessEqual;
    depthDescriptor.depthWriteEnabled = YES;
    id<MTLDepthStencilState> depthState = [_device newDepthStencilStateWithDescriptor:depthDescriptor];
    
    id<MTLCommandBuffer> commandBuffer = [self.device newCommandQueue].commandBuffer;
    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
//    renderPassDescriptor.colorAttachments[0].texture = self.texture;
//    view.currentRenderPassDescriptor.depthAttachment.storeAction = MTLStoreActionStore;

    float dzielAll = 1., dzielPos = 256.;
    
    struct PointLight punctualLight = {
        {[self.pointPosX floatValue]/dzielAll, -[self.pointPosY floatValue]/dzielAll, [self.pointPosZ floatValue]/dzielAll},
        {[self.pointColR floatValue]/dzielPos, [self.pointColG floatValue]/dzielPos, [self.pointColB floatValue]/dzielPos},
        [self.pointInten floatValue],
        [self.pointConst floatValue],
        [self.poinntLin floatValue],
        [self.pointQuad floatValue]
    };
    
    struct DirectionalLight directionalLight {
        {-[self.dirDX floatValue], -[self.dirDY floatValue], -[self.dirDZ floatValue]},
        {[self.dirCR floatValue]/dzielPos, [self.dirCG floatValue]/dzielPos, [self.dirCB floatValue]/dzielPos}
    };

    struct Material material {
        {[self.dirACR floatValue]/dzielPos, [self.dirACG floatValue]/dzielPos, [self.dirACB floatValue]/dzielPos},
        {[self.dirDCR floatValue]/dzielPos, [self.dirDCG floatValue]/dzielPos, [self.dirDCB floatValue]/dzielPos},
        {[self.dirSCR floatValue]/dzielPos, [self.dirSCG floatValue]/dzielPos, [self.dirSCB floatValue]/dzielPos},
        [self.dirInt floatValue]
    };
    
    renderPassDescriptor.depthAttachment.storeAction = MTLStoreActionStore;
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [renderEncoder setRenderPipelineState:self.pipelineState];
    [renderEncoder setDepthStencilState:depthState];
    
    [renderEncoder setVertexBytes:angles length:sizeof(float)*4 atIndex:RotationAngles];
    [renderEncoder setVertexBytes:scale length:sizeof(float)*4 atIndex:ScaleFactors];
    [renderEncoder setVertexBytes:translation length:sizeof(float)*4 atIndex:TranslationFactors];
    [renderEncoder setVertexBytes:projPos length:sizeof(float)*4 atIndex:ProjectionDirections];
    [renderEncoder setVertexBytes:nearFar length:sizeof(float)*2 atIndex:NearFar];
    [renderEncoder setVertexBuffer:self.indexBuffer offset:0 atIndex:IndexesBuffer];
    [renderEncoder setVertexBuffer:self.colorIndexBuffer offset:0 atIndex:ColorIndexBuffer];
    [renderEncoder setVertexBuffer:self.textureIndexBufferCube offset:0 atIndex:TextureCoords];
    [renderEncoder setVertexBuffer:self.normalsIndexBuffer offset:0 atIndex:NormalsIndexBuffer];
    [renderEncoder setVertexBytes:&isPlot length:sizeof(bool)*2 atIndex:PlotOnOff];
    [renderEncoder setVertexBuffer:[self.device newBufferWithBytes:lines length:sizeof(lines) options:MTLResourceStorageModeShared] offset:0 atIndex:MainBuffer];
    
    int lightType = 0;
    if([[self.comboboxLightOnOff stringValue] isEqualToString:@"Off"])
    {
        [self.customView setHidden:YES];
        [self.dirCustomView setHidden:YES];
        [renderEncoder setFragmentBytes:&lightType length:sizeof(int) atIndex:FragmentLightType];
    }
    else
    {
        if([[self.comboboxLightType stringValue] isEqualToString:@"Punctual"])
        {
            [self.customView setHidden:NO];
            [self.dirCustomView setHidden:YES];
            lightType = 1;
            [renderEncoder setFragmentBytes:&lightType length:sizeof(int) atIndex:FragmentLightType];
        }
        else
        {
            [self.customView setHidden:YES];
            [self.dirCustomView setHidden:NO];
            lightType = 2;
            [renderEncoder setFragmentBytes:&lightType length:sizeof(int) atIndex:FragmentLightType];
        }
    }
    [renderEncoder setFragmentBytes:&punctualLight length:sizeof(punctualLight) atIndex:PointLight];
    [renderEncoder setFragmentBytes:&directionalLight length:sizeof(directionalLight) atIndex:DirectionalLight];
    [renderEncoder setFragmentBytes:&material length:sizeof(material) atIndex:Material];
    [renderEncoder setFragmentTexture:self.textureCube atIndex:FragmentTexture];
    
    bool indexMode = false;
    [renderEncoder setVertexBytes:&indexMode length:sizeof(bool) atIndex:DrawWithIndexes];
    
    bool useTexture = false;
    [renderEncoder setFragmentBytes:&useTexture length:sizeof(bool) atIndex:UseTexture];
    
    [renderEncoder drawPrimitives:MTLPrimitiveTypeLine vertexStart:0 vertexCount:6];
    
    isPlot[0] = false;
    [renderEncoder setVertexBytes:&isPlot length:sizeof(bool)*2 atIndex:PlotOnOff];
    
    if([[self.comboBox stringValue] isEqualToString:@"Cube"])
    {
        useTexture = [self.testureOnOff state];
        [renderEncoder setFragmentBytes:&useTexture length:sizeof(bool) atIndex:UseTexture];
        indexMode = true;
        [renderEncoder setVertexBytes:&indexMode length:sizeof(bool) atIndex:DrawWithIndexes];
        [renderEncoder setVertexBuffer:self.vertexBufferCube offset:0 atIndex:MainBuffer];
        [renderEncoder setVertexBuffer:self.normalsIndexBuffer offset:0 atIndex:NormalsIndexBuffer];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:36];
        
        if([self.verticesOnOff state] == YES)
        {
            [renderEncoder setTriangleFillMode:MTLTriangleFillModeLines];
            [renderEncoder setVertexBuffer:self.vertexBufferCubeBlack offset:0 atIndex:MainBuffer];
            [renderEncoder setVertexBuffer:self.indexBufferBlack offset:0 atIndex:IndexesBuffer];
            [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:11*36];
        }
        
    }
    else if([[self.comboBox stringValue] isEqualToString:@"Sphere"])
    {
        useTexture = [self.testureOnOff state];
        [renderEncoder setFragmentBytes:&useTexture length:sizeof(bool) atIndex:UseTexture];
        
        indexMode = false;
        [renderEncoder setVertexBytes:&indexMode length:sizeof(bool) atIndex:DrawWithIndexes];
        [renderEncoder setVertexBuffer:self.vertexBufferSphere offset:0 atIndex:MainBuffer];
        [renderEncoder setFragmentTexture:self.textureSphere atIndex:FragmentTexture];
        [renderEncoder setVertexBuffer:self.textureIndexBufferSphere offset:0 atIndex:TextureCoords];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:42*120*2*3];
        
        if([self.verticesOnOff state] == YES)
        {
            isPlot[1] = false;
            [renderEncoder setVertexBytes:&isPlot length:sizeof(bool)*2 atIndex:PlotOnOff];
            [renderEncoder setTriangleFillMode:MTLTriangleFillModeLines];
            [renderEncoder setVertexBuffer:self.vertexBufferSphereBlack offset:0 atIndex:MainBuffer];
            [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:42*120*2*3];
        }
    }
    else if([[self.comboBox stringValue] isEqualToString:@"Plane"])
    {
        indexMode = false;
        [renderEncoder setVertexBytes:&indexMode length:sizeof(bool) atIndex:DrawWithIndexes];
        
        useTexture = false;
        [renderEncoder setFragmentBytes:&useTexture length:sizeof(bool) atIndex:UseTexture];
        
        vector_float2 texCoords[] = {
            {0., 0.}, {0., 1.}, {1., 1.},
            {0., 0.}, {1., 0.}, {1., 1.}
        };
        [renderEncoder setVertexBuffer:[self.device newBufferWithBytes:texCoords length:sizeof(texCoords) options:MTLResourceStorageModeShared] offset:0 atIndex:TextureCoords];
        [renderEncoder setVertexBuffer:self.vertexBufferPlane offset:0 atIndex:MainBuffer];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
        
        if([self.verticesOnOff state] == YES)
        {
            [renderEncoder setTriangleFillMode:MTLTriangleFillModeLines];
            [renderEncoder setVertexBuffer:self.vertexBufferPlaneBlack offset:0 atIndex:MainBuffer];
            [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:11*6];
        }
    }
    else if([[self.comboBox stringValue] isEqualToString:@"Cyllinder"])
    {
        useTexture = false;
        [renderEncoder setFragmentBytes:&useTexture length:sizeof(bool) atIndex:UseTexture];
        indexMode = false;
        [renderEncoder setVertexBytes:&indexMode length:sizeof(bool) atIndex:DrawWithIndexes];
        [renderEncoder setVertexBuffer:self.vertexBufferCyllinder offset:0 atIndex:MainBuffer];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:12*12];
        if([self.verticesOnOff state] == YES)
        {
            [renderEncoder setTriangleFillMode:MTLTriangleFillModeLines];
            [renderEncoder setVertexBuffer:self.vertexBufferCyllinderBlack offset:0 atIndex:MainBuffer];
            [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:11*12*12];
        }
        
    }
    else if([[self.comboBox stringValue] isEqualToString:@"Torus"])
    {
        useTexture = [self.testureOnOff state];
        [renderEncoder setFragmentBytes:&useTexture length:sizeof(bool) atIndex:UseTexture];
        indexMode = false;
        [renderEncoder setVertexBytes:&indexMode length:sizeof(bool) atIndex:DrawWithIndexes];
        isPlot[1] = true;
        [renderEncoder setVertexBytes:&isPlot length:sizeof(bool)*2 atIndex:PlotOnOff];
        [renderEncoder setVertexBuffer:self.vertexBufferTorus offset:0 atIndex:MainBuffer];
        [renderEncoder setVertexBuffer:self.textureIndexBufferTorus offset:0 atIndex:TextureCoords];
        [renderEncoder setFragmentTexture:self.textureTorus atIndex:FragmentTexture];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:60*90*2*3];
        
        if([self.verticesOnOff state] == YES)
        {
            isPlot[1] = false;
            [renderEncoder setVertexBytes:&isPlot length:sizeof(bool)*2 atIndex:PlotOnOff];
            [renderEncoder setTriangleFillMode:MTLTriangleFillModeLines];
            [renderEncoder setVertexBuffer:self.vertexBufferTorusBlack offset:0 atIndex:MainBuffer];
            [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:60*90*2*3];
        }
    }
    if([[self.comboBox stringValue] isEqualToString:@"Human"])
    {
        useTexture = false;
        [renderEncoder setFragmentBytes:&useTexture length:sizeof(bool) atIndex:UseTexture];
        indexMode = true;
        
        [renderEncoder setVertexBytes:&indexMode length:sizeof(bool) atIndex:DrawWithIndexes];
        [renderEncoder setVertexBuffer:self.vertexBufferHuman offset:0 atIndex:MainBuffer];
        [renderEncoder setVertexBuffer:self.indexBufferHuman offset:0 atIndex:NormalsIndexBuffer];
        [renderEncoder setVertexBuffer:self.indexBufferHuman offset:0 atIndex:IndexesBuffer];
        [renderEncoder setVertexBuffer:self.indexBufferHuman offset:0 atIndex:ColorIndexBuffer];
//        [renderEncoder setVertexBuffer:self.indexBufferHuman offset:0 atIndex:TextureCoords]
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:282];
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



-(void)mouseDown:(NSEvent *)event
{
    float tx =  [event locationInWindow].x, ty =  [event locationInWindow].y;
    if(tx>=44. && tx<=44.+766. && ty>=20. && ty<=20.+766.)
    {
        [self.progressCircle setIndeterminate:YES];
        [self.progressCircle setUsesThreadedAnimation:YES];
        [self.progressCircle startAnimation:nil];
        [self.progressCircle setHidden:NO];
    }
}

-(void)mouseUp:(NSEvent *)event
{
    float tx =  [event locationInWindow].x, ty =  [event locationInWindow].y;
    if(tx>=44. && tx<=44.+766. && ty>=20. && ty<=20.+766.)
    {
        [self.progressCircle stopAnimation:nil];
        [self.progressCircle setHidden:YES];
    }
}

-(void)mouseDragged:(NSEvent *)event
{
    NSLog(@"|x drag");
    if(false)
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
