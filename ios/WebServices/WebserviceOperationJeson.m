
#import "WebserviceOperationJeson.h"
#import "MTReachabilityManager.h"

#define POST_BODY_BOURDARY  @"boundary"



@implementation WebserviceOperationJeson

@synthesize _callback;
@synthesize _delegate,is_ProfilePic;

-(id)initWithDelegate:(id)delegate callback:(SEL)callback
{
	if(self = [super init])
    {
		self._delegate = delegate;
		self._callback = callback;
	}

	return self;
}

+(BOOL)testInternerConnection
{
    if(![MTReachabilityManager isReachable])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Internet connection not available." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    else
    {
        return YES;
    }
}
#pragma mark Delegate Mathod

-(void)RetryWebservice
{
    if(RETRY_COUNT< 3) // It will
    {
        RETRY_COUNT = RETRY_COUNT+1;
        conn=[[NSURLConnection alloc] initWithRequest:conn.currentRequest delegate:self];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if(RETRY_COUNT<3)
    {
        if([self._delegate respondsToSelector:self._callback])
        {
            [self performSelector:@selector(RetryWebservice) withObject:nil afterDelay:0.0];
        }
    }
    else
    {
        [self._delegate performSelector:self._callback withObject:error];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSError *error;
    NSData *data=[responseString dataUsingEncoding:NSUTF8StringEncoding];
    
    id json=  [NSJSONSerialization JSONObjectWithData:data options:NSUTF8StringEncoding error:&error];
    
    NSLog(@"resulted json %@",json);
    
    if (is_ProfilePic)
    {
        id json1=responseString;
        
        if ([json1 isKindOfClass:[NSString class]])
        {
            if([self._delegate respondsToSelector:self._callback])
            {
                [self._delegate performSelector:self._callback withObject:json1];
                return;
            }
        }
    }
   
    if(json == nil)
    {
        if ([self._delegate respondsToSelector:self._callback])
        {
            [self._delegate performSelector:self._callback withObject:error];
        }
    }
    else
    {
        if([self._delegate respondsToSelector:self._callback])
        {
            [self._delegate performSelector:self._callback withObject:json];
        }
        else
        {
            NSLog(@"Callback is not responding.");
        }
    }
}
#pragma mark Image name
-(NSString *)getUserImageName
{
    RETRY_COUNT = 0;
    NSArray *timeStamp = [[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000] componentsSeparatedByString:@"."];
    NSString *user_image_name = [NSString stringWithFormat:@"IOS_%@.jpg",[timeStamp objectAtIndex:0]];
    NSLog(@"user_image_name %@",user_image_name);
    return user_image_name;
}
-(NSString *)getGPXName
{
    RETRY_COUNT = 0;
    NSArray *timeStamp = [[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000] componentsSeparatedByString:@"."];
    NSString *user_image_name = [NSString stringWithFormat:@"IOS_%@.gpx",[timeStamp objectAtIndex:0]];
    NSLog(@"user_image_name %@",user_image_name);
    return user_image_name;
}
#pragma mark Upload chat image to node server
-(void)uploadFileWithName:(NSString *)filename Data:(UIImage *)data ThumbImage:(UIImage *)thumbnail;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@upload",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSDictionary *tempDIct=[[AppDelegate sharedInstance] getUserDefault];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    [sendData setObject:[tempDIct valueForKey:@"fb_id"] forKey:@"sender"];
    [sendData setObject:@"raj" forKey:@"receiver"];
    
//    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    // add image data
    if (data!=nil)
    {
        NSData *imageData = UIImagePNGRepresentation([self resizeImage:data IsThumb:NO]);
        
        if (imageData)
        {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"file",filename] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:imageData];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    // add image data
    if (thumbnail!=nil)
    {
        NSData *imageData = UIImagePNGRepresentation([self blurredImageWithImage:[self resizeImage:thumbnail IsThumb:YES]]);
        
        if (imageData)
        {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"thumbnail",filename] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:imageData];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}


-(void)updateProfileEmail:(NSString *)email Username:(NSString *)username DeviceId:(NSString *)device_id DeviceType:(NSString *)device_type UserId:(NSString *)appuserid;
{
    
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@updateprofile.php",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSDictionary *tempDIct=[[AppDelegate sharedInstance] getUserDefault];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    [sendData setObject:email forKey:@"email"];
    [sendData setObject:username forKey:@"username"];
    [sendData setObject:@"2" forKey:@"device_type"];
    [sendData setObject:@"123456" forKey:@"device_id"];
     [sendData setObject:appuserid forKey:@"appuserid"];
    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    // add image data
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
}
#pragma mark forgot password
-(void)forgotPasswordWithEmail:(NSString *)email;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@forgotePassword",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    [sendData setObject:email forKey:@"email"];
    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    // add image data
    //    if (profile_pic!=nil)
    //    {
    //        NSData *imageData = UIImagePNGRepresentation([self resizeImage:profile_pic IsThumb:NO]);
    //
    //        if (imageData)
    //        {
    //            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //
    //            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"profile_pic",[self getUserImageName]] dataUsingEncoding:NSUTF8StringEncoding]];
    //            [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //            [body appendData:imageData];
    //            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    //        }
    //    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}
#pragma mark Register login
-(void)RegLogEmail:(NSString *)email Username:(NSString *)username DeviceId:(NSString *)device_id DeviceType:(NSString *)device_type Password:(NSString *)password FBID:(NSString*)fb_id Gmail_ID:(NSString*)gmail_id Name:(NSString *)name Weight:(NSString *)weight Height:(NSString *)height DOB:(NSString *)dob Gender:(NSString *)gender Team:(NSString *)team Sport:(NSString *)sport Club:(NSString *)club HeightUnit:(NSString *)heightUnit WeightUnit:(NSString *)weightUnit Country:(NSString *)country TeamId:(NSString *)team_id;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@userRegister",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    //NSDictionary *tempDIct=[[AppDelegate sharedInstance] getUserDefault];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";

    //[sendData setObject:name forKey:@"name"];
    [sendData setObject:weight forKey:@"weight"];
    [sendData setObject:height forKey:@"height"];
    [sendData setObject:dob forKey:@"dob"];
    [sendData setObject:gender forKey:@"gender"];
    [sendData setObject:team forKey:@"team"];
    [sendData setObject:team_id forKey:@"team_id"];
    [sendData setObject:sport forKey:@"sport"];
    [sendData setObject:club forKey:@"club"];
    [sendData setObject:heightUnit forKey:@"height_unit"];
    [sendData setObject:weightUnit forKey:@"weight_unit"];
    [sendData setObject:email forKey:@"email"];
    [sendData setObject:name forKey:@"username"];
    [sendData setObject:password forKey:@"password"];
    [sendData setObject:@"2" forKey:@"device_type"];
    [sendData setObject:@"123" forKey:@"device_token"];
    [sendData setObject:@"123456" forKey:@"device_id"];
    [sendData setObject:gmail_id forKey:@"gmail_id"];
    [sendData setObject:fb_id forKey:@"fb_id"];
    [sendData setObject:name forKey:@"first_name"];
    [sendData setObject:@"" forKey:@"last_name"];
    [sendData setObject:country forKey:@"country"];
    [sendData setObject:@"0" forKey:@"country_id"];


    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    // add image data
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}
#pragma mark Edit profile
-(void)editProfileWithEmail:(NSString *)email Username:(NSString *)username DeviceId:(NSString *)device_id DeviceType:(NSString *)device_type Name:(NSString *)name Weight:(NSString *)weight Height:(NSString *)height DOB:(NSString *)dob Gender:(NSString *)gender Team:(NSString *)team Sport:(NSString *)sport Club:(NSString *)club HeightUnit:(NSString *)heightUnit WeightUnit:(NSString *)weightUnit Country:(NSString *)country TeamId:(NSString *)team_id;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@updateProfile",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    //NSDictionary *tempDIct=[[AppDelegate sharedInstance] getUserDefault];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSDictionary *dictUser = [[Singleton sharedSingleton] getUserDefault];
    
    //[sendData setObject:name forKey:@"name"];
    [sendData setObject:weight forKey:@"weight"];
    [sendData setObject:height forKey:@"height"];
    [sendData setObject:dob forKey:@"dob"];
    [sendData setObject:gender forKey:@"gender"];
    [sendData setObject:team forKey:@"team"];
    [sendData setObject:team_id forKey:@"team_id"];
    [sendData setObject:sport forKey:@"sport"];
    [sendData setObject:club forKey:@"club"];
    [sendData setObject:heightUnit forKey:@"height_unit"];
    [sendData setObject:weightUnit forKey:@"weight_unit"];
    [sendData setObject:email forKey:@"email"];
    [sendData setObject:name forKey:@"username"];
    [sendData setObject:@"2" forKey:@"device_type"];
    [sendData setObject:@"123" forKey:@"device_token"];
    [sendData setObject:@"123456" forKey:@"device_id"];
    [sendData setObject:name forKey:@"first_name"];
    [sendData setObject:@"" forKey:@"last_name"];
    [sendData setObject:country forKey:@"country"];
    [sendData setObject:@"0" forKey:@"country_id"];
    [sendData setObject:[NSString stringWithFormat:@"%@",[dictUser valueForKey:@"id"]] forKey:@"user_id"];
    [sendData setObject:[NSString stringWithFormat:@"%@",[dictUser valueForKey:@"id"]] forKey:@"coach_id"];
    
    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    // add image data
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)addUserDetail:(NSString *)name Weight:(NSString *)weight Height:(NSString *)height DOB:(NSString *)dob Gender:(NSString *)gender Team:(NSString *)team Club:(NSString *)club WeightUnit:(NSString *)weightUnit HeightUnit:(NSString *)heightUnit UserId:(NSString *)appuserid;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@addSubUser.php",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    //NSDictionary *tempDIct=[[AppDelegate sharedInstance] getUserDefault];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    [sendData setObject:appuserid forKey:@"appuserid"];
    [sendData setObject:name forKey:@"name"];
    [sendData setObject:weight forKey:@"weight"];
    [sendData setObject:height forKey:@"height"];
    [sendData setObject:dob forKey:@"dob"];
    [sendData setObject:gender forKey:@"gender"];
    [sendData setObject:team forKey:@"team"];
    [sendData setObject:club forKey:@"club"];
    [sendData setObject:weightUnit forKey:@"weightUnit"];
    [sendData setObject:heightUnit forKey:@"heightUnit"];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)updateUserDetail:(NSString *)name Weight:(NSString *)weight Height:(NSString *)height DOB:(NSString *)dob Gender:(NSString *)gender Team:(NSString *)team Club:(NSString *)club WeightUnit:(NSString *)weightUnit HeightUnit:(NSString *)heightUnit UserId:(NSString *)appuserid SubUserId:(NSString *)subuserid Username:(NSString *)username Email:(NSString *)email DeviceId:(NSString *)device_id DeviceType:(NSString *)device_type Sport:(NSString *)sport;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@updateprofile.php",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    //NSDictionary *tempDIct=[[AppDelegate sharedInstance] getUserDefault];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    [sendData setObject:sport forKey:@"sport"];
    [sendData setObject:device_type forKey:@"device_type"];
    [sendData setObject:@"123456" forKey:@"device_id"];
    [sendData setObject:email forKey:@"email"];
    [sendData setObject:username forKey:@"username"];
    [sendData setObject:appuserid forKey:@"appuserid"];
    [sendData setObject:name forKey:@"name"];
    [sendData setObject:weight forKey:@"weight"];
    [sendData setObject:height forKey:@"height"];
    [sendData setObject:dob forKey:@"dob"];
    [sendData setObject:gender forKey:@"gender"];
    [sendData setObject:team forKey:@"team"];
    [sendData setObject:club forKey:@"club"];
    [sendData setObject:weightUnit forKey:@"weightUnit"];
    [sendData setObject:heightUnit forKey:@"heightUnit"];
    [sendData setObject:subuserid forKey:@"subuserid"];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)getSubscriptionPlan;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@getSubscriptionPlan",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    NSDictionary *tempDIct=[[NSDictionary alloc]init];
    tempDIct=[[Singleton sharedSingleton] getUserDefault];
    
    [sendData setObject:[NSString stringWithFormat:@"%@",[tempDIct valueForKey:@"id"]] forKey:@"user_id"];
    [sendData setObject:[NSString stringWithFormat:@"1"] forKey:@"device"];

    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)deleteAccountWithPassword:(NSString *)password GmailId:(NSString *)gmail_id FBId:(NSString *)fb_id
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@deleteAccount",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    NSDictionary *tempDIct=[[NSDictionary alloc]init];
    tempDIct=[[Singleton sharedSingleton] getUserDefault];
    
    [sendData setObject:[NSString stringWithFormat:@"%@",[tempDIct valueForKey:@"id"]] forKey:@"user_id"];
    [sendData setObject:password forKey:@"password"];
    [sendData setObject:fb_id forKey:@"fb_id"];
    [sendData setObject:gmail_id forKey:@"gmail_id"];

    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)changePassword:(NSString *)password UserId:(NSString *)appuserid OldPassword:(NSString *)oldpassword;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@changePassword",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    NSDictionary *tempDIct=[[NSDictionary alloc]init];
    tempDIct=[[Singleton sharedSingleton] getUserDefault];
    
    [sendData setObject:[NSString stringWithFormat:@"%@",[tempDIct valueForKey:@"id"]] forKey:@"user_id"];
    [sendData setObject:password forKey:@"password"];
    [sendData setObject:oldpassword forKey:@"old_password"];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)loginWithEmail:(NSString *)email Password:(NSString *)password;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@userLogin",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    [sendData setObject:email forKey:@"email"];
    [sendData setObject:password forKey:@"password"];
    [sendData setObject:@"123" forKey:@"device_token"];
    [sendData setObject:@"2" forKey:@"device_type"];
    [sendData setObject:@"123456" forKey:@"device_id"];

    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)checkSocialLoginWithFBID:(NSString *)fb_id GmailID:(NSString *)gmail_id Email:(NSString *)email FirstName:(NSString *)first_name;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@socialLogin",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    [sendData setObject:fb_id forKey:@"fb_id"];
    [sendData setObject:gmail_id forKey:@"gmail_id"];
    [sendData setObject:@"2" forKey:@"device_type"];
    [sendData setObject:@"123" forKey:@"device_token"];
    [sendData setObject:@"123456" forKey:@"device_id"];
    [sendData setObject:email forKey:@"email"];
    [sendData setObject:first_name forKey:@"first_name"];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)updateSetWithUserId:(NSString *)appuserid SetDate:(NSString *)set_date Exercise:(NSString *)exercise Comment:(NSString *)comment IsPublic:(NSString *)isPublic Inertia:(NSString *)inertia Vas:(NSString *)vas Id:(NSString *)id1 Weight:(NSString *)weight;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@updateTrainingSet.php",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    [sendData setObject:appuserid forKey:@"appuserid"];
    [sendData setObject:set_date forKey:@"set_date"];
    [sendData setObject:exercise forKey:@"exercise"];
    [sendData setObject:comment forKey:@"comment"];
    [sendData setObject:isPublic forKey:@"isPublic"];
    [sendData setObject:inertia forKey:@"inertia"];
    [sendData setObject:vas forKey:@"vas"];
    [sendData setObject:id1 forKey:@"id"];
    [sendData setObject:weight forKey:@"weight"];
    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)deleteTrainingWithIds:(NSString *)ids;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@deleteTrainingSet.php",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSDictionary *tempDIct=[[AppDelegate sharedInstance] getUserDefault];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    [sendData setObject:[NSString stringWithFormat:@"(%@)",ids] forKey:@"id"];
     [sendData setObject:[NSString stringWithFormat:@"%@",[tempDIct valueForKey:@"id"]] forKey:@"appuserid"];
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)getTrainingSetListWithUserId:(NSString *)appuserid PageNumber:(NSString *)page_no;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@getTrainingSetList.php",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    [sendData setObject:appuserid forKey:@"appuserid"];
    [sendData setObject:page_no forKey:@"page_no"];
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)addTrainingRepWithUserId:(NSString *)appuserid SetId:(NSString *)set_id Duration:(NSString *)duration AveragePower:(NSString *)powerAvg AverageCon:(NSString *)powerCon PowerEcc:(NSString *)powerEcc PeakSpeed:(NSString *)peakSpeed RepRange:(NSString *)rep_range RepForce:(NSString *)rep_force;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@addTrainingRep.php",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    [sendData setObject:appuserid forKey:@"appuserid"];
    [sendData setObject:set_id forKey:@"set_id"];
    [sendData setObject:duration forKey:@"duration"];
    [sendData setObject:powerAvg forKey:@"powerAvg"];
    [sendData setObject:powerCon forKey:@"powerCon"];
    [sendData setObject:powerEcc forKey:@"powerEcc"];
    [sendData setObject:peakSpeed forKey:@"peakSpeed"];
    [sendData setObject:rep_range forKey:@"rep_range"];
    [sendData setObject:rep_force forKey:@"rep_force"];
    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)addSetWithUserId:(NSString *)appuserid SetDate:(NSString *)set_date Exercise:(NSString *)exercise Comment:(NSString *)comment IsPublic:(NSString *)isPublic Inertia:(NSString *)inertia Vas:(NSString *)vas Device:(NSString *)device Weight:(NSString *)weight;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@addTrainingSet.php",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    [sendData setObject:appuserid forKey:@"appuserid"];
    [sendData setObject:set_date forKey:@"set_date"];
    [sendData setObject:exercise forKey:@"exercise"];
    [sendData setObject:comment forKey:@"comment"];
    [sendData setObject:isPublic forKey:@"isPublic"];
    [sendData setObject:inertia forKey:@"inertia"];
    [sendData setObject:vas forKey:@"vas"];
    [sendData setObject:device forKey:@"device"];
    [sendData setObject:weight forKey:@"weight"];
    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)logoutUser;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@userLogout",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    NSDictionary *tempDIct = [[Singleton sharedSingleton]getUserDefault];
    
    [sendData setObject:[NSString stringWithFormat:@"%@",[tempDIct objectForKey:@"id"]] forKey:@"user_id"];
    [sendData setObject:@"123" forKey:@"device_token"];
    [sendData setObject:@"123456" forKey:@"device_id"];
    [sendData setObject:@"2" forKey:@"device_type"];

    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark Get user
