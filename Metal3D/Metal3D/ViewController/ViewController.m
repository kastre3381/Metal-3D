#import "ViewController.h"

@implementation ViewController

vector_float3 calculateNormalToTorus(float rin, float rout, float iangle, float jangle)
{
    float vx = cos(jangle)*(rout+cos(iangle)*rin);
    float vy = sin(jangle)*(rout+cos(iangle)*rin);
    float vz = sin(iangle)*rin;
    /* tangent vector with respect to big circle */
    float tx = -sin(jangle);
    float ty = cos(jangle);
    float tz = 0;
    /* tangent vector with respect to little circle */
    float sx = cos(jangle)*(-sin(iangle));
    float sy = sin(jangle)*(-sin(iangle));
    float sz = cos(iangle);
    /* normal is cross-product of tangents */
    float nx = ty*sz - tz*sy;
    float ny = tz*sx - tx*sz;
    float nz = tx*sy - ty*sx;
    /* normalize normal */
    float length = sqrt(nx*nx + ny*ny + nz*nz);
    nx /= length;
    ny /= length;
    nz /= length;
    
    return {nx,ny,nz};
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
    
    //cube
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
        self.vertexBufferCube = [self.device newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceStorageModeShared];
        
        Vertex vertices2[11*36];
        
        for(int i=0; i<11; i++)
        {
            for(int j=0; j<36; j++)
            {
                vertices2[i*36+j] = {vertices[j].position-vector_float3(5./1500.)+vector_float3(i*1./1500.), vertices[j].normals, {0.,0.,0.,1.}};
            }
        }
        self.vertexBufferCubeBlack = [self.device newBufferWithBytes:vertices2 length:sizeof(vertices2) options:MTLResourceStorageModeShared];
    }
    //sphere
    {
        Vertex vertices[45*120*2*3];
        
        float MAX_VAL = 45;
        float MAX_VAL_CIRCLE = 120;
        float r = 0.8;
        float MIN_ANGLE_CIRCLE = 2.*M_PI/MAX_VAL_CIRCLE;
        float MIN_ANGLE = 2.*M_PI/MAX_VAL;
        
        
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
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 1] = {{(r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*cosf(MIN_ANGLE*(float)i),
                                                              (r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*sinf(MIN_ANGLE*(float)i),
                                                              r*cosf(6.*MIN_ANGLE_CIRCLE*((float)j+1.))},
                    {(r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*cosf(MIN_ANGLE*(float)i),
                                                                  (r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*sinf(MIN_ANGLE*(float)i),
                                                                  r*cosf(6.*MIN_ANGLE_CIRCLE*((float)j+1.))},
                                                              {(r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*cosf(MIN_ANGLE*(float)i), (r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*sinf(MIN_ANGLE*(float)i), r*cosf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)), 1.}};
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 2] = {{(r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*cosf(MIN_ANGLE*((float)i+1.)),
                                                          (r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*sinf(MIN_ANGLE*((float)i+1.)),
                                                          r*cosf(6.*MIN_ANGLE_CIRCLE*(float)j)},
                    {(r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*cosf(MIN_ANGLE*((float)i+1.)),
                                                              (r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*sinf(MIN_ANGLE*((float)i+1.)),
                                                              r*cosf(6.*MIN_ANGLE_CIRCLE*(float)j)},
                                                          {(r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*cosf(MIN_ANGLE*((float)i+1.)), (r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*sinf(MIN_ANGLE*((float)i+1.)), r*cosf(6.*MIN_ANGLE_CIRCLE*(float)j), 1.}};
                
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 3] = {{(r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*cosf(MIN_ANGLE*((float)i+1.)),
                                                          (r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*sinf(MIN_ANGLE*((float)i+1.)),
                                                          r*cosf(6.*MIN_ANGLE_CIRCLE*(float)j)},
                    {(r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*cosf(MIN_ANGLE*((float)i+1.)),
                                                              (r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*sinf(MIN_ANGLE*((float)i+1.)),
                                                              r*cosf(6.*MIN_ANGLE_CIRCLE*(float)j)},
                                                          {(r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*cosf(MIN_ANGLE*((float)i+1.)), (r*sinf(6.*MIN_ANGLE_CIRCLE*(float)j))*sinf(MIN_ANGLE*((float)i+1.)), r*cosf(6.*MIN_ANGLE_CIRCLE*(float)j), 1.}};
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 4] = {{(r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*cosf(MIN_ANGLE*(float)i),
                                                              (r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*sinf(MIN_ANGLE*(float)i),
                                                              r*cosf(6.*MIN_ANGLE_CIRCLE*((float)j+1.))},
                    {(r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*cosf(MIN_ANGLE*(float)i),
                                                                  (r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*sinf(MIN_ANGLE*(float)i),
                                                                  r*cosf(6.*MIN_ANGLE_CIRCLE*((float)j+1.))},
                                                              {(r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*cosf(MIN_ANGLE*(float)i), (r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*sinf(MIN_ANGLE*(float)i), r*cosf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)), 1.}};
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 5] = {{(r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*cosf(MIN_ANGLE*((float)i+1.)),
                                                              (r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*sinf(MIN_ANGLE*((float)i+1.)),
                                                              r*cosf(6.*MIN_ANGLE_CIRCLE*((float)j+1.))},
                    {(r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*cosf(MIN_ANGLE*((float)i+1.)),
                                                                  (r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*sinf(MIN_ANGLE*((float)i+1.)),
                                                                  r*cosf(6.*MIN_ANGLE_CIRCLE*((float)j+1.))},
                                                              {(r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*cosf(MIN_ANGLE*((float)i+1.)), (r*sinf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)))*sinf(MIN_ANGLE*((float)i+1.)), r*cosf(6.*MIN_ANGLE_CIRCLE*((float)j+1.)), 1.}};
            }
        }
        
        for(int i=0; i<MAX_VAL; i++)
        {
            vertices[i*(int)MAX_VAL_CIRCLE] = {{0., 0., r}, {0., 0., r}, {0., 0., r, 1.}};
            vertices[i*(int)MAX_VAL_CIRCLE + 1] = {{(r*sinf(6.*MIN_ANGLE_CIRCLE*(1.)))*cosf(MIN_ANGLE*(float)i),
                                                          (r*sinf(6.*MIN_ANGLE_CIRCLE*(1.)))*sinf(MIN_ANGLE*(float)i),
                                                          r*cosf(6.*MIN_ANGLE_CIRCLE*(1.))},
                {(r*sinf(6.*MIN_ANGLE_CIRCLE*(1.)))*cosf(MIN_ANGLE*(float)i),
                                                              (r*sinf(6.*MIN_ANGLE_CIRCLE*(1.)))*sinf(MIN_ANGLE*(float)i),
                                                              r*cosf(6.*MIN_ANGLE_CIRCLE*(1.))},
                                                          {(r*sinf(6.*MIN_ANGLE_CIRCLE*(1.)))*cosf(MIN_ANGLE*(float)i), (r*sinf(6.*MIN_ANGLE_CIRCLE*(1.)))*sinf(MIN_ANGLE*(float)i), r*cosf(6.*MIN_ANGLE_CIRCLE*(1.)), 1.}};
            vertices[i*(int)MAX_VAL_CIRCLE + 2] = {{(r*sinf(6.*MIN_ANGLE_CIRCLE))*cosf(MIN_ANGLE*((float)i+1.)),
                                                      (r*sinf(6.*MIN_ANGLE_CIRCLE))*sinf(MIN_ANGLE*((float)i+1.)),
                                                      r*cosf(6.*MIN_ANGLE_CIRCLE)},
                {(r*sinf(6.*MIN_ANGLE_CIRCLE))*cosf(MIN_ANGLE*((float)i+1.)),
                                                          (r*sinf(6.*MIN_ANGLE_CIRCLE))*sinf(MIN_ANGLE*((float)i+1.)),
                                                          r*cosf(6.*MIN_ANGLE_CIRCLE)},
                                                      {(r*sinf(6.*MIN_ANGLE_CIRCLE))*cosf(MIN_ANGLE*((float)i+1.)), (r*sinf(6.*MIN_ANGLE_CIRCLE))*sinf(MIN_ANGLE*((float)i+1.)), r*cosf(6.*MIN_ANGLE_CIRCLE), 1.}};
            
            vertices[i*(int)MAX_VAL_CIRCLE + 3].position = {0., 0., 0.};
            vertices[i*(int)MAX_VAL_CIRCLE + 4].position = {0.,0.,0.};
            vertices[i*(int)MAX_VAL_CIRCLE + 5].position = {0.,0.,0.};
        }
        
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
        Vertex vertices[90*90*2*3];
        
        float MAX_VAL = 90;
        float MAX_VAL_CIRCLE = 90;
        
        float r = 0.5, R = 0.8;
        
        float MIN_THETA_ANGLE = M_PI/45., MIN_PHI_ANGLE = M_PI/45.;
        for(int i=0; i<MAX_VAL; i++)
        {
            for(int j=0; j<(MAX_VAL_CIRCLE)/6; j++)
            {

                
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j] = {{(R+r*cosf(6.*MIN_THETA_ANGLE*(float)j))*cosf(MIN_PHI_ANGLE*(float)i),
                                                          (R+r*cosf(6.*MIN_THETA_ANGLE*(float)j))*sinf(MIN_PHI_ANGLE*(float)i),
                                                          r*sinf(6.*MIN_THETA_ANGLE*(float)j)},
                                                          calculateNormalToTorus(0.5, 0.8, 6.*MIN_THETA_ANGLE*(float)j, MIN_PHI_ANGLE*(float)i),
                                                          {1., 0., 0., 1.}};
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 1] = {{(R+r*cosf(6.*MIN_THETA_ANGLE*((float)j+1.)))*cosf(MIN_PHI_ANGLE*(float)i),
                                                              (R+r*cosf(6.*MIN_THETA_ANGLE*((float)j+1.)))*sinf(MIN_PHI_ANGLE*(float)i),
                                                              r*sinf(6.*MIN_THETA_ANGLE*((float)j+1.))},
                                                              calculateNormalToTorus(0.5, 0.8, 6.*MIN_THETA_ANGLE*((float)j+1.), MIN_PHI_ANGLE*(float)i),
                                                              {1., 0., 0., 1.}};
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 2] = {{(R+r*cosf(6.*MIN_THETA_ANGLE*(float)j))*cosf(MIN_PHI_ANGLE*((float)i+1.)),
                                                          (R+r*cosf(6.*MIN_THETA_ANGLE*(float)j))*sinf(MIN_PHI_ANGLE*((float)i+1.)),
                                                          r*sinf(6.*MIN_THETA_ANGLE*(float)j)},
                                                          calculateNormalToTorus(0.5, 0.8, 6.*MIN_THETA_ANGLE*(float)j, MIN_PHI_ANGLE*((float)i+1.)),
                                                          {1., 0., 0., 1.}};
                
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 3] = {{(R+r*cosf(6.*MIN_THETA_ANGLE*(float)j))*cosf(MIN_PHI_ANGLE*((float)i+1.)),
                                                          (R+r*cosf(6.*MIN_THETA_ANGLE*(float)j))*sinf(MIN_PHI_ANGLE*((float)i+1.)),
                                                          r*sinf(6.*MIN_THETA_ANGLE*(float)j)},
                                                          calculateNormalToTorus(0.5, 0.8, 6.*MIN_THETA_ANGLE*(float)j, MIN_PHI_ANGLE*((float)i+1.)),
                                                          {0., 1., 0., 1.}};
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 4] = {{(R+r*cosf(6.*MIN_THETA_ANGLE*((float)j+1.)))*cosf(MIN_PHI_ANGLE*(float)i),
                                                              (R+r*cosf(6.*MIN_THETA_ANGLE*((float)j+1.)))*sinf(MIN_PHI_ANGLE*(float)i),
                                                              r*sinf(6.*MIN_THETA_ANGLE*((float)j+1.))},
                                                              calculateNormalToTorus(0.5, 0.8, 6.*MIN_THETA_ANGLE*((float)j+1.), MIN_PHI_ANGLE*(float)i),
                                                              {0., 1., 0., 1.}};
                vertices[i*(int)MAX_VAL_CIRCLE + 6*j + 5] = {{(R+r*cosf(6.*MIN_THETA_ANGLE*((float)j+1.)))*cosf(MIN_PHI_ANGLE*((float)i+1.)),
                                                              (R+r*cosf(6.*MIN_THETA_ANGLE*((float)j+1.)))*sinf(MIN_PHI_ANGLE*((float)i+1.)),
                                                              r*sinf(6.*MIN_THETA_ANGLE*((float)j+1.))},
                                                              calculateNormalToTorus(0.5, 0.8, 6.*MIN_THETA_ANGLE*((float)j+1.), MIN_PHI_ANGLE*((float)i+1.)),
                                                              {0., 1., 0., 1.}};
            }
        }
        
        self.vertexBufferTorus = [self.device newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceStorageModeShared];
        
        Vertex vertices2[90*90*2*3];
        
        for(int i=0; i<90*90*2*3; i++)
            vertices2[i] = {vertices[i].position, vertices[i].normals, {0.,0.,0.,1.}};
        
        self.vertexBufferTorusBlack = [self.device newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceStorageModeShared];

    }
    
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
    [self.verticesOnOff setState:NO];
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
        
    
    
    bool isPlot[2] = {true, false};
    
    MTLDepthStencilDescriptor *depthDescriptor = [MTLDepthStencilDescriptor new];
    depthDescriptor.depthCompareFunction = MTLCompareFunctionLessEqual;
    depthDescriptor.depthWriteEnabled = YES;
    id<MTLDepthStencilState> depthState = [_device newDepthStencilStateWithDescriptor:depthDescriptor];
    
    id<MTLCommandBuffer> commandBuffer = [self.device newCommandQueue].commandBuffer;
    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
//    renderPassDescriptor.colorAttachments[0].texture = self.texture;
//    view.currentRenderPassDescriptor.depthAttachment.storeAction = MTLStoreActionStore;

    struct PointLight punctualLight = {
        {0.0, 2.0, 0.0},
        {0.8, 0.8, 0.8},
        20.0,
        10.0,
        0.1,
        0.1
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
    
    [renderEncoder setVertexBytes:&isPlot length:sizeof(bool)*2 atIndex:PlotOnOff];
    [renderEncoder setVertexBuffer:[self.device newBufferWithBytes:lines length:sizeof(lines) options:MTLResourceStorageModeShared] offset:0 atIndex:MainBuffer];

    int lightType = 0;
    if([[self.comboboxLightOnOff stringValue] isEqualToString:@"Off"]) [renderEncoder setFragmentBytes:&lightType length:sizeof(int) atIndex:FragmentLightType];
    else
    {
        if([[self.comboboxLightType stringValue] isEqualToString:@"Punctual"])
        {
            lightType = 1;
            [renderEncoder setFragmentBytes:&lightType length:sizeof(int) atIndex:FragmentLightType];
        }
        else
        {
            lightType = 2;
            [renderEncoder setFragmentBytes:&lightType length:sizeof(int) atIndex:FragmentLightType];
        }
    }
    [renderEncoder setFragmentBytes:&punctualLight length:sizeof(punctualLight) atIndex:PointLight];
    
    [renderEncoder drawPrimitives:MTLPrimitiveTypeLine vertexStart:0 vertexCount:6];
    
    isPlot[0] = false;
    [renderEncoder setVertexBytes:&isPlot length:sizeof(bool)*2 atIndex:PlotOnOff];
    
    if([[self.comboBox stringValue] isEqualToString:@"Cube"])
    {
       
        [renderEncoder setVertexBuffer:self.vertexBufferCube offset:0 atIndex:MainBuffer];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:36];
        
        if([self.verticesOnOff state] == YES)
        {
            [renderEncoder setTriangleFillMode:MTLTriangleFillModeLines];
            [renderEncoder setVertexBuffer:self.vertexBufferCubeBlack offset:0 atIndex:MainBuffer];
            [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:11*36];
        }
        
    }
    else if([[self.comboBox stringValue] isEqualToString:@"Sphere"])
    {
        
        [renderEncoder setVertexBuffer:self.vertexBufferSphere offset:0 atIndex:MainBuffer];
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
        isPlot[1] = true;
        [renderEncoder setVertexBytes:&isPlot length:sizeof(bool)*2 atIndex:PlotOnOff];
        [renderEncoder setVertexBuffer:self.vertexBufferTorus offset:0 atIndex:MainBuffer];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:90*90*2*3];
        
        if([self.verticesOnOff state] == YES)
        {

            isPlot[1] = false;
            [renderEncoder setVertexBytes:&isPlot length:sizeof(bool)*2 atIndex:PlotOnOff];
            
            [renderEncoder setTriangleFillMode:MTLTriangleFillModeLines];
            [renderEncoder setVertexBuffer:self.vertexBufferTorusBlack offset:0 atIndex:MainBuffer];
            [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:90*90*2*3];
        }
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
