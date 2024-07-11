//
//  SettingKeys.h
//  LNPopupControllerExample
//
//  Created by Léo Natan on 18/03/2017.
//  Copyright © 2017 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString* PopupSetting _CF_TYPED_EXTENSIBLE_ENUM;

extern PopupSetting const PopupSettingBarStyle;
extern PopupSetting const PopupSettingInteractionStyle;
extern PopupSetting const PopupSettingProgressViewStyle;
extern PopupSetting const PopupSettingCloseButtonStyle;
extern PopupSetting const PopupSettingMarqueeEnabled;
extern PopupSetting const PopupSettingMarqueeCoordinationEnabled;
extern PopupSetting const PopupSettingHapticFeedbackEnabled;
extern PopupSetting const PopupSettingEnableCustomizations;
extern PopupSetting const PopupSettingExtendBar;
extern PopupSetting const PopupSettingHidesBottomBarWhenPushed;
extern PopupSetting const PopupSettingDisableScrollEdgeAppearance;
extern PopupSetting const PopupSettingVisualEffectViewBlurEffect;
extern PopupSetting const PopupSettingTouchVisualizerEnabled;
extern PopupSetting const PopupSettingCustomBarEverywhereEnabled;
extern PopupSetting const PopupSettingContextMenuEnabled;

extern PopupSetting const PopupSettingBarHideContentView;
extern PopupSetting const PopupSettingBarHideShadow;
extern PopupSetting const PopupSettingBarEnableLayoutDebug;
extern PopupSetting const PopupSettingForceRTL;
extern PopupSetting const PopupSettingDebugScaling;

extern PopupSetting const PopupSettingDisableDemoSceneColors;
extern PopupSetting const PopupSettingEnableFunkyInheritedFont;
extern PopupSetting const PopupSettingEnableExternalScenes;

extern PopupSetting const PopupSettingEnableCustomLabels;

@interface NSUserDefaults (LNPopupSettings)

@property (class, nonatomic, strong, readonly) NSUserDefaults* settingDefaults NS_SWIFT_NAME(settings);

@end

@interface NSNotificationCenter (LNPopupSettings)

- (id<NSObject>)addMainQueueObserverForName:(nullable NSNotificationName)name object:(nullable id)obj usingBlock:(void (^)(NSNotification * _Nonnull))block NS_SWIFT_UI_ACTOR;

@end

NS_ASSUME_NONNULL_END
