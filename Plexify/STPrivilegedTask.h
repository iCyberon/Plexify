#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <Security/Authorization.h>
#import <Security/AuthorizationTags.h>

#define STPrivilegedTaskDidTerminateNotification        @"STPrivilegedTaskDidTerminateNotification"
#define TMP_STDERR_TEMPLATE                             @".authStderr.XXXXXX"

// Define new error value for when AuthorizationExecuteWithPrivilleges no longer
// exists anyplace. Rather than defining a new enum, we just create a global
// constant
extern const OSStatus errAuthorizationFnNoLongerExists;

@interface STPrivilegedTask : NSObject 
{
    NSArray         *arguments;
    NSString        *cwd;
    NSString        *launchPath;
    BOOL            isRunning;
    pid_t           pid;
    int             terminationStatus;
    NSFileHandle    *outputFileHandle;
    NSTimer         *checkStatusTimer;
}
-(id)initWithLaunchPath: (NSString *)path;
-(id)initWithLaunchPath: (NSString *)path arguments:  (NSArray *)args;
+(STPrivilegedTask *)launchedPrivilegedTaskWithLaunchPath:(NSString *)path;
+(STPrivilegedTask *)launchedPrivilegedTaskWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments;
-(NSArray *)arguments;
-(NSString *)currentDirectoryPath;
-(BOOL)isRunning;
-(int)launch;
-(NSString *)launchPath;
-(int)processIdentifier;
-(void)setArguments:(NSArray *)arguments;
-(void)setCurrentDirectoryPath:(NSString *)path;
-(void)setLaunchPath:(NSString *)path;
-(NSFileHandle *)outputFileHandle;
-(void)terminate;  // doesn't work
-(int)terminationStatus;
-(void)_checkTaskStatus;
-(void)waitUntilExit;
@end
/*static OSStatus AuthorizationExecuteWithPrivilegesStdErrAndPid (
                                                                AuthorizationRef authorization,
                                                                const char *pathToTool,
                                                                AuthorizationFlags options,
                                                                char * const *arguments,
                                                                FILE **communicationsPipe,
                                                                FILE **errPipe,
                                                                pid_t* processid
                                                                );*/
