//
//  SettingsViewController.swift
//  LNPopupSettings
//
//  Created by Léo Natan on 2023-12-15.
//  Copyright © 2023-2024 Léo Natan. All rights reserved.
//

import SwiftUI

#if LNPOPUP

import LNPopupController

extension Notification.Name {
	static let textVisited = Notification.Name("textVisited")
}

extension UserDefaults {
	func object(forKey setting: PopupSetting) -> Any? {
		object(forKey: setting.rawValue)
	}
	
	func integer(forKey setting: PopupSetting) -> Int {
		integer(forKey: setting.rawValue)
	}
	
	func bool(forKey setting: PopupSetting) -> Bool {
		bool(forKey: setting.rawValue)
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
	static let `glass` = UIBlurEffect.Style(rawValue: -1)!
	static let `clearGlass` = UIBlurEffect.Style(rawValue: -2)!
	static let `default` = UIBlurEffect.Style(rawValue: 0xffff)!
}

fileprivate extension Picker where Label == EmptyView {
	init(selection: Binding<SelectionValue>, @ViewBuilder content: () -> Content) {
		self.init(selection: selection, content: content) {
			EmptyView()
		}
	}
}

@MainActor fileprivate var isLNPopupUIExample: Bool = {
	return ProcessInfo.processInfo.processName == "LNPopupUIExample"
}()

fileprivate extension String {
	func matches(_ another: String) -> Bool {
		return range(of: another, options: [.caseInsensitive]) != nil
	}
}

@MainActor
fileprivate struct LNText: View {
	let text: Text
	public init(_ content: String) {
		NotificationCenter.default.post(name: .textVisited, object: content)
		
		@AppStorage(PopupSetting.forceRTL) var forceRTL: Bool = false
		
		if forceRTL == false {
			text = Text(LocalizedStringKey(content))
		} else {
			text = Text(Bundle.main.localizedString(forKey: content, value: nil, table: nil))
		}
	}
	
	var body: some View {
		text
	}
}

@MainActor
fileprivate func LNTextCollector<Content>(_ container: inout [String], content: () -> Content) -> Content {
	var results = [String]()
	
	let observer = NotificationCenter.default.addMainQueueObserver(forName: .textVisited, object: nil) { note in
		results.append(note.object as! String)
	}
	
	let rv = content()
	
	NotificationCenter.default.removeObserver(observer)
	container.append(contentsOf: results)
	
	return rv
}

@MainActor
fileprivate struct LNHeaderFooterView: View {
	let content: LNText
	public init(_ content: String) {
		self.content = LNText(content)
	}
	
	var body: some View {
		content.font(.footnote)
	}
}

@MainActor
fileprivate struct LNToggle: View {
	let isHidden: Bool
	let title: LNText
	let isOn: Binding<Bool>
	let onTapGesture: (() -> Void)?
	
	init(_ title: String, isOn: Binding<Bool>, searchString: String, onTapGesture: (() -> Void)? = nil) {
		isHidden = searchString.isEmpty == false && title.matches(searchString) == false
		self.title = LNText(title)
		self.isOn = isOn
		self.onTapGesture = onTapGesture
	}
	
	var body: some View {
		if isHidden {
			EmptyView()
		} else {
			ZStack {
				Toggle(isOn: isOn, label: {
					title
				}).allowsHitTesting(onTapGesture == nil)
				if let onTapGesture {
					Color.red.opacity(0.001).onTapGesture(perform: onTapGesture)
				}
			}
		}
	}
}

@MainActor
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
fileprivate struct ArrayBuilder<T> {
	public static func build<U>(@ArrayBuilder<U> children: () -> [U]) -> [U] {
		children()
	}
	
	public static func buildPartialBlock(first: T) -> [T] { [first] }
	public static func buildPartialBlock(first: T?) -> [T] { if let first { [first] } else { [] } }
	public static func buildPartialBlock(first: [T]) -> [T] { first }
	public static func buildPartialBlock(accumulated: [T], next: T) -> [T] { accumulated + [next] }
	public static func buildPartialBlock(accumulated: [T], next: T?) -> [T] { accumulated + (next != nil ? [next!] : []) }
	public static func buildPartialBlock(accumulated: [T], next: [T]) -> [T] { accumulated + next }
	
	// Empty block
	public static func buildBlock() -> [T] { [] }
	
	// Empty partial block. Useful for switch cases to represent no elements.
	public static func buildPartialBlock(first: Void) -> [T] { [] }
	
	// Impossible partial block. Useful for fatalError().
	public static func buildPartialBlock(first: Never) -> [T] {}
	
	// Block for an 'if' condition.
	public static func buildIf(_ element: [T]?) -> [T] { element ?? [] }
	
	// Block for an 'if' condition which also have an 'else' branch.
	public static func buildEither(first: [T]) -> [T] { first }
	
	// Block for the 'else' branch of an 'if' condition.
	public static func buildEither(second: [T]) -> [T] { second }
	
	// Block for an array of elements. Useful for 'for' loops.
	public static func buildArray(_ components: [[T]]) -> [T] { components.flatMap { $0 } }
}

fileprivate typealias PickerGroupContentBuilder = ArrayBuilder<PickerGroupContent>

@MainActor
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
	
