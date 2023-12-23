//
//  SettingsViewController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 02/10/2023.
//  Copyright © 2023 Leo Natan. All rights reserved.
//

import SwiftUI

#if LNPOPUP

import LNPopupController

extension Notification.Name {
	static let textVisited = Notification.Name("textVisited")
}

extension UserDefaults {
	func object(forKey setting: PopupSetting) -> Any? {
		return object(forKey: setting.rawValue)
	}
	
	func bool(forKey setting: PopupSetting) -> Bool {
		return bool(forKey: setting.rawValue)
	}
	
	func set(_ value: Any?, forKey setting: PopupSetting) {
		set(value, forKey: setting.rawValue)
	}
	
	func removeObject(forKey setting: PopupSetting) {
		removeObject(forKey: setting.rawValue)
	}
}

extension AppStorage {
	public init(wrappedValue: Value, _ key: PopupSetting, store: UserDefaults? = nil) where Value == Bool {
		self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
	}
	public init(wrappedValue: Value, _ key: PopupSetting, store: UserDefaults? = nil) where Value == Int {
		self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
	}
	public init(wrappedValue: Value, _ key: PopupSetting, store: UserDefaults? = nil) where Value == Double {
		self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
	}
	public init(wrappedValue: Value, _ key: PopupSetting, store: UserDefaults? = nil) where Value == String {
		self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
	}
	public init(wrappedValue: Value, _ key: PopupSetting, store: UserDefaults? = nil) where Value == URL {
		self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
	}
	public init(wrappedValue: Value, _ key: PopupSetting, store: UserDefaults? = nil) where Value == Data {
		self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
	}
	public init(wrappedValue: Value, _ key: PopupSetting, store: UserDefaults? = nil) where Value : RawRepresentable, Value.RawValue == Int {
		self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
	}
	public init(wrappedValue: Value, _ key: PopupSetting, store: UserDefaults? = nil) where Value : RawRepresentable, Value.RawValue == String {
		self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
	}
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension AppStorage where Value : ExpressibleByNilLiteral {
	public init(_ key: PopupSetting, store: UserDefaults? = nil) where Value == Bool? {
		self.init(key.rawValue, store: store)
	}
	public init(_ key: PopupSetting, store: UserDefaults? = nil) where Value == Int? {
		self.init(key.rawValue, store: store)
	}
	public init(_ key: PopupSetting, store: UserDefaults? = nil) where Value == Double? {
		self.init(key.rawValue, store: store)
	}
	public init(_ key: PopupSetting, store: UserDefaults? = nil) where Value == String? {
		self.init(key.rawValue, store: store)
	}
	public init(_ key: PopupSetting, store: UserDefaults? = nil) where Value == URL? {
		self.init(key.rawValue, store: store)
	}
	public init(_ key: PopupSetting, store: UserDefaults? = nil) where Value == Data? {
		self.init(key.rawValue, store: store)
	}
}

extension UIBlurEffect.Style {
	static let `default` = UIBlurEffect.Style(rawValue: 0xffff)!
}

fileprivate extension Picker where Label == EmptyView {
	init(selection: Binding<SelectionValue>, @ViewBuilder content: () -> Content) {
		self.init(selection: selection, content: content) {
			EmptyView()
		}
	}
}

fileprivate var isLNPopupUIExample: Bool = {
	return ProcessInfo.processInfo.processName == "LNPopupUIExample"
}()

fileprivate extension String {
	func matches(_ another: String) -> Bool {
		return range(of: another, options: [.caseInsensitive]) != nil
	}
}

fileprivate struct LNText: View {
	let text: Text
	public init(_ content: String) {
		NotificationCenter.default.post(name: .textVisited, object: content)
		
		@AppStorage(PopupSetting.forceRTL) var forceRTL: Bool = false
		
		if isLNPopupUIExample || forceRTL == false {
			text = Text(LocalizedStringKey(content))
		} else {
			text = Text(content.applyingTransform(.latinToHebrew, reverse: false)!)
		}
	}
	
	var body: some View {
		text
	}
}

fileprivate func LNTextCollector<Content>(_ container: inout [String], content: () -> Content) -> Content {
	var results = [String]()
	let observer = NotificationCenter.default.addObserver(forName: .textVisited, object: nil, queue: nil) { note in
		results.append(note.object as! String)
	}
	
	let rv = content()
	
	NotificationCenter.default.removeObserver(observer)
	container.append(contentsOf: results)
	
	return rv
}

fileprivate struct LNHeaderFooterView: View {
	let content: LNText
	public init(_ content: String) {
		self.content = LNText(content)
	}
	
	var body: some View {
		content.font(.footnote)
	}
}

fileprivate func requiredPadding() -> CGFloat? {
	guard UserDefaults.standard.bool(forKey: "com.apple.SwiftUI.DisableCollectionViewBackedGroupedLists") == false else {
		return 0
	}
	
	return 4.167
}

fileprivate struct CellPaddedText: View {
	let content: LNText
	public init(_ content: String) {
		self.content = LNText(content)
	}
	
	var body: some View {
		content
			.padding([.top, .bottom], requiredPadding())
	}
}

fileprivate struct CellPaddedToggle: View {
	let isHidden: Bool
	let title: LNText
	let isOn: Binding<Bool>
	
	init(_ title: String, isOn: Binding<Bool>, searchString: String) {
		isHidden = searchString.isEmpty == false && title.matches(searchString) == false
		self.title = LNText(title)
		self.isOn = isOn
	}
	
	var body: some View {
		if isHidden {
			EmptyView()
		} else {
			Toggle(isOn: isOn, label: {
				title
					.padding([.top, .bottom], requiredPadding())
			})
		}
	}
}

fileprivate struct SearchAdaptingSection<Content, Header, Footer> {
	let searchString: String
	let searchTerms: [String]
	let isPicker: Bool
	
	let content: Content
	let header: Header
	let footer: Footer
}

fileprivate protocol PickerProtocol {}
extension Picker : PickerProtocol {}

extension SearchAdaptingSection: View where Content: View, Header: View, Footer: View {
	init(_ searchString: String, includeHeaderAndFooter include: Bool = false, @ViewBuilder content: (String) -> Content, @ViewBuilder header: () -> Header, @ViewBuilder footer: () -> Footer) {
		self.searchString = searchString
		var searchTerms = [String]()
		
		self.header = LNTextCollector(&searchTerms) {
			header()
		}
		self.footer = LNTextCollector(&searchTerms) {
			footer()
		}
		
		let matchesHeaderOrFooter = include && !searchString.isEmpty && searchTerms.firstIndex(where: { $0.matches(searchString) }) != nil
		
		self.content = LNTextCollector(&searchTerms) {
			content(matchesHeaderOrFooter ? "" : searchString)
		}
		isPicker = self.content is PickerProtocol
		
		self.searchTerms = searchTerms
	}
	
