//
//  SettingKeys.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 18/03/2017.
//  Copyright © 2017 Leo Natan. All rights reserved.
//

#import "SettingKeys.h"
#import <LNTouchVisualizer/LNTouchVisualizer.h>

NSString* const PopupSettingBarStyle = @"PopupSettingsBarStyle";
NSString* const PopupSettingInteractionStyle = @"PopupSettingsInteractionStyle";
NSString* const PopupSettingProgressViewStyle = @"PopupSettingsProgressViewStyle";
NSString* const PopupSettingCloseButtonStyle = @"PopupSettingsCloseButtonStyle";
NSString* const PopupSettingMarqueeEnabled = @"PopupSettingsMarqueeEnabled";
NSString* const PopupSettingMarqueeCoordinationEnabled = @"PopupSettingMarqueeCoordinationEnabled";
NSString* const PopupSettingHapticFeedbackEnabled = @"PopupSettingsHapticFeedbackEnabled";
NSString* const PopupSettingEnableCustomizations = @"PopupSettingsEnableCustomizations";
NSString* const PopupSettingExtendBar = @"PopupSettingsExtendBar";
NSString* const PopupSettingHidesBottomBarWhenPushed = @"PopupSettingsHidesBottomBarWhenPushed";
NSString* const PopupSettingDisableScrollEdgeAppearance = @"PopupSettingsDisableScrollEdgeAppearance";
NSString* const PopupSettingVisualEffectViewBlurEffect = @"PopupSettingsVisualEffectViewBlurEffect";
NSString* const PopupSettingTouchVisualizerEnabled = @"PopupSettingsTouchVisualizerEnabled";
NSString* const PopupSettingCustomBarEverywhereEnabled = @"PopupSettingsCustomBarEverywhereEnabled";
NSString* const PopupSettingContextMenuEnabled = @"PopupSettingsContextMenuEnabled";

NSString* const PopupSettingBarHideContentView = @"__LNPopupBarHideContentView";
NSString* const PopupSettingBarHideShadow = @"__LNPopupBarHideShadow";
NSString* const PopupSettingBarEnableLayoutDebug = @"__LNPopupBarEnableLayoutDebug";
NSString* const PopupSettingForceRTL = @"__LNForceRTL";
NSString* const PopupSettingDebugScaling = @"__LNDebugScaling";

NSString* const PopupSettingDisableDemoSceneColors = @"__LNPopupBarDisableDemoSceneColors";
NSString* const PopupSettingEnableFunkyInheritedFont = @"DemoAppEnableFunkyInheritedFont";
NSString* const PopupSettingEnableExternalScenes = @"DemoAppEnableExternalScenes";

@import ObjectiveC;

@implementation NSUserDefaults (LNPopupSettings)

+ (NSUserDefaults*)settingDefaults
{
	static NSUserDefaults* rv = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		rv = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.LeoNatan.LNPopupSettings"];
	});
	
	return rv;
}

@end

__attribute__((constructor))
void fixUIKitSwiftUIShit(void)
{
	[NSUserDefaults.standardUserDefaults removeObjectForKey:@"com.apple.SwiftUI.DisableCollectionViewBackedGroupedLists"];
	[NSUserDefaults.standardUserDefaults registerDefaults:@{@"com.apple.SwiftUI.DisableCollectionViewBackedGroupedLists": @YES}];
	
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
			desiredWidth = windowScene.screen.bounds.size.width;
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
