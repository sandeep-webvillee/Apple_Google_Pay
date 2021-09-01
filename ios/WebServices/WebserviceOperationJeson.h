//  WebserviceOperation.h
//  Created by Praveen Tripathi on 26/12/10.
//  Copyright 2010 PKTSVITS. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"

@interface WebserviceOperationJeson : NSObject<NSURLConnectionDelegate,CLLocationManagerDelegate>
{
	NSMutableData *responseData;
	id _delegate;
	SEL _callback;
    AppDelegate *appDelegate;
    NSURLConnection *conn;
    int RETRY_COUNT;
    CLLocationManager *locationManager;
    NSString *currentLatitude;
    NSString *currentLongitude;
}
@property ( nonatomic) BOOL is_ProfilePic;
@property(nonatomic, retain)id _delegate;
@property(nonatomic, assign)SEL _callback;

+(BOOL)testInternerConnection;
-(id)initWithDelegate:(id)delegate callback:(SEL)callback;

#pragma mark method Defination

//Registration
-(void)RegLogEmail:(NSString *)email Username:(NSString *)username DeviceId:(NSString *)device_id DeviceType:(NSString *)device_type Password:(NSString *)password FBID:(NSString*)fb_id Gmail_ID:(NSString*)gmail_id Name:(NSString *)name Weight:(NSString *)weight Height:(NSString *)height DOB:(NSString *)dob Gender:(NSString *)gender Team:(NSString *)team Sport:(NSString *)sport Club:(NSString *)club HeightUnit:(NSString *)heightUnit WeightUnit:(NSString *)weightUnit Country:(NSString *)country TeamId:(NSString *)team_id;

//Edit profile
-(void)editProfileWithEmail:(NSString *)email Username:(NSString *)username DeviceId:(NSString *)device_id DeviceType:(NSString *)device_type Name:(NSString *)name Weight:(NSString *)weight Height:(NSString *)height DOB:(NSString *)dob Gender:(NSString *)gender Team:(NSString *)team Sport:(NSString *)sport Club:(NSString *)club HeightUnit:(NSString *)heightUnit WeightUnit:(NSString *)weightUnit Country:(NSString *)country TeamId:(NSString *)team_id;

//Login
-(void)loginWithEmail:(NSString *)email Password:(NSString *)password;

//Update profile
-(void)updateProfileEmail:(NSString *)email Username:(NSString *)username DeviceId:(NSString *)device_id DeviceType:(NSString *)device_type UserId:(NSString *)appuserid;

//Change Password
-(void)changePassword:(NSString *)password UserId:(NSString *)appuserid OldPassword:(NSString *)oldpassword;

//forgot password
-(void)forgotPasswordWithEmail:(NSString *)email;

//Create profile with social media
-(void)checkSocialLoginWithFBID:(NSString *)fb_id GmailID:(NSString *)gmail_id Email:(NSString *)email FirstName:(NSString *)first_name;

//Add user
-(void)addUserDetail:(NSString *)name Weight:(NSString *)weight Height:(NSString *)height DOB:(NSString *)dob Gender:(NSString *)gender Team:(NSString *)team Club:(NSString *)club WeightUnit:(NSString *)weightUnit HeightUnit:(NSString *)heightUnit UserId:(NSString *)appuserid;

//updaet user detail
-(void)updateUserDetail:(NSString *)name Weight:(NSString *)weight Height:(NSString *)height DOB:(NSString *)dob Gender:(NSString *)gender Team:(NSString *)team Club:(NSString *)club WeightUnit:(NSString *)weightUnit HeightUnit:(NSString *)heightUnit UserId:(NSString *)appuserid SubUserId:(NSString *)subuserid Username:(NSString *)username Email:(NSString *)email DeviceId:(NSString *)device_id DeviceType:(NSString *)device_type Sport:(NSString *)sport;

//get user detail
-(void)getUserDetail:(NSString *)appuserid;

//Add training set
-(void)addSetWithUserId:(NSString *)appuserid SetDate:(NSString *)set_date Exercise:(NSString *)exercise Comment:(NSString *)comment IsPublic:(NSString *)isPublic Inertia:(NSString *)inertia Vas:(NSString *)vas Device:(NSString *)device Weight:(NSString *)weight;

//Update training set
-(void)updateSetWithUserId:(NSString *)appuserid SetDate:(NSString *)set_date Exercise:(NSString *)exercise Comment:(NSString *)comment IsPublic:(NSString *)isPublic Inertia:(NSString *)inertia Vas:(NSString *)vas Id:(NSString *)id1 Weight:(NSString *)weight;

//add Training Rep
-(void)addTrainingRepWithUserId:(NSString *)appuserid SetId:(NSString *)set_id Duration:(NSString *)duration AveragePower:(NSString *)powerAvg AverageCon:(NSString *)powerCon PowerEcc:(NSString *)powerEcc PeakSpeed:(NSString *)peakSpeed RepRange:(NSString *)rep_range RepForce:(NSString *)rep_force;

//get Training Set List
-(void)getTrainingSetListWithUserId:(NSString *)appuserid PageNumber:(NSString *)page_no;

//Delete set with id
-(void)deleteTrainingWithIds:(NSString *)ids;

//checkSocialLogin
-(void)checkSocialLoginWithFBID:(NSString *)fb_id GmailID:(NSString *)gmail_id;

//Get team list
-(void)getTeamListWithuserId:(NSString *)user_id;

//Verify email
-(void)verifyEmail:(NSString *)email UserId:(NSString *)user_id Type:(NSString *)type;

//Get user list
-(void)getUserList;

//Upload profile pic
-(void)uploadProfilePic:(UIImage *)image;

//Get result list
-(void)getResultListWithPage:(NSString *)page SearchKey:(NSString *)search_key UserId:(NSString *)user_id;

//Delete set
-(void)deleteSetWithId:(NSString *)set_id UserId:(NSString *)user_id;

//logout
-(void)logoutUser;

//delete account
-(void)deleteAccountWithPassword:(NSString *)password GmailId:(NSString *)gmail_id FBId:(NSString *)fb_id;

//Get subscription plan
-(void)getSubscriptionPlan;

//Get existing coach
-(void)getExistingCoachList;

//Get pending existing coach
-(void)getPendingCoach;

//Get pending client
-(void)getPendingClient;

//Add client
-(void)addClientEmail:(NSString *)user_email;

//Remove client
-(void)removeClientId:(NSString *)coach_id;

//Remove coach
-(void)removeCoachId:(NSString *)coach_id;

//Add coach
-(void)addCoachEmail:(NSString *)user_email;

//Coach action
-(void)AcceptRejectCoachId:(NSString *)client_id Action:(NSString *)action;

//Client Action
-(void)AcceptRejectClientId:(NSString *)coach_id Action:(NSString *)action;

//Add exercise
-(void)addExercise:(NSString *)name Image:(UIImage *)logo;

//Get exercise
-(void)getExercise;

//Add training set
-(void)AddTrainingSetData:(NSMutableDictionary *)params;

//Update training set
-(void)UpdateTrainingSet:(NSMutableDictionary *)params;

-(void)sendRequestWithApi:(NSString *)api Parameter:(NSMutableDictionary *)sendData;

@end