	@AppStorage(.transitionType, store: .settings) var transitionType: Int = 0
	@AppStorage(.extendBar, store: .settings) var extendBar: Bool = true
	@AppStorage(.limitFloatingWidth, store: .settings) var limitFloatingWidth: Bool = true
	@AppStorage(.hidesBottomBarWhenPushed, store: .settings) var hideBottomBar: Bool = true
	@AppStorage(.disableScrollEdgeAppearance, store: .settings) var disableScrollEdgeAppearance: Bool = false
	@AppStorage(.customBarEverywhereEnabled, store: .settings) var customPopupBar: Bool = false
	@AppStorage(.enableCustomizations, store: .settings) var enableCustomizations: Bool = false
	@AppStorage(.contextMenuEnabled, store: .settings) var contextMenu: Bool = false
	@AppStorage(.touchVisualizerEnabled, store: .settings) var touchVisualizer: Bool = false
	
	@AppStorage(.barHideContentView, store: .settings) var hidePopupBarContentView: Bool = false
	@AppStorage(.barHideShadow, store: .settings) var hidePopupBarShadow: Bool = false
	@AppStorage(.barEnableLayoutDebug, store: .settings) var layoutDebug: Bool = false
	@AppStorage(.enableSlowTransitionsDebug, store: .settings) var enableSlowTransitionsDebug: Bool = false
	@AppStorage(.forceRTL) var forceRTL: Bool = false
	@AppStorage(.debugScaling, store: .settings) var debugScaling: Double = 0
	
	@AppStorage(.tabBarHasSidebar, store: .settings) var tabBarHasSidebar: Bool = true
	@AppStorage(.invertDemoSceneColors, store: .settings) var invertDemoSceneColors: Bool = true
	@AppStorage(.disableDemoSceneColors, store: .settings) var disableDemoSceneColors: Bool = false
	@AppStorage(.enableFunkyInheritedFont, store: .settings) var enableFunkyInheritedFont: Bool = false
	@AppStorage(.enableExternalScenes, store: .settings) var enableExternalScenes: Bool = false
	
	@AppStorage(.enableCustomLabels, store: .settings) var enableCustomLabels: Bool = false
	@AppStorage(.useScrollingPopupContent, store: .settings) var useScrollingPopupContent: Int = 0
	
	@Environment(\.isSearching) private var isSearching
	@Environment(\.dismissSearch) private var dismissSearch
	let searchText: String
	let isDefault: Bool
	
	init(isDefault: Bool, searchText: String) {
		self.isDefault = isDefault
		self.searchText = isDefault ? "" : searchText
	}
	
	struct TransitionType: Identifiable {
		let id: Int
		let title: String
		let description: String
		let popupUISupport: Bool
		
		var footerDescription: String {
			"**\(title)** \(description)."
		}
	}
	
	let transitionTypes: [TransitionType] = [
		TransitionType(id: 0, title: "Preferred", description: "uses \(isLNPopupUIExample ? "the `popupTransitionTarget()` modifier" : "`LNPopupImageView` as the image view")", popupUISupport: true),
		TransitionType(id: 2, title: "Full Content View", description: "uses a view that spans the entirety of the popup content view", popupUISupport: true),
		TransitionType(id: 1, title: "Generic", description: "uses a custom `UIView` for transition", popupUISupport: false),
	].filter { isLNPopupUIExample == false || $0.popupUISupport == true }
	
