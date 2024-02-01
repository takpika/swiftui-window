
import Foundation
import SwiftUI

struct TitleSetKey: EnvironmentKey {
    static var defaultValue: ((String) -> Void)? = nil
}

struct TitleGetKey: EnvironmentKey {
    static var defaultValue: (() -> String)? = nil
}

struct IDKey: EnvironmentKey {
    static var defaultValue: (() -> Int)? = nil
}

struct CloseKey: EnvironmentKey {
    static var defaultValue: (() -> Void)? = nil
}

struct AddWindowAllKey: EnvironmentKey {
    static var defaultValue: ((AnyView, WindowConfig) -> Int)? = nil
}

struct AddWindowSimpleKey: EnvironmentKey {
    static var defaultValue: ((AnyView, String) -> Int)? = nil
}

struct SizeSetKey: EnvironmentKey {
    static var defaultValue: ((CGFloat,CGFloat) -> Void)? = nil
}

struct SizeGetKey: EnvironmentKey {
    static var defaultValue: CGSize = CGSize()
}

struct PositionSetKey: EnvironmentKey {
    static var defaultValue: ((CGFloat,CGFloat) -> Void)? = nil
}

struct PositionGetKey: EnvironmentKey {
    static var defaultValue: CGPoint = CGPoint()
}

struct PermissionSetKey: EnvironmentKey {
    static var defaultValue: ((String, Bool) -> Void)? = nil
}

struct PermissionGetKey: EnvironmentKey {
    static var defaultValue: ((String) -> Bool)? = nil
}

struct WindowPosModeGetKey: EnvironmentKey {
    static var defaultValue: WindowPosMode = WindowPosMode.normal
}

struct WindowPosModeSetKey: EnvironmentKey {
    static var defaultValue: ((WindowPosMode) -> Void)? = nil
}

struct ActionBarClearKey: EnvironmentKey {
    static var defaultValue: (() -> Void)? = nil
}

struct ActionBarAddKey: EnvironmentKey {
    static var defaultValue: ((AnyView) -> String)? = nil
}

struct WindowBarHeightGetKey: EnvironmentKey {
    static var defaultValue: CGFloat = 40
}

struct WindowBarHeightSetKey: EnvironmentKey {
    static var defaultValue: ((CGFloat) -> Void)? = nil
}

extension EnvironmentValues {
    var titleSetKey: ((String) -> Void)? {
        get { self[TitleSetKey.self] }
        set { self[TitleSetKey.self] = newValue }
    }
    
    var titleGetKey: (() -> String)? {
        get { self[TitleGetKey.self] }
        set { self[TitleGetKey.self] = newValue }
    }
    
    var windowIDGetKey: (() -> Int)? {
        get { self[IDKey.self] }
        set { self[IDKey.self] = newValue }
    }
    
    var closeKey: (() -> Void)? {
        get { self[CloseKey.self] }
        set { self[CloseKey.self] = newValue }
    }
    
    var window_AllAddKey: ((AnyView, WindowConfig) -> Int)? {
        get { self[AddWindowAllKey.self] }
        set { self[AddWindowAllKey.self] = newValue }
    }
    
    var window_SimpleAddKey: ((AnyView, String) -> Int)? {
        get { self[AddWindowSimpleKey.self] }
        set { self[AddWindowSimpleKey.self] = newValue }
    }
    
    var sizeSetKey: ((CGFloat,CGFloat) -> Void)? {
        get { self[SizeSetKey.self] }
        set { self[SizeSetKey.self] = newValue }
    }
    
    var sizeGetKey: CGSize {
        get { self[SizeGetKey.self] }
        set { self[SizeGetKey.self] = newValue }
    }
    
    var positionSetKey: ((CGFloat,CGFloat) -> Void)? {
        get { self[PositionSetKey.self] }
        set { self[PositionSetKey.self] = newValue }
    }
    
    var positionGetKey: CGPoint {
        get { self[PositionGetKey.self] }
        set { self[PositionGetKey.self] = newValue }
    }
    
    var permission_SetKey: ((String,Bool) -> Void)? {
        get { self[PermissionSetKey.self] }
        set { self[PermissionSetKey.self] = newValue }
    }
    
    var permission_GetKey: ((String) -> Bool)? {
        get { self[PermissionGetKey.self] }
        set { self[PermissionGetKey.self] = newValue }
    }
    
    var windowPosMode_GetKey: WindowPosMode {
        get { self[WindowPosModeGetKey.self] }
        set { self[WindowPosModeGetKey.self] = newValue }
    }
    
    var windowPosMode_SetKey: ((WindowPosMode) -> Void)? {
        get { self[WindowPosModeSetKey.self] }
        set { self[WindowPosModeSetKey.self] = newValue }
    }
    
    var actionBarClearKey: (() -> Void)? {
        get { self[ActionBarClearKey.self] }
        set { self[ActionBarClearKey.self] = newValue }
    }
    
    var actionBarAddKey: ((AnyView) -> String)? {
        get { self[ActionBarAddKey.self] }
        set { self[ActionBarAddKey.self] = newValue }
    }
    
    var windowBarHeightGetKey: CGFloat {
        get {self[WindowBarHeightGetKey.self]}
        set {self[WindowBarHeightGetKey.self] = newValue}
    }
    
    var windowBarHeightSetKey: ((CGFloat) -> Void)? {
        get {self[WindowBarHeightSetKey.self]}
        set {self[WindowBarHeightSetKey.self] = newValue}
    }
}
