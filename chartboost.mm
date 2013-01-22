/*
 
 This code is MIT licensed, see http://www.opensource.org/licenses/mit-license.php
 (C) 2013 Nightspade
 
 */

#include "gideros.h"
#include "lua.h"
#include "lauxlib.h"
#import "Chartboost.h"

// some Lua helper functions
#ifndef abs_index
#define abs_index(L, i) ((i) > 0 || (i) <= LUA_REGISTRYINDEX ? (i) : lua_gettop(L) + (i) + 1)
#endif

static void luaL_newweaktable(lua_State *L, const char *mode)
{
	lua_newtable(L);			// create table for instance list
	lua_pushstring(L, mode);
	lua_setfield(L, -2, "__mode");	  // set as weak-value table
	lua_pushvalue(L, -1);             // duplicate table
	lua_setmetatable(L, -2);          // set itself as metatable
}

static void luaL_rawgetptr(lua_State *L, int idx, void *ptr)
{
	idx = abs_index(L, idx);
	lua_pushlightuserdata(L, ptr);
	lua_rawget(L, idx);
}

static void luaL_rawsetptr(lua_State *L, int idx, void *ptr)
{
	idx = abs_index(L, idx);
	lua_pushlightuserdata(L, ptr);
	lua_insert(L, -2);
	lua_rawset(L, idx);
}

enum
{
	GCHARTBOOST_CACHE_INTERSTITIAL_EVENT,
	GCHARTBOOST_CACHE_MORE_APPS_EVENT,
	GCHARTBOOST_CLICK_INTERSTITIAL_EVENT,
	GCHARTBOOST_CLICK_MORE_APPS_EVENT,
	GCHARTBOOST_CLOSE_INTERSTITIAL_EVENT,
	GCHARTBOOST_CLOSE_MORE_APPS_EVENT,
	GCHARTBOOST_DISMISS_INTERSTITIAL_EVENT,
	GCHARTBOOST_DISMISS_MORE_APPS_EVENT,
	GCHARTBOOST_FAIL_TO_LOAD_INTERSTITIAL_EVENT,
	GCHARTBOOST_FAIL_TO_LOAD_MORE_APPS_EVENT,
	GCHARTBOOST_SHOW_INTERSTITIAL_EVENT,
	GCHARTBOOST_SHOW_MORE_APPS_EVENT
};

static const char *CACHE_INTERSTITIAL = "cacheInterstitial";
static const char *CACHE_MORE_APPS = "cacheMoreApps";
static const char *CLICK_INTERSTITIAL = "clickInterstitial";
static const char *CLICK_MORE_APPS = "clickMoreApps";
static const char *CLOSE_INTERSTITIAL = "closeInterstitial";
static const char *CLOSE_MORE_APPS = "closeMoreApps";
static const char *DISMISS_INTERSTITIAL = "dismissInterstitial";
static const char *DISMISS_MORE_APPS = "dismissMoreApps";
static const char *FAIL_TO_LOAD_INTERSTITIAL = "failToLoadInterstitial";
static const char *FAIL_TO_LOAD_MORE_APPS = "failToLoadMoreApps";
static const char *SHOW_INTERSTITIAL = "showInterstitial";
static const char *SHOW_MORE_APPS = "showMoreApps";

static char keyWeak = ' ';

class ChartboostPlugin;

@interface ChartboostPluginDelegate : NSObject<ChartboostDelegate>
{
}

- (id) initWithInstance:(ChartboostPlugin*)instance;

@property (nonatomic, assign) ChartboostPlugin *instance;

@end

class ChartboostPlugin : public GEventDispatcherProxy
{
public:
    ChartboostPlugin(lua_State *L) : L(L), delegate_(nil)
	{
        delegate_ = [[ChartboostPluginDelegate alloc] initWithInstance:this];
    }
    
	~ChartboostPlugin()
	{
        delegate_.instance = nil;
        [delegate_ release];
    }
    
    void startSession(const char* appId, const char* appSignature)
	{
        Chartboost* cb = [Chartboost sharedChartboost];
        cb.delegate = delegate_;
        cb.appId = [NSString stringWithUTF8String:appId];
        cb.appSignature = [NSString stringWithUTF8String:appSignature];
        [cb startSession];
	}
    