	@ViewBuilder var body: some View {
		if searchString.isEmpty == false && (searchTerms.isEmpty || searchTerms.first(where: { $0.matches(searchString) }) == nil) {
			EmptyView()
		}
		else {
			if content is EmptyView == false && !isPicker && !searchString.isEmpty {
				content
			} else {
				Section {
					content
				} header: {
//					if searchString.isEmpty {
						header
//					}
				} footer: {
					if searchString.isEmpty || content is EmptyView {
						footer
					}
				}
			}
		}
	}
}

extension SearchAdaptingSection where Content: View, Header: View, Footer == EmptyView {
	init(_ searchString: String, includeHeaderAndFooter include: Bool = false, @ViewBuilder content: (String) -> Content, @ViewBuilder header: () -> Header) {
		self.searchString = searchString
		var searchTerms = [String]()
		
		self.header = LNTextCollector(&searchTerms) {
			header()
		}
		self.footer = EmptyView()
		
		let matchesHeaderOrFooter = include && !searchString.isEmpty && searchTerms.firstIndex(where: { $0.matches(searchString) }) != nil
		
		self.content = LNTextCollector(&searchTerms) {
			content(matchesHeaderOrFooter ? "" : searchString)
		}
		isPicker = self.content is PickerProtocol
		
		self.searchTerms = searchTerms
	}
}

extension SearchAdaptingSection where Content: View, Header == EmptyView, Footer: View {
	init(_ searchString: String, includeHeaderAndFooter include: Bool = false, @ViewBuilder content: (String) -> Content, @ViewBuilder footer: () -> Footer) {
		self.searchString = searchString
		var searchTerms = [String]()
		
		self.header = EmptyView()
		self.footer = LNTextCollector(&searchTerms) {
			footer()
		}
		
		let matchesHeaderOrFooter = include && !searchString.isEmpty && searchTerms.firstIndex(where: { $0.matches(searchString) }) != nil
		
		self.content = LNTextCollector(&searchTerms) {
			content(matchesHeaderOrFooter ? "" : searchString)
		}
		isPicker = self.content is PickerProtocol
		
		self.searchTerms = searchTerms
	}
}

fileprivate struct PickerGroupContent {
	@ViewBuilder let content: () -> any View
	@ViewBuilder let footer: () -> any View
}

fileprivate struct PickerGroupContentFulfilled {
	var content: any View
	var footer: any View
}

@resultBuilder
fileprivate struct PickerGroupContentBuilder {
	static func buildBlock(_ parts: PickerGroupContent...) -> [PickerGroupContent] {
		parts
	}
}

fileprivate struct SearchAdaptingPickerGroup<Header: View, SelectionValue: Hashable>: View {
	let searchString: String
	let searchTerms: [String]
	let selection: Binding<SelectionValue>
	
	let content: [PickerGroupContentFulfilled]
	let header: Header
	
	init(_ searchString: String, selection: Binding<SelectionValue>, @PickerGroupContentBuilder content: () -> [PickerGroupContent], @ViewBuilder header: () -> Header) {
		self.searchString = searchString
		self.selection = selection
		
		var searchTerms = [String]()
		
		self.content = LNTextCollector(&searchTerms) {
			content().map { PickerGroupContentFulfilled(content: $0.content(), footer: $0.footer()) }
		}
		
		self.header = LNTextCollector(&searchTerms) {
			header()
		}
		
		self.searchTerms = searchTerms
	}
	
	var body: some View {
		if !searchString.isEmpty && searchTerms.first(where: { $0.matches(searchString) }) == nil {
			EmptyView()
		} else {
			if !searchString.isEmpty {
				SearchAdaptingSection("") { _ in
					Picker(selection: selection) {
						ForEach(Array(content.enumerated()), id: \.offset) {
							AnyView(erasing: $1.content)
						}
					}
				} header: {
					header
				}
			}
			else {
				ForEach(content.indices, id: \.self) { idx in
					let current = content[idx]
					SearchAdaptingSection("") { _ in
						Picker(selection: selection) {
							AnyView(erasing: current.content)
						}
					} header: {
						if idx == 0 {
							header
						} else {
							EmptyView()
						}
					} footer: {
						AnyView(current.footer)
					}
				}
			}
		}
	}
}

struct SettingsForm : View {
	@AppStorage(.barStyle, store: .settings) var barStyle: LNPopupBar.Style = .default
	@AppStorage(.interactionStyle, store: .settings) var interactionStyle: UIViewController.__PopupInteractionStyle = .default
	@AppStorage(.closeButtonStyle, store: .settings) var closeButtonStyle: LNPopupCloseButton.Style = .default
	@AppStorage(.progressViewStyle, store: .settings) var progressViewStyle: LNPopupBar.ProgressViewStyle = .default
	@AppStorage(.marqueeEnabled, store: .settings) var marqueeEnabled: Bool = false
	@AppStorage(.marqueeCoordinationEnabled, store: .settings) var marqueeCoordinationEnabled: Bool = true
	@AppStorage(.hapticFeedbackEnabled, store: .settings) var hapticFeedback: Bool = true
	@AppStorage(.visualEffectViewBlurEffect, store: .settings) var blurEffectStyle: UIBlurEffect.Style = .default
	