-(void)getTeamListWithuserId:(NSString *)user_id;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@getClubTeamSport",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [sendData setObject:user_id forKey:@"user_id"];
    [sendData setObject:@"123456" forKey:@"device_id"];

    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
}

#pragma mark Get user
-(void)getUserDetail:(NSString *)appuserid;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@getUserDetails",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [sendData setObject:appuserid forKey:@"user_id"];
    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
   
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
 
}
-(void)sendRequestWithApi:(NSString *)api Parameter:(NSMutableDictionary *)sendData
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@%@",FIND_URL,api];
    responseData = [[NSMutableData alloc] init];
    //NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
   NSLog(@"api -->%@ \nrequest--> %@",urlStr,sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    
    if ([sendData.allKeys containsObject:@"logo"])
    {
        if ([[sendData valueForKey:@"logo"] isKindOfClass:[UIImage class]])
        {
            UIImage *logo = [sendData valueForKey:@"logo"];
            
            if (logo!=nil)
            {
                NSData *imageData = UIImagePNGRepresentation([self resizeImage:logo IsThumb:NO]);
                
                if (imageData)
                {
                    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"logo",[self getUserImageName]] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:imageData];
                    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                }
            }
        }
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
}

-(void)uploadProfilePic:(UIImage *)image;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@uploadProfilePic",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSDictionary *tempDIct=[[NSDictionary alloc]init];
    tempDIct=[[Singleton sharedSingleton] getUserDefault];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    [sendData setObject:[NSString stringWithFormat:@"%@",[tempDIct objectForKey:@"id"]] forKey:@"user_id"];
    
    NSLog(@"request %@ %@",urlStr,sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    // add image data
    if (image!=nil)
    {
        NSData *imageData = UIImagePNGRepresentation([self resizeImage:image IsThumb:NO]);
        
        if (imageData)
        {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"profile_pic",[self getUserImageName]] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:imageData];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}
