//
//  SettingKeys.m
//  LNPopupSettings
//
//  Created by Léo Natan on 2023-12-15.
//  Copyright © 2023-2024 Léo Natan. All rights reserved.
//

#import "SettingKeys.h"
#import <LNTouchVisualizer/LNTouchVisualizer.h>
@import ObjectiveC;

PopupSetting const PopupSettingBarStyle = @"PopupSettingsBarStyle";
PopupSetting const PopupSettingInteractionStyle = @"PopupSettingsInteractionStyle";
PopupSetting const PopupSettingProgressViewStyle = @"PopupSettingsProgressViewStyle";
PopupSetting const PopupSettingCloseButtonStyle = @"PopupSettingsCloseButtonStyle";
PopupSetting const PopupSettingCloseButtonPositioning = @"PopupSettingCloseButtonPositioning";
PopupSetting const PopupSettingMarqueeEnabled = @"PopupSettingsMarqueeEnabled";
PopupSetting const PopupSettingMarqueeCoordinationEnabled = @"PopupSettingMarqueeCoordinationEnabled";
PopupSetting const PopupSettingHapticFeedbackEnabled = @"PopupSettingsHapticFeedbackEnabled";
PopupSetting const PopupSettingEnableCustomizations = @"PopupSettingsEnableCustomizations";
PopupSetting const PopupSettingTransitionType = @"PopupSettingTransitionType";
PopupSetting const PopupSettingExtendBar = @"PopupSettingsExtendBar";
PopupSetting const PopupSettingHidesBottomBarWhenPushed = @"PopupSettingsHidesBottomBarWhenPushed";
PopupSetting const PopupSettingDisableScrollEdgeAppearance = @"PopupSettingsDisableScrollEdgeAppearance";
PopupSetting const PopupSettingVisualEffectViewBlurEffect = @"PopupSettingsVisualEffectViewBlurEffect";
PopupSetting const PopupSettingShineEnabled = @"PopupSettingShineEnabled";
PopupSetting const PopupSettingTouchVisualizerEnabled = @"PopupSettingsTouchVisualizerEnabled";
PopupSetting const PopupSettingCustomBarEverywhereEnabled = @"PopupSettingsCustomBarEverywhereEnabled";
PopupSetting const PopupSettingContextMenuEnabled = @"PopupSettingsContextMenuEnabled";
PopupSetting const PopupSettingLimitFloatingWidth = @"PopupSettingLimitFloatingWidth";
PopupSetting const PopupSettingTabBarHasSidebar = @"PopupSettingTabBarHasSidebar";

PopupSetting const PopupSettingBarHideContentView = @"__LNPopupBarHideContentView";
PopupSetting const PopupSettingBarHideShadow = @"__LNPopupBarHideShadow";
PopupSetting const PopupSettingBarEnableLayoutDebug = @"__LNPopupBarEnableLayoutDebug";
PopupSetting const PopupSettingEnableSlowTransitionsDebug = @"__LNPopupEnableSlowTransitionsDebug";
PopupSetting const PopupSettingForceRTL = @"__LNForceRTL";
PopupSetting const PopupSettingDebugScaling = @"__LNDebugScaling";

PopupSetting const PopupSettingInvertDemoSceneColors = @"__PopupSettingInvertDemoSceneColors";
PopupSetting const PopupSettingDisableDemoSceneColors = @"__LNPopupBarDisableDemoSceneColors";
PopupSetting const PopupSettingLongerLoremIpsumTitles = @"__PopupSettingLongerLoremIpsumTitles";
PopupSetting const PopupSettingEnableFunkyInheritedFont = @"DemoAppEnableFunkyInheritedFont";
PopupSetting const PopupSettingEnableExternalScenes = @"DemoAppEnableExternalScenes";

PopupSetting const PopupSettingEnableCustomLabels = @"DemoAppEnableCustomLabels";

PopupSetting const PopupSettingUseScrollingPopupContent = @"PopupSettingUseScrollingPopupContent";

@implementation NSUserDefaults (LNPopupSettings)

+ (NSUserDefaults*)settingDefaults
{
	static NSUserDefaults* rv = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		rv = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.LeoNatan.LNPopupSettings"];
		
		[rv registerDefaults:@{
			PopupSettingLimitFloatingWidth: @YES,
			PopupSettingHidesBottomBarWhenPushed: @YES,
			PopupSettingExtendBar: @YES,
			PopupSettingHapticFeedbackEnabled: @NO,
			PopupSettingMarqueeEnabled: @(LNPopupSettingsHasOS26Glass() ? YES : NO),
			PopupSettingMarqueeCoordinationEnabled: @YES,
			PopupSettingTabBarHasSidebar: @YES,
			PopupSettingTransitionType: @0,
			PopupSettingInvertDemoSceneColors: @YES,
		}];
	});
	
	return rv;
}

@end