	@AppStorage(.extendBar, store: .settings) var extendBar: Bool = true
	@AppStorage(.hidesBottomBarWhenPushed, store: .settings) var hideBottomBar: Bool = true
	@AppStorage(.disableScrollEdgeAppearance, store: .settings) var disableScrollEdgeAppearance: Bool = false
	@AppStorage(.customBarEverywhereEnabled, store: .settings) var customPopupBar: Bool = false
	@AppStorage(.enableCustomizations, store: .settings) var enableCustomizations: Bool = false
	@AppStorage(.contextMenuEnabled, store: .settings) var contextMenu: Bool = false
	@AppStorage(.touchVisualizerEnabled, store: .settings) var touchVisualizer: Bool = false
	
	@AppStorage(.barHideContentView, store: .settings) var hidePopupBarContentView: Bool = false
	@AppStorage(.barHideShadow, store: .settings) var hidePopupBarShadow: Bool = false
	@AppStorage(.barEnableLayoutDebug, store: .settings) var layoutDebug: Bool = false
	@AppStorage(.forceRTL) var forceRTL: Bool = false
	@AppStorage(.debugScaling, store: .settings) var debugScaling: Double = 0
	
	@AppStorage(.disableDemoSceneColors, store: .settings) var disableDemoSceneColors: Bool = false
	@AppStorage(.enableFunkyInheritedFont, store: .settings) var enableFunkyInheritedFont: Bool = false
	@AppStorage(.enableExternalScenes, store: .settings) var enableExternalScenes: Bool = false
	