#pragma mark Delete set
-(void)deleteSetWithId:(NSString *)set_id UserId:(NSString *)user_id
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@deleteTrainingSet",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    
    NSDictionary *dictUser = [[Singleton sharedSingleton] getUserDefault];
    
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [sendData setObject:user_id forKey:@"user_id"];
    //[NSString stringWithFormat:@"%@",[dictUser valueForKey:@"id"]] forKey:@"user_id"];
    [sendData setObject:[NSString stringWithFormat:@"%@",set_id] forKey:@"set_id"];
    
    
    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
}
#pragma mark Get user & result list
-(void)getResultListWithPage:(NSString *)page SearchKey:(NSString *)search_key UserId:(NSString *)user_id
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@getTraningSetList",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    
    NSDictionary *dictUser = [[Singleton sharedSingleton] getUserDefault];
    
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    NSString *idd = [NSString stringWithFormat:@"%@",[dictUser valueForKey:@"id"]];
    NSLog(@"url---->%@,user_id---->%@ , select id --->%@",urlStr,idd , user_id);
    [sendData setObject:[NSString stringWithFormat:@"%@",user_id] forKey:@"user_id"];
    [sendData setObject:[NSString stringWithFormat:@"%@",idd] forKey:@"coach_id"];
    [sendData setObject:[NSString stringWithFormat:@"%@",search_key] forKey:@"search_key"];

    [sendData setObject:[NSString stringWithFormat:@"%@",page] forKey:@"page"];

    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
}
-(void)removeClientId:(NSString *)coach_id;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@removeClient",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    
    NSDictionary *dictUser = [[Singleton sharedSingleton] getUserDefault];
    
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [sendData setObject:[NSString stringWithFormat:@"%@",coach_id] forKey:@"user_id"];
    [sendData setObject:[NSString stringWithFormat:@"%@",[dictUser valueForKey:@"id"]] forKey:@"coach_id"];

    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
}
-(void)removeCoachId:(NSString *)coach_id;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@removeCoach",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    
    NSDictionary *dictUser = [[Singleton sharedSingleton] getUserDefault];
    
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [sendData setObject:[NSString stringWithFormat:@"%@",[dictUser valueForKey:@"id"]] forKey:@"user_id"];
    [sendData setObject:[NSString stringWithFormat:@"%@",coach_id] forKey:@"coach_id"];
    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
}
//Add client
-(void)addClientEmail:(NSString *)user_email;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@addClient",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    
    NSDictionary *dictUser = [[Singleton sharedSingleton] getUserDefault];
    
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [sendData setObject:[NSString stringWithFormat:@"%@",[dictUser valueForKey:@"id"]] forKey:@"user_id"];
    [sendData setObject:[NSString stringWithFormat:@"%@",user_email] forKey:@"user_email"];
    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
}
//Coach action
-(void)AcceptRejectCoachId:(NSString *)client_id Action:(NSString *)action;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@coachAction",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    
    NSDictionary *dictUser = [[Singleton sharedSingleton] getUserDefault];
    
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [sendData setObject:[NSString stringWithFormat:@"%@",client_id] forKey:@"client_id"];
    [sendData setObject:[NSString stringWithFormat:@"%@",[dictUser valueForKey:@"id"]] forKey:@"user_id"];
    [sendData setObject:[NSString stringWithFormat:@"%@",action] forKey:@"action"];
    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
}
//Client Action
-(void)AcceptRejectClientId:(NSString *)coach_id Action:(NSString *)action;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@clientAction",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    
    NSDictionary *dictUser = [[Singleton sharedSingleton] getUserDefault];
    
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [sendData setObject:[NSString stringWithFormat:@"%@",coach_id] forKey:@"coach_id"];
    [sendData setObject:[NSString stringWithFormat:@"%@",[dictUser valueForKey:@"id"]] forKey:@"user_id"];
    [sendData setObject:[NSString stringWithFormat:@"%@",action] forKey:@"action"];

    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
}
//Add client
-(void)addCoachEmail:(NSString *)user_email;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@addCoach",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    
    NSDictionary *dictUser = [[Singleton sharedSingleton] getUserDefault];
    
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [sendData setObject:[NSString stringWithFormat:@"%@",[dictUser valueForKey:@"id"]] forKey:@"user_id"];
    [sendData setObject:[NSString stringWithFormat:@"%@",user_email] forKey:@"coach_email"];
    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
}