#if !TARGET_OS_MACCATALYST
__attribute__((constructor))
void fixUIKitSwiftUIShit(void)
{
	if(LNPopupSettingsHasOS26Glass())
	{
		return;
	}
	
	{
		Class cls = UICollectionViewCell.class;
		void (*orig)(id, SEL, BOOL, BOOL);
		SEL sel = NSSelectorFromString(@"_setHighlighted:animated:");
		Method m = class_getInstanceMethod(cls, sel);
		orig = (void*)method_getImplementation(m);
		method_setImplementation(m, imp_implementationWithBlock(^(UICollectionViewCell* _self,
																  BOOL highlighted,
																  BOOL animated) {
			if(highlighted == NO && [NSStringFromClass(_self.class) hasPrefix:@"SwiftUI."])
			{
				animated = YES;
			}
			
			orig(_self, sel, highlighted, animated);
		}));
	}
	{
		if(@available(iOS 17, *))
		{
			Class cls = NSClassFromString(@"UITabBarItem");
			SEL sel = NSSelectorFromString(@"setScrollEdgeAppearance:");
			void (*orig)(id, SEL, UITabBarAppearance*);
			Method m = class_getInstanceMethod(cls, sel);
			orig = (void*)method_getImplementation(m);
			method_setImplementation(m, imp_implementationWithBlock(^(id _self, UITabBarAppearance* appearance) {
				if([[appearance.class valueForKey:@"isFromSwiftUI"] boolValue] && appearance.backgroundEffect == nil && appearance.backgroundColor == nil && appearance.backgroundImage == nil)
				{
					appearance = nil;
				}
				
				
				orig(_self, sel, appearance);
			}));
		}
	}
}

@interface LNTouchVisualizerSupport: NSObject @end
@implementation LNTouchVisualizerSupport

+ (void)load
{
	@autoreleasepool
	{
		[NSUserDefaults.settingDefaults addObserver:(id)self forKeyPath:PopupSettingTouchVisualizerEnabled options:0 context:NULL];
		[NSUserDefaults.settingDefaults addObserver:(id)self forKeyPath:PopupSettingDebugScaling options:0 context:NULL];
		
		
		[NSNotificationCenter.defaultCenter addObserverForName:UISceneWillConnectNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self _updateTouchVisualizer];
				[self _updateScalingAnimated:NO];
			});
		}];
	}
}

+ (void)_updateTouchVisualizer
{
	for(UIWindowScene* windowScene in UIApplication.sharedApplication.connectedScenes)
	{
		if([windowScene isKindOfClass:UIWindowScene.class] == NO)
		{
			continue;
		}
		
		windowScene.touchVisualizerEnabled = [NSUserDefaults.settingDefaults boolForKey:PopupSettingTouchVisualizerEnabled];
		LNTouchConfig* rippleConfig = [LNTouchConfig rippleConfig];
		rippleConfig.fillColor = UIColor.systemPinkColor;
		windowScene.touchVisualizerWindow.touchRippleConfig = rippleConfig;
	}
}

+ (void)_updateScalingAnimated:(BOOL)animated
{	
	for(UIWindowScene* windowScene in UIApplication.sharedApplication.connectedScenes)
	{
		if([windowScene isKindOfClass:UIWindowScene.class] == NO)
		{
			continue;
		}
		
		CGFloat desiredWidth = [NSUserDefaults.settingDefaults doubleForKey:PopupSettingDebugScaling];
		if(desiredWidth == 0)
		{
			desiredWidth = windowScene.screen.fixedCoordinateSpace.bounds.size.width;
		}
		   
		CGFloat scale = windowScene.screen.fixedCoordinateSpace.bounds.size.width / desiredWidth;
		
		for(UIWindow* window in windowScene.windows)
		{
			window.layer.allowsEdgeAntialiasing = YES;
			window.layer.magnificationFilter = kCAFilterTrilinear;
			window.layer.minificationFilter = kCAFilterTrilinear;
			CGAffineTransform targetTransform = scale == 1.0 ? CGAffineTransformIdentity : CGAffineTransformMakeScale(scale, scale);
			CGRect targetFrame = windowScene.screen.bounds;
			if(CGAffineTransformEqualToTransform(window.transform, targetTransform) == NO)
			{
				dispatch_block_t update = ^ {
					[UIView performWithoutAnimation:^{
						window.transform = targetTransform;
						window.frame = targetFrame;
					}];
				};
				
				if(animated == NO)
				{
					update();
					return;
				}
				
				[UIView transitionWithView:window duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:update completion:nil];
			}
		}
	}
}

+ (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
	[self _updateTouchVisualizer];
	[self _updateScalingAnimated:YES];
}

@end

#endif

@implementation NSNotificationCenter (LNPopupSettings)