	@Environment(\.isSearching) private var isSearching
	@Environment(\.dismissSearch) private var dismissSearch
	let searchText: String
	let isDefault: Bool
	
	init(isDefault: Bool, searchText: String) {
		self.isDefault = isDefault
		self.searchText = isDefault ? "" : searchText
	}
	
	@ViewBuilder var body: some View {
		if isDefault == false && (isSearching == false || searchText.isEmpty) {
			Color.black.opacity(isSearching ? 0.12 : 0.0).ignoresSafeArea()
				.transition(.opacity)
				.animation(.default, value: isSearching)
				.onTapGesture {
					dismissSearch()
				}
		}
		else {
			Form {
				SearchAdaptingSection(searchText) { _ in
					Picker(selection: $barStyle) {
						CellPaddedText("Default").tag(LNPopupBar.Style.default)
						CellPaddedText("Compact").tag(LNPopupBar.Style.compact)
						CellPaddedText("Prominent").tag(LNPopupBar.Style.prominent)
						CellPaddedText("Floating").tag(LNPopupBar.Style.floating)
					}
				} header: {
					LNHeaderFooterView("Bar Style")
				}
				
				SearchAdaptingSection(searchText) { _ in
					Picker(selection: $interactionStyle) {
						CellPaddedText("Default").tag(UIViewController.__PopupInteractionStyle.default)
						CellPaddedText("Drag").tag(UIViewController.__PopupInteractionStyle.drag)
						CellPaddedText("Snap").tag(UIViewController.__PopupInteractionStyle.snap)
						CellPaddedText("Scroll").tag(UIViewController.__PopupInteractionStyle.scroll)
						CellPaddedText("None").tag(UIViewController.__PopupInteractionStyle.none)
					}
				} header: {
					LNHeaderFooterView("Interaction Style")
				}
				
				SearchAdaptingSection(searchText) { _ in
					Picker(selection: $closeButtonStyle) {
						CellPaddedText("Default").tag(LNPopupCloseButton.Style.default)
						CellPaddedText("Round").tag(LNPopupCloseButton.Style.round)
						CellPaddedText("Chevron").tag(LNPopupCloseButton.Style.chevron)
						CellPaddedText("Grabber").tag(LNPopupCloseButton.Style.grabber)
						CellPaddedText("None").tag(LNPopupCloseButton.Style.none)
					}
				} header: {
					LNHeaderFooterView("Close Button Style")
				}
				
				SearchAdaptingSection(searchText) { _ in
					Picker(selection: $progressViewStyle) {
						CellPaddedText("Default").tag(LNPopupBar.ProgressViewStyle.default)
						CellPaddedText("Top").tag(LNPopupBar.ProgressViewStyle.top)
						CellPaddedText("Bottom").tag(LNPopupBar.ProgressViewStyle.bottom)
						CellPaddedText("None").tag(LNPopupBar.ProgressViewStyle.none)
					}
				} header: {
					LNHeaderFooterView("Progress View Style")
				}
				
				SearchAdaptingPickerGroup(searchText, selection: $blurEffectStyle) {
					PickerGroupContent {
						CellPaddedText("Default").tag(UIBlurEffect.Style.default)
					} footer: {
						LNHeaderFooterView("Uses the default material chosen by the system.")
					}
					PickerGroupContent {
						CellPaddedText("Ultra Thin Material").tag(UIBlurEffect.Style.systemUltraThinMaterial)
						CellPaddedText("Thin Material").tag(UIBlurEffect.Style.systemThinMaterial)
						CellPaddedText("Material").tag(UIBlurEffect.Style.systemMaterial)
						CellPaddedText("Thick Material").tag(UIBlurEffect.Style.systemThickMaterial)
						CellPaddedText("Chrome Material").tag(UIBlurEffect.Style.systemChromeMaterial)
					} footer: {
						LNHeaderFooterView("Material styles which automatically adapt to the user interface style. Available in iOS 13 and above.")
					}
					PickerGroupContent {
						CellPaddedText("Regular").tag(UIBlurEffect.Style.regular)
						CellPaddedText("Prominent").tag(UIBlurEffect.Style.prominent)
					} footer: {
						LNHeaderFooterView("Styles which automatically show one of the traditional blur styles, depending on the user interface style. Available in iOS 10 and above.")
					}
					PickerGroupContent {
						CellPaddedText("Extra Light").tag(UIBlurEffect.Style.extraLight)
						CellPaddedText("Light").tag(UIBlurEffect.Style.light)
						CellPaddedText("Dark").tag(UIBlurEffect.Style.dark)
					} footer: {
						LNHeaderFooterView("Traditional blur styles. Available in iOS 8 and above.")
					}
				} header: {
					LNHeaderFooterView("Background Blur Style")
				}
				
				SearchAdaptingSection(searchText) { searchText in
					CellPaddedToggle("Title & Subtitle Label Marquee", isOn: $marqueeEnabled, searchString: searchText)
					if marqueeEnabled {
						CellPaddedToggle("Coordinate Marquee Labels", isOn: $marqueeCoordinationEnabled, searchString: searchText)
					}
				} header: {
					LNHeaderFooterView("Marquee")
				}
				
				SearchAdaptingSection(searchText) { searchText in
					CellPaddedToggle("Popup Interaction Haptic Feedback", isOn: $hapticFeedback, searchString: searchText)
				} header: {
					LNHeaderFooterView("Haptic Feedback")
				} footer: {
					LNHeaderFooterView("Enables haptic feedback when the user interacts with the popup.")
				}
				
				SearchAdaptingSection(searchText) { searchText in
					CellPaddedToggle("Extend Bar Under Safe Area", isOn: $extendBar, searchString: searchText)
				} header: {
					LNHeaderFooterView("Settings")
				} footer: {
					if isLNPopupUIExample {
						LNHeaderFooterView("Calls the `popupBarShouldExtendPopupBarUnderSafeArea()` modifier with a value of `true` in standard demo scenes.")
					} else {
						LNHeaderFooterView("Sets the `shouldExtendPopupBarUnderSafeArea` property to `true` in standard demo scenes.")
					}
				}
				
				if isLNPopupUIExample == false {
					SearchAdaptingSection(searchText) { searchText in
						CellPaddedToggle("Hides Bottom Bar When Pushed", isOn: $hideBottomBar, searchString: searchText)
					} footer: {
						LNHeaderFooterView("Sets the `hidesBottomBarWhenPushed` property of pushed controllers in standard demo scenes.")
					}
					
					SearchAdaptingSection(searchText) { searchText in
						CellPaddedToggle("Disable Scroll Edge Appearance", isOn: $disableScrollEdgeAppearance, searchString: searchText)
					} footer: {
						LNHeaderFooterView("Disables the scroll edge appearance for system bars in standard demo scenes.")
					}
				}
				
				SearchAdaptingSection(searchText) { searchText in
					CellPaddedToggle("Context Menu Interactions", isOn: $contextMenu, searchString: searchText)
				} footer: {
					LNHeaderFooterView("Enables popup bar context menu interaction in standard demo scenes.")
				}
				
				SearchAdaptingSection(searchText) { searchText in
					CellPaddedToggle("Customizations", isOn: $enableCustomizations, searchString: searchText)
				} footer: {
					LNHeaderFooterView("Enables popup bar customizations in standard demo scenes.")
				}
				
				SearchAdaptingSection(searchText) { searchText in
					CellPaddedToggle("Custom Popup Bar", isOn: $customPopupBar, searchString: searchText)
				} footer: {
					LNHeaderFooterView("Enables a custom popup bar in standard demo scenes.")
				}
				
				SearchAdaptingSection(searchText) { searchText in
					CellPaddedToggle("Disable Demo Scene Colors", isOn: $disableDemoSceneColors, searchString: searchText)
				} footer: {
					LNHeaderFooterView("Disables random background colors in the demo scenes.")
				}
				
				if isLNPopupUIExample {
					SearchAdaptingSection(searchText) { searchText in
						CellPaddedToggle("Use Funky Inherited Font", isOn: $enableFunkyInheritedFont, searchString: searchText)
					} footer: {
						LNHeaderFooterView("Enables an environment font that is inherited by the popup bar.")
					}
				}
				
				SearchAdaptingSection(searchText) { searchText in
					CellPaddedToggle("Layout Debug", isOn: $layoutDebug, searchString: searchText)
					CellPaddedToggle("Hide Content View", isOn: $hidePopupBarContentView, searchString: searchText)
					CellPaddedToggle("Hide Floating Shadow", isOn: $hidePopupBarShadow, searchString: searchText)
					CellPaddedToggle("Use Right-to-Left Pseudolanguage With Right-to-Left Strings", isOn: $forceRTL, searchString: searchText).onTapGesture {
						SettingsViewController.toggleRTL { accepted in
							if accepted {
								return
							}
							
							forceRTL.toggle()
						}
					}
					
					if isDefault || "Scaling".matches(searchText) {
						NavigationLink {
							Form {
								Section {
									Picker(selection: $debugScaling) {
										CellPaddedText("Default").tag(0.0)
									}
								} footer: {
									LNHeaderFooterView("Uses the default scaling according to screen size and “Display Zoom” setting.")
								}
								
								Section {
									Picker(selection: $debugScaling) {
										CellPaddedText("320").tag(320.0)
									}
								} footer: {
									LNHeaderFooterView("Classic phones as well as “Larger Text” non-Max & non-Plus phones.")
								}
								
								Section {
									Picker(selection: $debugScaling) {
										CellPaddedText("375").tag(375.0)
										CellPaddedText("390").tag(390.0)
										CellPaddedText("393").tag(393.0)
									}
								} footer: {
									LNHeaderFooterView("Non-Max & non-Plus phones as well as “Larger Text” Max & Plus phones.")
								}
								
								Section {
									Picker(selection: $debugScaling) {
										CellPaddedText("414").tag(414.0)
										CellPaddedText("428").tag(428.0)
										CellPaddedText("430").tag(430.0)
									}
								} footer: {
									LNHeaderFooterView("Max & Plus phones.")
								}
							}.pickerStyle(.inline).navigationTitle("Scaling")
						} label: {
							HStack {
								CellPaddedText("Scaling")
								Spacer()
								CellPaddedText(debugScaling == 0 ? "Default" : "\(String(format: "%.0f", debugScaling))").foregroundColor(.secondary)
							}
						}
					}
				} header: {
					LNHeaderFooterView("Popup Bar Debug")
				}
				
				SearchAdaptingSection(searchText) { searchText in
					CellPaddedToggle("Touch Visualizer", isOn: $touchVisualizer, searchString: searchText)
				} header: {
					LNHeaderFooterView("Demonstration")
				} footer: {
					LNHeaderFooterView("Enables visualization of touches within the app, for demo purposes.")
				}
				
				if isLNPopupUIExample {
					SearchAdaptingSection(searchText, includeHeaderAndFooter: true) { searchText in
						CellPaddedToggle("CompactSlider", isOn: $enableExternalScenes, searchString: searchText)
					} header: {
						LNHeaderFooterView("External Libraries")
					} footer: {
						LNHeaderFooterView("Enables scenes for testing with external libraries.")
					}
				}
				
				SearchAdaptingSection(searchText) { _ in
					
				} footer: {
					LNHeaderFooterView("\(Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String) Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)")
				}
				
				//				SearchAdaptingSection(searchText) {
				//					HStack {
				//						CellPaddedText("Version")
				//						Spacer()
				//						CellPaddedText(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String).foregroundColor(.secondary)
				//					}
				//				} header: {
				//					LNHeaderFooterView(Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String)
				//				}
			}
			.background {
				if isDefault == false {
					Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
				}
			}
		}
	}
}

struct SettingsView : View {
	@State private var searchText = ""
	