-(void)getPendingCoach
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@getPendingCoach",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    
    NSDictionary *dictUser = [[Singleton sharedSingleton] getUserDefault];
    
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [sendData setObject:[NSString stringWithFormat:@"%@",[dictUser valueForKey:@"id"]] forKey:@"user_id"];
    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
}
    

-(void)getExistingCoachList;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@getExistingCoach",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    
    NSDictionary *dictUser = [[Singleton sharedSingleton] getUserDefault];
    
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [sendData setObject:[NSString stringWithFormat:@"%@",[dictUser valueForKey:@"id"]] forKey:@"user_id"];
    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
}
-(void)getPendingClient
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@getPendingClient",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    
    NSDictionary *dictUser = [[Singleton sharedSingleton] getUserDefault];
    
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [sendData setObject:[NSString stringWithFormat:@"%@",[dictUser valueForKey:@"id"]] forKey:@"user_id"];
    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
}
-(void)getUserList;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@getExistingClient",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    
    NSDictionary *dictUser = [[Singleton sharedSingleton] getUserDefault];
    
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [sendData setObject:[NSString stringWithFormat:@"%@",[dictUser valueForKey:@"id"]] forKey:@"user_id"];
    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
}
#pragma mark Exercise---------
-(void)addExercise:(NSString *)name Image:(UIImage *)logo
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@addExercise",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    
    NSDictionary *dictUser = [[Singleton sharedSingleton] getUserDefault];
    
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    
    [sendData setObject:[NSString stringWithFormat:@"%@",[dictUser valueForKey:@"id"]] forKey:@"user_id"];
    [sendData setObject:name forKey:@"title"];
    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data //
    if (logo!=nil)
    {
        NSData *imageData = UIImagePNGRepresentation([self resizeImage:logo IsThumb:NO]);
        
        if (imageData)
        {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"logo",[self getUserImageName]] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:imageData];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
}
-(void)getExercise
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@getExercise",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    
    NSDictionary *dictUser = [[Singleton sharedSingleton] getUserDefault];
    
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    NSDictionary *tempDIct = [[Singleton sharedSingleton]getUserDefault];
    
    [sendData setObject:[NSString stringWithFormat:@"%@",[tempDIct objectForKey:@"id"]] forKey:@"user_id"];

   // [sendData setObject:[NSString stringWithFormat:@"3"] forKey:@"user_id"];
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
}