	void showInterstitial(const char* location)
	{
		if (location){
            return [[Chartboost sharedChartboost] showInterstitial:[NSString stringWithUTF8String:location]];
        } else {
            return [[Chartboost sharedChartboost] showInterstitial];
        }
	}
    
    void cacheInterstitial(const char* location)
	{
		if (location){
            return [[Chartboost sharedChartboost] cacheInterstitial:[NSString stringWithUTF8String:location]];
        } else {
            return [[Chartboost sharedChartboost] cacheInterstitial];
        }
	}
    
    void cacheMoreApps()
	{
		[[Chartboost sharedChartboost] cacheMoreApps];
	}
    
    bool hasCachedInterstitial(const char* location)
    {
        if (location){
            return [[Chartboost sharedChartboost] hasCachedInterstitial:[NSString stringWithUTF8String:location]];
        } else {
            return [[Chartboost sharedChartboost] hasCachedInterstitial];
        }
    }
    
    void dispatchEvent(int type, NSString *event)
	{
		luaL_rawgetptr(L, LUA_REGISTRYINDEX, &keyWeak);
		luaL_rawgetptr(L, -1, this);
        
		if (lua_isnil(L, -1))
		{
			lua_pop(L, 2);
			return;
		}
        
		lua_getfield(L, -1, "dispatchEvent");
        
		lua_pushvalue(L, -2);
        
		lua_getglobal(L, "Event");
		lua_getfield(L, -1, "new");
		lua_remove(L, -2);
        
		switch (type)
		{
            case GCHARTBOOST_CACHE_INTERSTITIAL_EVENT:
                lua_pushstring(L, CACHE_INTERSTITIAL);
                break;
            case GCHARTBOOST_CACHE_MORE_APPS_EVENT:
                lua_pushstring(L, CACHE_MORE_APPS);
                break;
            case GCHARTBOOST_CLICK_INTERSTITIAL_EVENT:
                lua_pushstring(L, CLICK_INTERSTITIAL);
                break;
            case GCHARTBOOST_CLICK_MORE_APPS_EVENT:
                lua_pushstring(L, CLICK_MORE_APPS);
                break;
            case GCHARTBOOST_CLOSE_INTERSTITIAL_EVENT:
                lua_pushstring(L, CLOSE_INTERSTITIAL);
                break;
            case GCHARTBOOST_CLOSE_MORE_APPS_EVENT:
                lua_pushstring(L, CLOSE_MORE_APPS);
                break;
            case GCHARTBOOST_DISMISS_INTERSTITIAL_EVENT:
                lua_pushstring(L, DISMISS_INTERSTITIAL);
                break;
            case GCHARTBOOST_DISMISS_MORE_APPS_EVENT:
                lua_pushstring(L, DISMISS_MORE_APPS);
                break;
            case GCHARTBOOST_FAIL_TO_LOAD_INTERSTITIAL_EVENT:
                lua_pushstring(L, FAIL_TO_LOAD_INTERSTITIAL);
                break;
            case GCHARTBOOST_FAIL_TO_LOAD_MORE_APPS_EVENT:
                lua_pushstring(L, FAIL_TO_LOAD_MORE_APPS);
                break;
            case GCHARTBOOST_SHOW_INTERSTITIAL_EVENT:
                lua_pushstring(L, SHOW_INTERSTITIAL);
                break;
            case GCHARTBOOST_SHOW_MORE_APPS_EVENT:
                lua_pushstring(L, SHOW_MORE_APPS);
                break;
		}
        
		lua_call(L, 1, 1);
        
		if (type == GCHARTBOOST_CACHE_INTERSTITIAL_EVENT ||
			type == GCHARTBOOST_CLICK_INTERSTITIAL_EVENT ||
			type == GCHARTBOOST_CLOSE_INTERSTITIAL_EVENT ||
			type == GCHARTBOOST_DISMISS_INTERSTITIAL_EVENT ||
			type == GCHARTBOOST_FAIL_TO_LOAD_INTERSTITIAL_EVENT ||
			type == GCHARTBOOST_SHOW_INTERSTITIAL_EVENT)
		{
			lua_pushstring(L, [event UTF8String]);
			lua_setfield(L, -2, "location");
		}
        
		lua_call(L, 2, 0);
        
		lua_pop(L, 2);
	}
    
private:
	lua_State *L;
    
    ChartboostPluginDelegate *delegate_;
};

