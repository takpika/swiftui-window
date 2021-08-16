
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
    static var defaultValue: ((AnyView, String, CGSize, CGPoint, Bool, Bool, Bool) -> Int)? = nil
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

struct FullScreenGetKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

struct FullScreenSetKey: EnvironmentKey {
    static var defaultValue: (() -> Void)? = nil
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
    
    var window_AllAddKey: ((AnyView, String, CGSize, CGPoint, Bool, Bool, Bool) -> Int)? {
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
    
    var fullScreen_GetKey: Bool {
        get { self[FullScreenGetKey.self] }
        set { self[FullScreenGetKey.self] = newValue }
    }
    
    var fullScreen_SetKey: (() -> Void)? {
        get { self[FullScreenSetKey.self] }
        set { self[FullScreenSetKey.self] = newValue }
    }
}