-(void)UpdateTrainingSet:(NSMutableDictionary *)params
{
    //mohan
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@updateTrainingSet",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    //    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    //NSDictionary *tempDIct=[[AppDelegate sharedInstance] getUserDefault];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    //    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    //    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    
    // [sendData setObject:@"2" forKey:@"device_type"];
    
    //[sendData setObject:name forKey:@"name"];
    /*  [sendData setObject:weight forKey:@"weight"];
     [sendData setObject:height forKey:@"height"];
     [sendData setObject:dob forKey:@"dob"];
     [sendData setObject:gender forKey:@"gender"];
     [sendData setObject:team forKey:@"team"];
     [sendData setObject:team_id forKey:@"team_id"];
     [sendData setObject:sport forKey:@"sport"];
     [sendData setObject:club forKey:@"club"];
     [sendData setObject:heightUnit forKey:@"height_unit"];
     [sendData setObject:weightUnit forKey:@"weight_unit"];
     [sendData setObject:email forKey:@"email"];
     [sendData setObject:name forKey:@"username"];
     [sendData setObject:password forKey:@"password"];
     [sendData setObject:@"2" forKey:@"device_type"];
     [sendData setObject:@"2jgkjnjkhjk" forKey:@"device_token"];
     [sendData setObject:device_id forKey:@"device_id"];
     [sendData setObject:gmail_id forKey:@"gmail_id"];
     [sendData setObject:fb_id forKey:@"fb_id"];
     [sendData setObject:name forKey:@"first_name"];
     [sendData setObject:@"" forKey:@"last_name"];
     [sendData setObject:country forKey:@"country"];
     [sendData setObject:@"0" forKey:@"country_id"];
     
     */
    //    filename=[self getUserImageName];
    
    NSLog(@"urlStr-->%@, request %@",urlStr,params);
    // add params (all params are strings)
    for (NSString *param in params)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    // add image data
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)AddTrainingSetData:(NSMutableDictionary *)params
{
    //mohan
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@addTrainingSetData",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    //    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    //NSDictionary *tempDIct=[[AppDelegate sharedInstance] getUserDefault];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
 //   NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
   // dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    
    // [sendData setObject:@"2" forKey:@"device_type"];
    
    //[sendData setObject:name forKey:@"name"];
    /*  [sendData setObject:weight forKey:@"weight"];
     [sendData setObject:height forKey:@"height"];
     [sendData setObject:dob forKey:@"dob"];
     [sendData setObject:gender forKey:@"gender"];
     [sendData setObject:team forKey:@"team"];
     [sendData setObject:team_id forKey:@"team_id"];
     [sendData setObject:sport forKey:@"sport"];
     [sendData setObject:club forKey:@"club"];
     [sendData setObject:heightUnit forKey:@"height_unit"];
     [sendData setObject:weightUnit forKey:@"weight_unit"];
     [sendData setObject:email forKey:@"email"];
     [sendData setObject:name forKey:@"username"];
     [sendData setObject:password forKey:@"password"];
     [sendData setObject:@"2" forKey:@"device_type"];
     [sendData setObject:@"2jgkjnjkhjk" forKey:@"device_token"];
     [sendData setObject:device_id forKey:@"device_id"];
     [sendData setObject:gmail_id forKey:@"gmail_id"];
     [sendData setObject:fb_id forKey:@"fb_id"];
     [sendData setObject:name forKey:@"first_name"];
     [sendData setObject:@"" forKey:@"last_name"];
     [sendData setObject:country forKey:@"country"];
     [sendData setObject:@"0" forKey:@"country_id"];
     
     */
    //    filename=[self getUserImageName];
    
    NSLog(@"urlStr-->%@, request %@",urlStr,params);
    // add params (all params are strings)
    for (NSString *param in params)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    // add image data
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark Verify email
-(void)verifyEmail:(NSString *)email UserId:(NSString *)user_id Type:(NSString *)type;
{
    RETRY_COUNT = 0;
    responseData = [[NSMutableData alloc] init];
    
    NSString *urlStr =[NSString stringWithFormat:@"%@changeEmail",FIND_URL];
    responseData = [[NSMutableData alloc] init];
    NSMutableDictionary *sendData = [[NSMutableDictionary alloc]init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    //     set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // UIImage to Nsdata
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [sendData setObject:user_id forKey:@"user_id"];
    [sendData setObject:email forKey:@"email"];
    [sendData setObject:type forKey:@"type"];

    
    //    filename=[self getUserImageName];
    
    NSLog(@"request %@",sendData);
    // add params (all params are strings)
    for (NSString *param in sendData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [sendData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10000];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
}

#pragma mark Google place search
-(void)getCurrentTemperatureWithLat:(NSString *)lat Long:(NSString *)longg
{
    //http://eworksth-001-site5.atempurl.com/UpdateUserFavouriteRest
    
    //https://maps.googleapis.com/maps/api/place/autocomplete/json?input=c&types=geocode&language=en&key=AIzaSyB8X1mOzZsC594OXTG1520xyuie8Ya60PI&components=country:th&location=13.736717,100.523186&radius=100000
    
    responseData = [[NSMutableData alloc] init];
    //22.7228606 75.8825475
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://api.geonames.org/findNearByWeatherJSON?lat=%@&lng=%@&username=webvilleedeveloper",lat,longg]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120000.0];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"oAuthkey"] forHTTPHeaderField:@"oAuthkey"];
    [request setHTTPMethod:@"GET"];
    
    conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
}



#pragma mark Compress Image
-(UIImage *)resizeImage:(UIImage *)image IsThumb:(BOOL)isThumb
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight;
    float maxWidth;
    float compressionQuality;
    
    if (isThumb)
    {
        compressionQuality = 0.95;//70 percent compression
        maxHeight = 100.0;
        maxWidth = 100.0;
    }
    else
    {
        compressionQuality = 1.0;//60 percent compression
        maxHeight = 500.0;
        maxWidth = 350.0;
    }
    
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    
    if (actualHeight > maxHeight || actualWidth > maxWidth)
    {
        if(imgRatio < maxRatio)
        {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio)
        {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else
        {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:imageData];
}
#pragma mark Blur image
- (UIImage *)blurredImageWithImage:(UIImage *)sourceImage
{
    
    //Create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    
    //  Setting up Gaussian Blur
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    /*  CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches
     *  up exactly to the bounds of our original image */
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *retVal = [UIImage imageWithCGImage:cgImage];
    
    if (cgImage) {
        CGImageRelease(cgImage);
    }
    
    return retVal;
}
@end

