require "chartboost"

print("Chartboost test")

-- LIST OF EVENTS --

chartboost:addEventListener(Event.CACHE_INTERSTITIAL, function(evt)
	print("CACHE_INTERSTITIAL "..evt.location)
end)

chartboost:addEventListener(Event.CLICK_INTERSTITIAL, function(evt)
	print("CLICK_INTERSTITIAL "..evt.location)
end)

chartboost:addEventListener(Event.CLOSE_INTERSTITIAL, function(evt)
	print("CLOSE_INTERSTITIAL "..evt.location)
end)

chartboost:addEventListener(Event.DISMISS_INTERSTITIAL, function(evt)
	print("DISMISS_INTERSTITIAL "..evt.location)
end)

chartboost:addEventListener(Event.FAIL_TO_LOAD_INTERSTITIAL, function(evt)
	print("FAIL_TO_LOAD_INTERSTITIAL "..evt.location)
end)

chartboost:addEventListener(Event.SHOW_INTERSTITIAL, function(evt)
	print("SHOW_INTERSTITIAL "..evt.location)
end)

chartboost:addEventListener(Event.CACHE_MORE_APPS, function()
	print("CACHE_MORE_APPS ")
end)

chartboost:addEventListener(Event.CLICK_MORE_APPS, function()
	print("CLICK_MORE_APPS ")
end)

chartboost:addEventListener(Event.CLOSE_MORE_APPS, function()
	print("CLOSE_MORE_APPS ")
end)

chartboost:addEventListener(Event.DISMISS_MORE_APPS, function()
	print("DISMISS_MORE_APPS ")
end)

chartboost:addEventListener(Event.FAIL_TO_LOAD_MORE_APPS, function()
	print("FAIL_TO_LOAD_MORE_APPS ")
end)

-- LIST OF API --

-- start session (appId, appSignature)
chartboost:startSession("APP_ID" , "APP_SIGNATURE") 

-- show cross promotion (location)
chartboost:showInterstitial()
--chartboost:showInterstitial("main menu")

-- cache interstitial (location)
chartboost:cacheInterstitial()
--chartboost:cacheInterstitial("main menu")

-- cachek more apps (location)
chartboost:cacheMoreApps()
--chartboost:cacheMoreApps("main menu")

-- has cached (location)
chartboost:hasCachedInterstitial()
--chartboost:hasCachedInterstitial("main menu")
