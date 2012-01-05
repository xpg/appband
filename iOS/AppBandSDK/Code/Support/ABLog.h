//
//  ABLog.h
//  AppBandSDK
//
//  Created by Yan Liu on 1/5/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

//
//  RKLog.h
//  RestKit
//
//  Created by Blake Watters on 5/3/11.
//  Copyright 2011 Two Toasters
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

/**
 AppBand Logging is based on the LibComponentLogging framework
 
 @see lcl_config_components.h
 @see lcl_config_logger.h
 */
#import "lcl.h"

/**
 ABLogComponent defines the active component within any given portion of AppBand
 
 By default, messages will log to the base 'AppBand' log component. All other components
 used by AppBand are nested under this parent, so this effectively sets the default log
 level for the entire library.
 
 The component can be undef'd and redefined to change the active logging component.
 */
#define ABLogComponent lcl_cAppBand

/**
 The logging macros. These macros will log to the currently active logging component
 at the log level identified in the name of the macro.
 
 For example, in the ABProvisioning class we would redefine the ABLogComponent:
 
 #undef ABLogComponent
 #define ABLogComponent lcl_cAppBandProvisioning
 
 The lcl_c prefix is the LibComponentLogging data structure identifying the logging component
 we want to target within this portion of the codebase. See lcl_config_component.h for reference.
 
 Having defined the logging component, invoking the logger via:
 
 ABLogInfo(@"This is my log message!");
 
 Would result in a log message similar to:
 
 I AppBand.Provisioning:ABLog.h:42 This is my log message!
 
 The message will only be logged if the log level for the active component is equal to or higher
 than the level the message was logged at (in this case, Info).
 */
#define ABLogCritical(...)                                                              \
lcl_log(ABLogComponent, lcl_vCritical, @"" __VA_ARGS__)

#define ABLogError(...)                                                                 \
lcl_log(ABLogComponent, lcl_vError, @"" __VA_ARGS__)

#define ABLogWarning(...)                                                               \
lcl_log(ABLogComponent, lcl_vWarning, @"" __VA_ARGS__)

#define ABLogInfo(...)                                                                  \
lcl_log(ABLogComponent, lcl_vInfo, @"" __VA_ARGS__)

#define ABLogDebug(...)                                                                 \
lcl_log(ABLogComponent, lcl_vDebug, @"" __VA_ARGS__)

#define ABLogTrace(...)                                                                 \
lcl_log(ABLogComponent, lcl_vTrace, @"" __VA_ARGS__)

/**
 Log Level Aliases
 
 These aliases simply map the log levels defined within LibComponentLogger to something more friendly
 */
#define ABLogLevelCritical  lcl_vCritical
#define ABLogLevelError     lcl_vError
#define ABLogLevelWarning   lcl_vWarning
#define ABLogLevelInfo      lcl_vInfo
#define ABLogLevelDebug     lcl_vDebug
#define ABLogLevelTrace     lcl_vTrace

/**
 Alias the LibComponentLogger logging configuration method. Also ensures logging
 is initialized for the framework.
 
 Expects the name of the component and a log level.
 
 Examples:
 
 // Log debugging messages from the Network component
 ABLogConfigureByName("AppBand/Network", ABLogLevelDebug);
 */
#define ABLogConfigureByName(name, level)                                               \
ABLogInitialize();                                                                      \
lcl_configure_by_name(name, level);

/**
 Alias for configuring the LibComponentLogger logging component for the App. This
 enables the end-user of AppBand to leverage ABLog() to log messages inside of 
 their apps.
 */
#define ABLogSetAppLoggingLevel(level)                                                  \
ABLogInitialize();                                                                      \
lcl_configure_by_name("App", level);

/**
 Temporarily changes the logging level for the specified component and executes the block. Any logging
 statements executed within the body of the block against the specified component will log at the new
 logging level. After the block has executed, the logging level is restored to its previous state.
 */
#define ABLogToComponentWithLevelWhileExecutingBlock(_component, _level, _block)        \
do {                                                                                \
int _currentLevel = _lcl_component_level[_component];                           \
lcl_configure_by_component(_component, _level);                                 \
@try {                                                                          \
_block();                                                                   \
}                                                                               \
@catch (NSException *exception) {                                               \
@throw;                                                                     \
}                                                                               \
@finally {                                                                      \
lcl_configure_by_component(_component, _currentLevel);                      \
}                                                                               \
} while(false);

/**
 Temporarily changes the logging level for the configured ABLogComponent and executes the block. Any logging
 statements executed within the body of the block for the current logging component will log at the new
 logging level. After the block has finished excution, the logging level is restored to its previous state.
 */
#define ABLogWithLevelWhileExecutingBlock(_level, _block)                               \
ABLogToComponentWithLevelWhileExecutingBlock(ABLogComponent, _level, _block)

/**
 Set the Default Log Level
 
 Based on the presence of the DEBUG flag, we default the logging for the AppBand parent component
 to Info or Warning.
 
 You can override this setting by defining ABLogLevelDefault as a pre-processor macro.
 */
#ifndef ABLogLevelDefault
#ifdef DEBUG
#define ABLogLevelDefault ABLogLevelTrace
#else
#define ABLogLevelDefault ABLogLevelWarning
#endif
#endif

/**
 Initialize the logging environment
 */
void ABLogInitialize(void);