	func transitionTypeFooterDescription() -> String {
		transitionTypes.map { $0.footerDescription }.joined(separator: "\n")
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
						LNText("Default").tag(LNPopupBar.Style.default)
						if !LNPopupSettingsHasOS26Glass() {
							LNText("Compact").tag(LNPopupBar.Style.compact)
							LNText("Prominent").tag(LNPopupBar.Style.prominent)
						}
						LNText("Floating").tag(LNPopupBar.Style.floating)
						LNText("Floating Compact").tag(LNPopupBar.Style.floatingCompact)
					}
				} header: {
					LNHeaderFooterView("Bar Style")
				}
				
				SearchAdaptingSection(searchText) { _ in
					Picker(selection: $interactionStyle) {
						LNText("Default").tag(UIViewController.__PopupInteractionStyle.default)
						LNText("Drag").tag(UIViewController.__PopupInteractionStyle.drag)
						LNText("Snap").tag(UIViewController.__PopupInteractionStyle.snap)
						LNText("Scroll").tag(UIViewController.__PopupInteractionStyle.scroll)
						LNText("None").tag(UIViewController.__PopupInteractionStyle.none)
					}
				} header: {
					LNHeaderFooterView("Interaction Style")
				}
				
				SearchAdaptingSection(searchText) { _ in
					Picker(selection: $closeButtonStyle) {
						LNText("Default").tag(LNPopupCloseButton.Style.default)
						LNText("Round").tag(LNPopupCloseButton.Style.round)
						LNText("Chevron").tag(LNPopupCloseButton.Style.chevron)
						LNText("Grabber").tag(LNPopupCloseButton.Style.grabber)
						LNText("None").tag(LNPopupCloseButton.Style.none)
					}
				} header: {
					LNHeaderFooterView("Close Button Style")
				}
				
				SearchAdaptingSection(searchText) { _ in
					Picker(selection: $progressViewStyle) {
						LNText("Default").tag(LNPopupBar.ProgressViewStyle.default)
						LNText("Top").tag(LNPopupBar.ProgressViewStyle.top)
						LNText("Bottom").tag(LNPopupBar.ProgressViewStyle.bottom)
						LNText("None").tag(LNPopupBar.ProgressViewStyle.none)
					}
				} header: {
					LNHeaderFooterView("Progress View Style")
				}
				
				SearchAdaptingPickerGroup(searchText, selection: $blurEffectStyle) {
					PickerGroupContent {
						LNText("Default").tag(UIBlurEffect.Style.default)
					} footer: {
						LNHeaderFooterView("Uses the default visual effect chosen by the system.")
					}
					if LNPopupSettingsHasOS26Glass() {
						PickerGroupContent {
							LNText("Glass").tag(UIBlurEffect.Style.glass)
							LNText("Clear Glass").tag(UIBlurEffect.Style.clearGlass)
						} footer: {
							LNHeaderFooterView("Glass styles. Available in iOS 26 and above.")
						}
					}
					PickerGroupContent {
						LNText("Ultra Thin Material").tag(UIBlurEffect.Style.systemUltraThinMaterial)
						LNText("Thin Material").tag(UIBlurEffect.Style.systemThinMaterial)
						LNText("Material").tag(UIBlurEffect.Style.systemMaterial)
						LNText("Thick Material").tag(UIBlurEffect.Style.systemThickMaterial)
						LNText("Chrome Material").tag(UIBlurEffect.Style.systemChromeMaterial)
					} footer: {
						LNHeaderFooterView("Blur material styles which automatically adapt to the user interface style. Available in iOS 13 and above.")
					}
					PickerGroupContent {
						LNText("Regular").tag(UIBlurEffect.Style.regular)
						LNText("Prominent").tag(UIBlurEffect.Style.prominent)
					} footer: {
						LNHeaderFooterView("Blur styles which automatically show one of the traditional blur styles, depending on the user interface style. Available in iOS 10 and above.")
					}
					PickerGroupContent {
						LNText("Extra Light").tag(UIBlurEffect.Style.extraLight)
						LNText("Light").tag(UIBlurEffect.Style.light)
						LNText("Dark").tag(UIBlurEffect.Style.dark)
					} footer: {
						LNHeaderFooterView("Traditional blur styles. Available in iOS 8 and above.")
					}
				} header: {
					LNHeaderFooterView("Background Visual Effect")
				}
				
				SearchAdaptingSection(searchText) { searchText in
					LNToggle("Title & Subtitle Label Marquee", isOn: $marqueeEnabled, searchString: searchText)
					if marqueeEnabled {
						LNToggle("Coordinate Marquee Labels", isOn: $marqueeCoordinationEnabled, searchString: searchText)
					}
				} header: {
					LNHeaderFooterView("Marquee")
				}
				
				SearchAdaptingSection(searchText) { searchText in
					LNToggle("Popup Interaction Haptic Feedback", isOn: $hapticFeedback, searchString: searchText)
				} header: {
					LNHeaderFooterView("Haptic Feedback")
				} footer: {
					LNHeaderFooterView("Enables haptic feedback when the user interacts with the popup.")
				}
				
				SearchAdaptingSection(searchText) { searchText in
					Picker(selection: $transitionType) {
						ForEach(transitionTypes) { type in
							LNText(type.title).tag(type.id)
						}
						Divider()
						LNText("None").tag(999)
					} label: {
						LNText("Image Transition")
					}
					.pickerStyle(.menu)
					.tint(.secondary)
				} header: {
					LNHeaderFooterView("Settings")
				} footer: {
					LNHeaderFooterView("Enables or disables popup image open and close transitions in standard demo scenes.\n\(transitionTypeFooterDescription())")
				}
				
				if !LNPopupSettingsHasOS26Glass() {
					SearchAdaptingSection(searchText) { searchText in
						LNToggle("Extend Bar Under Safe Area", isOn: $extendBar, searchString: searchText)
					} footer: {
						if isLNPopupUIExample {
							LNHeaderFooterView("Calls the `popupBarShouldExtendPopupBarUnderSafeArea()` modifier with a value of `true` in standard demo scenes.")
						} else {
							LNHeaderFooterView("Sets the `shouldExtendPopupBarUnderSafeArea` property to `true` in standard demo scenes.")
						}
					}
				}
				
				if UIDevice.current.userInterfaceIdiom == .pad {
					SearchAdaptingSection(searchText) { searchText in
						LNToggle("Limit Width of Floating Bar", isOn: $limitFloatingWidth, searchString: searchText)
					} footer: {
						LNHeaderFooterView("Limits the width of a floating popup bar to a system-determined value in standard demo scenes.")
					}
				}
				
				if #available(iOS 18.0, *), UIDevice.current.userInterfaceIdiom == .pad {
					SearchAdaptingSection(searchText) { searchText in
						LNToggle("Tab \(isLNPopupUIExample ? "Views" : "Bar Controllers") Have Sidebars", isOn: $tabBarHasSidebar, searchString: searchText)
					} footer: {
						LNHeaderFooterView("Add support for sidebar to standard tab \(isLNPopupUIExample ? "view" : "bar controller") scenes.")
					}
				}
				
				if isLNPopupUIExample == false {
					SearchAdaptingSection(searchText) { searchText in
						LNToggle("Hides Bottom Bar When Pushed", isOn: $hideBottomBar, searchString: searchText)
					} footer: {
						LNHeaderFooterView("Sets the `hidesBottomBarWhenPushed` property of pushed controllers in standard demo scenes.")
					}
					
					if !LNPopupSettingsHasOS26Glass() {
						SearchAdaptingSection(searchText) { searchText in
							LNToggle("Disable Scroll Edge Appearance", isOn: $disableScrollEdgeAppearance, searchString: searchText)
						} footer: {
							LNHeaderFooterView("Disables the scroll edge appearance for system bars in standard demo scenes.")
						}
					}
				}
				
				SearchAdaptingSection(searchText) { searchText in
					LNToggle("Context Menu Interactions", isOn: $contextMenu, searchString: searchText)
				} footer: {
					LNHeaderFooterView("Enables popup bar context menu interaction in standard demo scenes.")
				}
				
				SearchAdaptingSection(searchText) { searchText in
					LNToggle("Customizations", isOn: $enableCustomizations, searchString: searchText)
				} footer: {
					LNHeaderFooterView("Enables popup bar customizations in standard demo scenes.")
				}
				
				if isLNPopupUIExample {
					SearchAdaptingSection(searchText) { searchText in
						LNToggle("Custom Labels", isOn: $enableCustomLabels, searchString: searchText)
					} footer: {
						LNHeaderFooterView("Enables the use of custom labels in standard demo scenes.")
					}
				}
				
				SearchAdaptingSection(searchText) { searchText in
					LNToggle("Custom Popup Bar", isOn: $customPopupBar, searchString: searchText)
				} footer: {
					LNHeaderFooterView("Enables a custom popup bar in standard demo scenes.")
				}
				
				if !isLNPopupUIExample {
					SearchAdaptingSection(searchText) { searchText in
						Picker(selection: $useScrollingPopupContent) {
							LNText("None").tag(0)
							
							LNText("Vertical").tag(10)
							LNText("Horizontal").tag(11)
							
							LNText("Paged Vertical").tag(20)
							LNText("Paged Horizontal").tag(21)
							LNText("Paged Vertical & Paged Horizontal").tag(22)
							LNText("Paged Horizontal & Paged Vertical").tag(23)
							
							LNText("Map View").tag(100)
						} label: {
							LNText("Scrolling Popup Content")
						}
						.pickerStyle(.menu)
						.tint(.secondary)
					} footer: {
						switch useScrollingPopupContent {
						case 1:
							LNHeaderFooterView("Uses vertical scrolling popup content in standard demo scenes.")
						case 2:
							LNHeaderFooterView("Uses horizontal scrolling popup content in standard demo scenes.")
						default:
							LNHeaderFooterView("Uses standard popup content in standard demo scenes.")
						}
					}
				}
				
				if !isLNPopupUIExample {
					SearchAdaptingSection(searchText) { searchText in
						LNToggle("Invert Demo Scene Colors", isOn: $invertDemoSceneColors, searchString: searchText)
					} footer: {
						LNHeaderFooterView("Inverts random background colors in standard demo scenes.")
					}
				}
				
				SearchAdaptingSection(searchText) { searchText in
					LNToggle("Disable Demo Scene Colors", isOn: $disableDemoSceneColors, searchString: searchText)
				} footer: {
					LNHeaderFooterView("Disables random background colors in standard demo scenes.")
				}
				
				if isLNPopupUIExample {
					SearchAdaptingSection(searchText) { searchText in
						LNToggle("Use Funky Inherited Font", isOn: $enableFunkyInheritedFont, searchString: searchText)
					} footer: {
						LNHeaderFooterView("Enables an environment font that is inherited by the popup bar.")
					}
				}
				
				SearchAdaptingSection(searchText) { searchText in
					LNToggle("Layout Debug", isOn: $layoutDebug, searchString: searchText)
					LNToggle("Hide Content View", isOn: $hidePopupBarContentView, searchString: searchText)
					LNToggle("Hide Floating Shadow", isOn: $hidePopupBarShadow, searchString: searchText)
					LNToggle("Slow Popup Transitions", isOn: $enableSlowTransitionsDebug, searchString: searchText)
					LNToggle("Use Right-to-Left Pseudolanguage With Right-to-Left Strings", isOn: $forceRTL, searchString: searchText) {
						SettingsViewController.toggleRTL { accepted in
							guard accepted else {
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
										LNText("Default").tag(0.0)
									}
								} footer: {
									LNHeaderFooterView("Uses the default scaling according to screen size and “Display Zoom” setting.")
								}
								
								Section {
									Picker(selection: $debugScaling) {
										LNText("320").tag(320.0)
									}
								} footer: {
									LNHeaderFooterView("Classic phones as well as “Larger Text” non-Max & non-Plus phones.")
								}
								
								Section {
									Picker(selection: $debugScaling) {
										LNText("375").tag(375.0)
										LNText("390").tag(390.0)
										LNText("393").tag(393.0)
									}
								} footer: {
									LNHeaderFooterView("Non-Max & non-Plus phones as well as “Larger Text” Max & Plus phones.")
								}
								
								Section {
									Picker(selection: $debugScaling) {
										LNText("414").tag(414.0)
										LNText("428").tag(428.0)
										LNText("430").tag(430.0)
									}
								} footer: {
									LNHeaderFooterView("Max & Plus phones.")
								}
							}.pickerStyle(.inline).navigationTitle(NSLocalizedString("Scaling", comment: ""))
						} label: {
							HStack {
								LNText("Scaling")
								Spacer()
								LNText(debugScaling == 0 ? "Default" : "\(String(format: "%.0f", debugScaling))").foregroundColor(.secondary)
							}
						}
					}
				} header: {
					LNHeaderFooterView("Popup Bar Debug")
				}
				
				SearchAdaptingSection(searchText) { searchText in
					LNToggle("Touch Visualizer", isOn: $touchVisualizer, searchString: searchText)
				} header: {
					LNHeaderFooterView("Demonstration")
				} footer: {
					LNHeaderFooterView("Enables visualization of touches within the app, for demo purposes.")
				}
				
				if isLNPopupUIExample {
					SearchAdaptingSection(searchText, includeHeaderAndFooter: true) { searchText in
						LNToggle("CompactSlider", isOn: $enableExternalScenes, searchString: searchText)
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
			}
			.background {
				if isDefault == false {
					Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
				}
			}
		}
	}
}

