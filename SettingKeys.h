//
//  SettingKeys.h
//  LNPopupControllerExample
//
//  Created by Leo Natan on 18/03/2017.
//  Copyright © 2017 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString* const PopupSettingsBarStyle;
extern NSString* const PopupSettingsInteractionStyle;
extern NSString* const PopupSettingsProgressViewStyle;
extern NSString* const PopupSettingsCloseButtonStyle;
extern NSString* const PopupSettingsMarqueeStyle;
extern NSString* const PopupSettingsHapticFeedbackStyle;
extern NSString* const PopupSettingsEnableCustomizations;
extern NSString* const PopupSettingsExtendBar;
extern NSString* const PopupSettingsHidesBottomBarWhenPushed;
extern NSString* const PopupSettingsDisableScrollEdgeAppearance;
extern NSString* const PopupSettingsVisualEffectViewBlurEffect;
extern NSString* const PopupSettingsTouchVisualizerEnabled;
extern NSString* const PopupSettingsCustomBarEverywhereEnabled;
extern NSString* const PopupSettingsContextMenuEnabled;

extern NSString* const __LNPopupBarHideContentView;
extern NSString* const __LNPopupBarHideShadow;
extern NSString* const __LNPopupBarEnableLayoutDebug;
extern NSString* const __LNForceRTL;
extern NSString* const __LNDebugScaling;

extern NSString* const DemoAppDisableDemoSceneColors;
extern NSString* const DemoAppEnableFunkyInheritedFont;
extern NSString* const DemoAppEnableExternalScenes;

@interface NSUserDefaults (LNPopupSettings)

@property (class, nonatomic, strong, readonly) NSUserDefaults* settingDefaults NS_SWIFT_NAME(settings);

@end

NS_ASSUME_NONNULL_END