	@AppStorage(.forceRTL) var forceRTL: Bool = false
	@AppStorage(.marqueeEnabled, store: .settings) var marqueeEnabled: Bool = false
	
	let onDismiss: (() -> ())?
	@Environment(\.presentationMode) var presentationMode
	
	init(onDismiss: (() -> ())? = nil) {
		self.onDismiss = onDismiss
	}
	
	@ViewBuilder var body: some View {
		ZStack {
			SettingsForm(isDefault: true, searchText: searchText)
			SettingsForm(isDefault: false, searchText: searchText)
		}
		.navigationTitle(NSLocalizedString("Settings", comment: ""))
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button(NSLocalizedString("Reset", comment: "")) {
					SettingsViewController.reset()
				}
			}
			ToolbarItem(placement: .confirmationAction) {
				Button(NSLocalizedString("Done", comment: "")) {
					if let onDismiss {
						onDismiss()
					} else {
						self.presentationMode.wrappedValue.dismiss()
					}
				}
			}
		}
		.pickerStyle(.inline)
		.animation(.default, value: marqueeEnabled)
		.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: NSLocalizedString("Search", comment: ""))
	}
}

class SettingsViewController: UIHostingController<SettingsView> {
	required init() {
		weak var weakSelf: SettingsViewController?
		
		super.init(rootView: SettingsView(onDismiss: {
			weakSelf?.presentingViewController?.dismiss(animated: true)
		}))
		
		weakSelf = self
		
		self.preferredContentSize = CGSize(width: 375, height: 600)
	}
	