extension View {
	@ViewBuilder
	func appropriateButtonStyle() -> some View {
#if compiler(>=6.2)
		if #available(iOS 26, *), LNPopupSettingsHasOS26Glass() {
			self.buttonStyle(.glassProminent)
		} else {
			self.buttonStyle(.plain)
		}
#else
		buttonStyle(.plain)
#endif
	}
}

extension View {
	@ViewBuilder
	func searchable<S: StringProtocol>(text: Binding<String>, prompt: S) -> some View {
		if #available(iOS 26, *), LNPopupSettingsHasOS26Glass(), UIDevice.current.userInterfaceIdiom != .pad {
			self.searchable(text: text, placement: .toolbar, prompt: prompt)
		} else {
			self.searchable(text: text, placement: .navigationBarDrawer(displayMode: .always), prompt: prompt)
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
				Button {
					SettingsViewController.reset()
				} label: {
					if #available(iOS 26, *), LNPopupSettingsHasOS26Glass() {
						Image(systemName: "arrow.counterclockwise")
					} else {
						Text(String(localized: "Reset"))
					}
				}
			}
			ToolbarItem(placement: .confirmationAction) {
				Button {
					if let onDismiss {
						onDismiss()
					} else {
						self.presentationMode.wrappedValue.dismiss()
					}
				} label: {
					if #available(iOS 26, *), LNPopupSettingsHasOS26Glass() {
						Image(systemName: "checkmark")
							.fontWeight(.semibold)
					} else {
						Text(String(localized: "Done"))
							.bold()
							.foregroundStyle(.tint)
					}
				}
				.appropriateButtonStyle()
			}
		}
		.pickerStyle(.inline)
		.animation(.default, value: marqueeEnabled)
		.searchable(text: $searchText, prompt: NSLocalizedString("Search", comment: ""))
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
		UserDefaults.standard.synchronize()
	}
	
	class func resetRTL() {
		UserDefaults.standard.removeObject(forKey: "AppleTextDirection")
		UserDefaults.standard.removeObject(forKey: "NSForceRightToLeftWritingDirection")
		UserDefaults.standard.removeObject(forKey: "NSForceRightToLeftLocalizedStrings")
		UserDefaults.standard.synchronize()
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
			if includeRTL {
				UserDefaults.standard.removeObject(forKey:	.forceRTL)
				resetRTL()
			}
			
			UserDefaults.settings.removeObject(forKey: .debugScaling)
			
			let settingsToRemove: [PopupSetting] = [.barStyle, .interactionStyle, .closeButtonStyle, .progressViewStyle, .enableCustomizations, .disableScrollEdgeAppearance, .touchVisualizerEnabled, .customBarEverywhereEnabled, .contextMenuEnabled, .barHideContentView, .barHideShadow, .barEnableLayoutDebug, .enableSlowTransitionsDebug, .invertDemoSceneColors, .disableDemoSceneColors, .enableFunkyInheritedFont, .enableExternalScenes, .marqueeEnabled, .enableCustomLabels, .useScrollingPopupContent, .limitFloatingWidth, .tabBarHasSidebar, .transitionType, .extendBar, .hidesBottomBarWhenPushed, .hapticFeedbackEnabled, .marqueeCoordinationEnabled]
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