@implementation ChartboostPluginDelegate

@synthesize instance = instance_;

-(id)initWithInstance:(ChartboostPlugin*)instance
{
	if (self = [super init])
	{
        instance_  = instance;
	}
	
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

// Called when an interstitial has been received, before it is presented on screen
// Return NO if showing an interstitial is currently inappropriate, for example if the user has entered the main game mode
- (BOOL)shouldDisplayInterstitial:(NSString *)location
{
    if (instance_) instance_->dispatchEvent(GCHARTBOOST_SHOW_INTERSTITIAL_EVENT, location);
    return YES;
}

// Called when the user dismisses the interstitial
- (void)didDismissInterstitial:(NSString *)location
{
    [[Chartboost sharedChartboost] cacheInterstitial:location];
    if (instance_) instance_->dispatchEvent(GCHARTBOOST_DISMISS_INTERSTITIAL_EVENT, location);
}

// Same as above, but only called when dismissed for a close
- (void)didCloseInterstitial:(NSString *)location
{
    if (instance_) instance_->dispatchEvent(GCHARTBOOST_CLOSE_INTERSTITIAL_EVENT, location);
}

// Same as above, but only called when dismissed for a click
- (void)didClickInterstitial:(NSString *)location
{
    if (instance_) instance_->dispatchEvent(GCHARTBOOST_CLICK_INTERSTITIAL_EVENT, location);
}

// Called when an interstitial has failed to come back from the server
// This may be due to network connection or that no interstitial is available for that user
- (void)didFailToLoadInterstitial:(NSString *)location
{
    if (instance_) instance_->dispatchEvent(GCHARTBOOST_FAIL_TO_LOAD_INTERSTITIAL_EVENT, location);
}

// Called when an interstitial has been received and cached.
- (void)didCacheInterstitial:(NSString *)location
{
    if (instance_) instance_->dispatchEvent(GCHARTBOOST_CACHE_INTERSTITIAL_EVENT, location);
}

// Called before requesting the more apps view from the back-end
// Return NO if when showing the loading view is not the desired user experience
- (BOOL)shouldDisplayMoreApps
{
    if (instance_) instance_->dispatchEvent(GCHARTBOOST_SHOW_MORE_APPS_EVENT, NULL);
    return YES;
}

// Called when the user dismisses the more apps view
- (void)didDismissMoreApps
{
    [[Chartboost sharedChartboost] cacheMoreApps];
    if (instance_) instance_->dispatchEvent(GCHARTBOOST_DISMISS_MORE_APPS_EVENT, NULL);
}

// Same as above, but only called when dismissed for a close
- (void)didCloseMoreApps
{
    if (instance_) instance_->dispatchEvent(GCHARTBOOST_CLOSE_MORE_APPS_EVENT, NULL);
}

// Same as above, but only called when dismissed for a click
- (void)didClickMoreApps
{
    if (instance_) instance_->dispatchEvent(GCHARTBOOST_CLICK_MORE_APPS_EVENT, NULL);
}

// Called when a more apps page has failed to come back from the server
- (void)didFailToLoadMoreApps
{
    if (instance_) instance_->dispatchEvent(GCHARTBOOST_FAIL_TO_LOAD_MORE_APPS_EVENT, NULL);
}

// Called when the More Apps page has been received and cached
- (void)didCacheMoreApps
{
    if (instance_) instance_->dispatchEvent(GCHARTBOOST_CACHE_MORE_APPS_EVENT, NULL);
}

@end

static int destruct(lua_State* L)
{
	void *ptr =*(void**)lua_touserdata(L, 1);
	GReferenced* object = static_cast<GReferenced*>(ptr);
	ChartboostPlugin *instance = static_cast<ChartboostPlugin*>(object->proxy());
	instance->unref();
    
	return 0;
}

static ChartboostPlugin *getInstance(lua_State *L, int index)
{
	GReferenced *object = static_cast<GReferenced*>(g_getInstance(L, "Chartboost", index));
	ChartboostPlugin *instance = static_cast<ChartboostPlugin*>(object->proxy());
    
	return instance;
}

static int startSession(lua_State *L)
{
	ChartboostPlugin *instance = getInstance(L, 1);
	const char *appId = lua_tostring(L, 2);
	const char *appSignature = lua_tostring(L, 3);
	instance->startSession(appId, appSignature);
    
	return 0;
}

static int showInterstitial(lua_State *L)
{
	ChartboostPlugin *instance = getInstance(L, 1);
    const char *location = lua_tostring(L, 2);
	instance->showInterstitial(location);
    
	return 0;
}

static int cacheInterstitial(lua_State *L)
{
	ChartboostPlugin *instance = getInstance(L, 1);
    const char *location = lua_tostring(L, 2);
	instance->cacheInterstitial(location);
    
	return 0;
}

static int cacheMoreApps(lua_State *L)
{
	ChartboostPlugin *instance = getInstance(L, 1);
	instance->cacheMoreApps();
    
	return 0;
}

static int hasCachedInterstitial(lua_State *L)
{
	ChartboostPlugin *instance = getInstance(L, 1);
    const char *location = lua_tostring(L, 2);
	lua_pushboolean(L, instance->hasCachedInterstitial(location));
    
	return 1;
}

static int loader(lua_State *L)
{
	const luaL_Reg functionList[] = {
		{"startSession", startSession},
		{"showInterstitial", showInterstitial},
        {"cacheInterstitial", cacheInterstitial},
        {"cacheMoreApps", cacheMoreApps},
        {"hasCachedInterstitial", hasCachedInterstitial},
		{NULL, NULL}
	};
    
    g_createClass(L, "Chartboost", "EventDispatcher", NULL, destruct, functionList);
    
    // create a weak table in LUA_REGISTRYINDEX that can be accessed with the address of keyWeak
	luaL_newweaktable(L, "v");
	luaL_rawsetptr(L, LUA_REGISTRYINDEX, &keyWeak);
    
	lua_getglobal(L, "Event");
	lua_pushstring(L, CACHE_INTERSTITIAL);
	lua_setfield(L, -2, "CACHE_INTERSTITIAL");
	lua_pushstring(L, CACHE_MORE_APPS);
	lua_setfield(L, -2, "CACHE_MORE_APPS");
	lua_pushstring(L, CLICK_INTERSTITIAL);
	lua_setfield(L, -2, "CLICK_INTERSTITIAL");
	lua_pushstring(L, CLICK_MORE_APPS);
	lua_setfield(L, -2, "CLICK_MORE_APPS");
	lua_pushstring(L, CLOSE_INTERSTITIAL);
	lua_setfield(L, -2, "CLOSE_INTERSTITIAL");
	lua_pushstring(L, CLOSE_MORE_APPS);
	lua_setfield(L, -2, "CLOSE_MORE_APPS");
	lua_pushstring(L, DISMISS_INTERSTITIAL);
	lua_setfield(L, -2, "DISMISS_INTERSTITIAL");
	lua_pushstring(L, DISMISS_MORE_APPS);
	lua_setfield(L, -2, "DISMISS_MORE_APPS");
	lua_pushstring(L, FAIL_TO_LOAD_INTERSTITIAL);
	lua_setfield(L, -2, "FAIL_TO_LOAD_INTERSTITIAL");
	lua_pushstring(L, FAIL_TO_LOAD_MORE_APPS);
	lua_setfield(L, -2, "FAIL_TO_LOAD_MORE_APPS");
	lua_pushstring(L, SHOW_INTERSTITIAL);
	lua_setfield(L, -2, "SHOW_INTERSTITIAL");
	lua_pushstring(L, SHOW_MORE_APPS);
	lua_setfield(L, -2, "SHOW_MORE_APPS");
	lua_pop(L, 1);
    
	ChartboostPlugin *instance = new ChartboostPlugin(L);
	g_pushInstance(L, "Chartboost", instance->object());
    
	luaL_rawgetptr(L, LUA_REGISTRYINDEX, &keyWeak);
	lua_pushvalue(L, -2);
	luaL_rawsetptr(L, -2, instance);
	lua_pop(L, 1);
    
	lua_pushvalue(L, -1);
	lua_setglobal(L, "chartboost");
    
    return 1;
}

static void g_initializePlugin(lua_State *L)
{
    lua_getglobal(L, "package");
	lua_getfield(L, -1, "preload");
    
	lua_pushcfunction(L, loader);
	lua_setfield(L, -2, "chartboost");
    
	lua_pop(L, 2);
}

static void g_deinitializePlugin(lua_State *L)
{
    
}

REGISTER_PLUGIN("Chartboost", "2013.1")