	required init?(coder aDecoder: NSCoder) {
		weak var weakSelf: SettingsViewController?
		
		super.init(coder: aDecoder, rootView: SettingsView(onDismiss: {
			weakSelf?.presentingViewController?.dismiss(animated: true)
		}))
		
		weakSelf = self
		
		self.preferredContentSize = CGSize(width: 375, height: 600)
	}
	
	enum ResetAlertChoice {
		case cancelled
		case resetWithoutRestart
		case reset
	}
	
	class func alertRestartNeeded(allowSafeReset: Bool, completion: @escaping (ResetAlertChoice) -> ()) {
		let alertController = UIAlertController(title: NSLocalizedString("Restart Required", comment: ""), message: NSLocalizedString("Changing some settings requires exiting the app and restarting it.", comment: ""), preferredStyle: .alert)
		alertController.view.tintColor = .systemBlue
		if #available(iOS 16.0, *) {
			alertController.severity = .critical
		}
		alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
			completion(.cancelled)
		}))
		if allowSafeReset {
			alertController.addAction(UIAlertAction(title: NSLocalizedString("Reset Without Exiting", comment: ""), style: .default, handler: { _ in
				completion(.resetWithoutRestart)
			}))
		}
		alertController.addAction(UIAlertAction(title: NSLocalizedString("Exit", comment: ""), style: .destructive, handler: { _ in
			completion(.reset)
			UserDefaults.settings.synchronize()
			exit(0)
		}))
		
		let window = UIWindow.value(forKey: "keyWindow") as! UIWindow
		var controller = window.rootViewController!
		while controller.presentedViewController != nil {
			controller = controller.presentedViewController!
		}
		controller.present(alertController, animated: true)
	}
	
	class func setRTL() {
		UserDefaults.standard.set(true, forKey: "AppleTextDirection")
		UserDefaults.standard.set(true, forKey: "NSForceRightToLeftWritingDirection")
		UserDefaults.standard.set(true, forKey: "NSForceRightToLeftLocalizedStrings")
	}
	
	class func resetRTL() {
		UserDefaults.standard.removeObject(forKey: "AppleTextDirection")
		UserDefaults.standard.removeObject(forKey: "NSForceRightToLeftWritingDirection")
		UserDefaults.standard.removeObject(forKey: "NSForceRightToLeftLocalizedStrings")
	}
	
	class func toggleRTL(completion: @escaping (Bool) -> ()) {
		alertRestartNeeded(allowSafeReset: false) { response in
			guard response == .reset else {
				completion(false)
				return
			}
			
			completion(true)
			
			let wantsRTL = UserDefaults.standard.bool(forKey: .forceRTL)
			if wantsRTL {
				setRTL()
			} else {
				resetRTL()
			}
		}
	}
	
	class func reset() {
		let actualReset: (Bool) -> () = { includeRTL in
			UserDefaults.settings.set(true, forKey: .extendBar)
			UserDefaults.settings.set(true, forKey: .hidesBottomBarWhenPushed)
			UserDefaults.settings.set(true, forKey: .hapticFeedbackEnabled)
			UserDefaults.settings.set(true, forKey: .marqueeCoordinationEnabled)
			
			if includeRTL {
				UserDefaults.standard.removeObject(forKey:	.forceRTL)
				resetRTL()
			}
			
			UserDefaults.settings.removeObject(forKey: .debugScaling)
			
			let settingsToRemove: [PopupSetting] = [.barStyle, .interactionStyle, .closeButtonStyle, .progressViewStyle, .enableCustomizations, .disableScrollEdgeAppearance, .touchVisualizerEnabled, .customBarEverywhereEnabled, .contextMenuEnabled, .barHideContentView, .barHideShadow, .barEnableLayoutDebug, .disableDemoSceneColors, .enableFunkyInheritedFont, .enableExternalScenes, .marqueeEnabled]
			for key in settingsToRemove {
				UserDefaults.settings.removeObject(forKey: key)
			}
			
			UserDefaults.settings.set(0xffff, forKey: .visualEffectViewBlurEffect)
		}
		
		if UserDefaults.standard.bool(forKey: .forceRTL) {
			alertRestartNeeded(allowSafeReset: true) { response in
				guard response != .cancelled else {
					return
				}
				
				actualReset(response == .reset)
			}
		} else {
			actualReset(false)
		}
	}
	
	@IBAction func reset() {
		SettingsViewController.reset()
	}
}

@available(iOS 16.0, *)
struct SettingsNavView: View {
	var body: some View {
		NavigationStack {
			SettingsView()
		}
	}
}

#else

struct NoSettingsView : View {
	let onDismiss: (() -> ())?
	@Environment(\.presentationMode) var presentationMode
	
	init(onDismiss: (() -> ())? = nil) {
		self.onDismiss = onDismiss
	}
	
	var body: some View {
		Text("No Settings")
			.fontWeight(.semibold)
			.foregroundStyle(.secondary)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(Color(UIColor.systemGroupedBackground))
			.navigationTitle("Settings")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Done") {
						if let onDismiss {
							onDismiss()
						} else {
							self.presentationMode.wrappedValue.dismiss()
						}
					}
				}
			}
	}
}

class SettingsViewController: UIHostingController<NoSettingsView> {
	required init?(coder aDecoder: NSCoder) {
		weak var weakSelf: SettingsViewController?
		
		super.init(coder: aDecoder, rootView: NoSettingsView(onDismiss: {
			weakSelf?.presentingViewController?.dismiss(animated: true)
		}))
		
		weakSelf = self
	}
}

#endif