- (id<NSObject>)addMainQueueObserverForName:(nullable NSNotificationName)name object:(nullable id)obj usingBlock:(void (^)(NSNotification * _Nonnull))block
{
	return [self addObserverForName:name object:obj queue:NSOperationQueue.mainQueue usingBlock:block];
}

@end


BOOL LNPopupSettingsHasOS26Glass(void)
{
	static BOOL rv;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if(@available(iOS 26.0, *))
		{
			rv = ![[NSBundle.mainBundle objectForInfoDictionaryKey:@"UIDesignRequiresCompatibility"] boolValue];
		}
		else
		{
			rv = NO;
		}
	});
	
	return rv;
}

UIButton* LNPopupShinyButton(void)
{
	UIButtonConfiguration* config = [UIButtonConfiguration valueForKey:@"_posterSwitcherGlassButtonConfiguration"];
	UIButton* button = [UIButton buttonWithConfiguration:config primaryAction:nil];
	return button;
}

@interface NSBundle ()

- (NSAttributedString *)localizedAttributedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName localization:(id)arg4;

@end

@interface NSBundle (HebrewTransliteration) @end

@implementation NSBundle (HebrewTransliteration)

- (NSString *)_hebrew_localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName localizations:(id)arg4
{
	return [self _hebrew_localizedStringForKey:key value:value table:tableName];
}

- (NSAttributedString *)_hebrew_localizedAttributedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
	return [[NSAttributedString alloc] initWithString:[self _hebrew_localizedStringForKey:key value:value table:tableName]];
}

- (NSAttributedString *)_hebrew_localizedAttributedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName localization:(id)arg4
{
	return [[NSAttributedString alloc] initWithString:[self _hebrew_localizedStringForKey:key value:value table:tableName]];
}

- (NSString *)_hebrew_localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
	NSString* stringToTransliterate = value.length > 0 && [value isEqualToString:@"<unlocalized>"] == NO ? value : key;
	stringToTransliterate = [stringToTransliterate stringByReplacingOccurrencesOfString:@"LNPopupController" withString:@"אֶלְאֶנפּוֹפּאָפְּקוֹנְטְרוֹלֶר"];
	stringToTransliterate = [stringToTransliterate stringByReplacingOccurrencesOfString:@"LNPopupUI" withString:@"אֶלְאֶנפּוֹפּאָפְּיֻואָיְי"];
	stringToTransliterate = [stringToTransliterate stringByReplacingOccurrencesOfString:@"LNPopup" withString:@"אֶלְאֶנפּוֹפּאָפ"];
	stringToTransliterate = [stringToTransliterate stringByReplacingOccurrencesOfString:@"Controller" withString:@"קוֹנְטְרוֹלֶר"];
	stringToTransliterate = [[stringToTransliterate stringByReplacingOccurrencesOfString:@"ll" withString:@"l"] stringByReplacingOccurrencesOfString:@"tt" withString:@"t"];
	stringToTransliterate = [stringToTransliterate stringByReplacingOccurrencesOfString:@"View" withString:@"וְיוֻ"];
	stringToTransliterate = [stringToTransliterate stringByReplacingOccurrencesOfString:@"[MapKit] Apple Maps Brand Mark" withString:@"מַפס"];
	stringToTransliterate = [stringToTransliterate stringByReplacingOccurrencesOfString:@"Exit" withString:@"אֶקְזִיט"];
	
	return [stringToTransliterate stringByApplyingTransform:NSStringTransformLatinToHebrew reverse:NO];
}

+ (void)load
{
	@autoreleasepool
	{
		if([NSUserDefaults.standardUserDefaults boolForKey:PopupSettingForceRTL] == NO)
		{
			return;
		}
		
		Method m1 = class_getInstanceMethod(NSBundle.class, @selector(localizedStringForKey:value:table:));
		Method m2 = class_getInstanceMethod(NSBundle.class, @selector(_hebrew_localizedStringForKey:value:table:));
		method_exchangeImplementations(m1, m2);
		
		m1 = class_getInstanceMethod(NSBundle.class, @selector(localizedStringForKey:value:table:localizations:));
		m2 = class_getInstanceMethod(NSBundle.class, @selector(_hebrew_localizedStringForKey:value:table:localizations:));
		method_exchangeImplementations(m1, m2);
		
		m1 = class_getInstanceMethod(NSBundle.class, @selector(localizedAttributedStringForKey:value:table:));
		m2 = class_getInstanceMethod(NSBundle.class, @selector(_hebrew_localizedAttributedStringForKey:value:table:));
		method_exchangeImplementations(m1, m2);
		
		m1 = class_getInstanceMethod(NSBundle.class, @selector(localizedAttributedStringForKey:value:table:localization:));
		m2 = class_getInstanceMethod(NSBundle.class, @selector(_hebrew_localizedAttributedStringForKey:value:table:localization:));
		method_exchangeImplementations(m1, m2);
	}
}

@end
