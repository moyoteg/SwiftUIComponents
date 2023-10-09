//
//  Permissions.swift
//  SwiftUtilities
//
//  Created by Moi Gutierrez on 8/22/22.
//

import Foundation

import CloudyLogs
import PermissionsKit

import BluetoothPermission
import NotificationPermission
import FaceIDPermission
import CameraPermission
import PhotoLibraryPermission
import MicrophonePermission
import CalendarPermission
import ContactsPermission
import RemindersPermission
import SpeechRecognizerPermission
import LocationWhenInUsePermission
import LocationAlwaysPermission
import MotionPermission
import MediaLibraryPermission
import TrackingPermission
import SiriPermission
import HealthPermission

/*
 
 ****** INFO.plist keys ****************************************
 
 Calendar :
 Key      :  Privacy - Calendars Usage Description
 Value  :  $(PRODUCT_NAME) calendar events

 Reminder :
 Key      :   Privacy - Reminders Usage Description
 Value  :   $(PRODUCT_NAME) reminder use

 Contact :
 Key       :   Privacy - Contacts Usage Description
 Value    :  $(PRODUCT_NAME) contact use

 Photo :
 Key       :  Privacy - Photo Library Usage Description
 Value   :  $(PRODUCT_NAME) photo use

 Bluetooth Sharing :
 Key       :  Privacy - Bluetooth Peripheral Usage Description
 Value   :  $(PRODUCT_NAME) Bluetooth Peripheral use

 Microphone :
 Key        :  Privacy - Microphone Usage Description
 Value    :  $(PRODUCT_NAME) microphone use

 Camera :
 Key       :  Privacy - Camera Usage Description
 Value   :  $(PRODUCT_NAME) camera use

 Location :
 Key      :  Privacy - Location Always Usage Description
 Value  :  $(PRODUCT_NAME) location use

 Key       :  Privacy - Location When In Use Usage Description
 Value   :  $(PRODUCT_NAME) location use

 Heath :
 Key      :  Privacy - Health Share Usage Description
 Value  :  $(PRODUCT_NAME) heath share use

 Key      :  Privacy - Health Update Usage Description
 Value  :  $(PRODUCT_NAME) heath update use

 HomeKit :
 Key      :  Privacy - HomeKit Usage Description
 Value  :  $(PRODUCT_NAME) home kit use

 Media Library :
 Key      :  Privacy - Media Library Usage Description
 Value  :  $(PRODUCT_NAME) media library use

 Motion :
 Key      :  Privacy - Motion Usage Description
 Value  :  $(PRODUCT_NAME) motion use

 Speech Recognition :
 Key      :  Privacy - Speech Recognition Usage Description
 Value  :  $(PRODUCT_NAME) speech use

 SiriKit  :
 Key      :  Privacy - Siri Usage Description
 Value  :  $(PRODUCT_NAME) siri use

 TV Provider :
 Key      :  Privacy - TV Provider Usage Description
 Value  :  $(PRODUCT_NAME) tvProvider use

 */

/*
 
 ****** INFO.plist keys RAW ****************************************

 <key>NSVideoSubscriberAccountUsageDescription</key>
 <string>to learn</string>
 <key>NSMotionUsageDescription</key>
 <string>to learn</string>
 <key>NSHomeKitUsageDescription</key>
 <string>to learn</string>
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>to learn</string>
 <key>NSHealthShareUsageDescription</key>
 <string>to learn</string>
 <key>NSMicrophoneUsageDescription</key>
 <string>to learn</string>
 <key>NSPhotoLibraryUsageDescription</key>
 <string>to learn</string>
 <key>NSRemindersUsageDescription</key>
 <string>to learn</string>
 <key>NSAppleMusicUsageDescription</key>
 <string>to learn</string>
 <key>NSSpeechRecognitionUsageDescription</key>
 <string>to learn</string>
 <key>NSSiriUsageDescription</key>
 <string>to learn</string>
 <key>NSUserTrackingUsageDescription</key>
 <string>to learn</string>
 <key>NSLocationAlwaysUsageDescription</key>
 <string>to learn</string>
 <key>NSFallDetectionUsageDescription</key>
 <string>to learn</string>
 <key>NSFaceIDUsageDescription</key>
 <string>to learn</string>
 <key>NSDocumentsFolderUsageDescription</key>
 <string>to learn</string>
 <key>NSContactsUsageDescription</key>
 <string>to learn</string>
 <key>NSBluetoothPeripheralUsageDescription</key>
 <string>to learn</string>
 <key>NSBluetoothAlwaysUsageDescription</key>
 <string>to learn</string>
 <key>NSAppleEventsUsageDescription</key>
 <string>to learn</string>
 <key>NSFileProviderDomainUsageDescription</key>
 <string>to learn</string>
 <key>NSCalendarsUsageDescription</key>
 <string>to learn</string>
 <key>NSCameraUsageDescription</key>
 <string>to learn</string>
 <key>NSHealthUpdateUsageDescription</key>
 <string>placeholder text</string>
 */

public enum Permission: CaseIterable, Hashable {
        
    case bluetooth
    case notification
#if !os(watchOS)
    case faceId
    case camera
    case photoLibrary
    case microphone
    case calendar
    case contacts
    case reminders
    case speechRecognizer
#endif
    case locationWhenInUse
#if !os(watchOS)
    case locationAlways
    case motion
    case mediaLibrary
    case tracking
    case siri
#endif
#if os(iOS) && PERMISSIONSKIT_HEALTH
    case health
#endif

    internal var permission: PermissionsKit.Permission {
        switch self {
        case .bluetooth: return PermissionsKit.Permission.bluetooth
        case .notification: return PermissionsKit.Permission.notification
#if !os(watchOS)
        case .faceId: return PermissionsKit.Permission.faceID
        case .camera: return PermissionsKit.Permission.camera
        case .photoLibrary: return PermissionsKit.Permission.photoLibrary
        case .microphone: return PermissionsKit.Permission.microphone
        case .calendar: return PermissionsKit.Permission.calendar
        case .contacts: return PermissionsKit.Permission.contacts
        case .reminders: return PermissionsKit.Permission.reminders
        case .speechRecognizer: return PermissionsKit.Permission.speech
#endif
        case .locationWhenInUse: return PermissionsKit.Permission.locationWhenInUse
#if !os(watchOS)
        case .locationAlways: return PermissionsKit.Permission.locationAlways
        case .motion: return PermissionsKit.Permission.motion
        case .mediaLibrary: return PermissionsKit.Permission.mediaLibrary
        case .tracking: return PermissionsKit.Permission.tracking
        case .siri: return PermissionsKit.Permission.siri
#endif
#if os(iOS) && PERMISSIONSKIT_HEALTH
        case .health: return PermissionsKit.Permission.health
#endif
        }
    }
    
    public var name: String {
        switch self {
        case .bluetooth: return "bluetooth"
        case .notification: return "notification"
#if !os(watchOS)
        case .faceId: return "faceId"
        case .camera: return "camera"
        case .photoLibrary: return "photoLibrary"
        case .microphone: return "microphone"
        case .calendar: return "calendar"
        case .contacts: return "contacts"
        case .reminders: return "reminders"
        case .speechRecognizer: return "speechRecognizer"
#endif
        case .locationWhenInUse: return "locationWhenInUse"
#if !os(watchOS)
        case .locationAlways: return "locationAlways"
        case .motion: return "motion"
        case .mediaLibrary: return "mediaLibrary"
        case .tracking: return "tracking"
        case .siri: return "siri"
#endif
#if os(iOS) && PERMISSIONSKIT_HEALTH
        case .health: return "health"
#endif
        }
    }
    
    public enum Status: Int, CustomStringConvertible {
        
        case authorized
        case denied
        case notDetermined
        case notSupported
        
        public var description: String {
            switch self {
            case .authorized: return "authorized"
            case .denied: return "denied"
            case .notDetermined: return "not determined"
            case .notSupported: return "not supported"
            }
        }
    }
    
    public var status: Permission.Status {
        
        switch permission.status {
        case .authorized: return .authorized
        case .denied: return .denied
        case .notDetermined: return .notSupported
        case .notSupported: return .notSupported
        }
    }
    
    public var isAuthorized: Bool {
        
        let isAuthorized = self.permission.status == .authorized
        
        Logger.log("Permission: \(permission) isAuthorized: \(isAuthorized), status: \(permission.status)")
        
        return isAuthorized
    }
    
    public static func checkAllPermissionsAuthorizationStatus() {
        
        for permission in Permission.allCases {
            Logger.log("Permission: \(permission.permission.kind.name): authorized: \(permission.permission.status)")
        }
    }
    
    public static func logAllPermissions() {

        for permission in Permission.allCases {
            
            switch permission {
               
            case .bluetooth: let key = PermissionsKit.Permission.bluetooth.usageDescriptionKey; let status = PermissionsKit.Permission.bluetooth.status; Logger.log("Permission: \(permission.permission.kind.name): key: \(String(describing: key)), status: \(status)")
            case .notification: let authorized = PermissionsKit.Permission.notification.authorized; Logger.log("Permission: \(permission.permission.kind.name): authorized: \(authorized)")
#if !os(watchOS)
            case .faceId: let authorized = PermissionsKit.Permission.faceID.authorized; Logger.log("Permission: \(permission.permission.kind.name): authorized: \(authorized)")
            case .camera: Logger.log("Permission: \(permission.permission.kind.name): authorized: \(PermissionsKit.Permission.camera.authorized)")
            case .photoLibrary: Logger.log("Permission: \(permission.permission.kind.name): authorized: \(PermissionsKit.Permission.photoLibrary.authorized)")
            case .microphone: Logger.log("Permission: \(permission.permission.kind.name): authorized: \(PermissionsKit.Permission.microphone.authorized)")
            case .calendar: Logger.log("Permission: \(permission.permission.kind.name): authorized: \(PermissionsKit.Permission.calendar.authorized)")
            case .contacts: Logger.log("Permission: \(permission.permission.kind.name): authorized: \(PermissionsKit.Permission.contacts.authorized)")
            case .reminders: Logger.log("Permission: \(permission.permission.kind.name): authorized: \(PermissionsKit.Permission.reminders.authorized)")
            case .speechRecognizer: Logger.log("Permission: \(permission.permission.kind.name): authorized: \(PermissionsKit.Permission.speech.authorized)")
#endif
            case .locationWhenInUse: Logger.log("Permission: \(permission.permission.kind.name): authorized: \(PermissionsKit.Permission.locationWhenInUse.authorized)")
#if !os(watchOS)
            case .locationAlways: Logger.log("Permission: \(permission.permission.kind.name): authorized: \(PermissionsKit.Permission.locationAlways.authorized)")
            case .motion: Logger.log("Permission: \(permission.permission.kind.name): authorized: \(PermissionsKit.Permission.motion.authorized)")
            case .mediaLibrary: Logger.log("Permission: \(permission.permission.kind.name): authorized: \(PermissionsKit.Permission.mediaLibrary.authorized)")
            case .tracking: Logger.log("Permission: \(permission.permission.kind.name): authorized: \(PermissionsKit.Permission.tracking.authorized)")
            case .siri: Logger.log("Permission: \(permission.permission.kind.name): authorized: \(PermissionsKit.Permission.siri.authorized)")
#endif
#if os(iOS) && PERMISSIONSKIT_HEALTH
            case .health: Logger.log("Permission: \(permission.permission.kind.name): authorized: \(PermissionsKit.Permission.health.authorized)")
#endif
            }
        }
    }
    
    public func request(completion: @escaping ()->Void) {
        
        switch self {
        case .bluetooth: return PermissionsKit.Permission.bluetooth.request(completion: completion)
        case .notification: return PermissionsKit.Permission.notification.request(completion: completion)
#if !os(watchOS)
        case .faceId: return PermissionsKit.Permission.faceID.request(completion: completion)
        case .camera: return PermissionsKit.Permission.camera.request(completion: completion)
        case .photoLibrary: return PermissionsKit.Permission.photoLibrary.request(completion: completion)
        case .microphone: return PermissionsKit.Permission.microphone.request(completion: completion)
        case .calendar: return PermissionsKit.Permission.calendar.request(completion: completion)
        case .contacts: return PermissionsKit.Permission.contacts.request(completion: completion)
        case .reminders: return PermissionsKit.Permission.reminders.request(completion: completion)
        case .speechRecognizer: return PermissionsKit.Permission.speech.request(completion: completion)
#endif
        case .locationWhenInUse: return PermissionsKit.Permission.locationWhenInUse.request(completion: completion)
#if !os(watchOS)
        case .locationAlways: return PermissionsKit.Permission.locationAlways.request(completion: completion)
        case .motion: return PermissionsKit.Permission.motion.request(completion: completion)
        case .mediaLibrary: return PermissionsKit.Permission.mediaLibrary.request(completion: completion)
        case .tracking: return PermissionsKit.Permission.tracking.request(completion: completion)
        case .siri: return PermissionsKit.Permission.siri.request(completion: completion)
#endif
#if os(iOS) && PERMISSIONSKIT_HEALTH
        case .health: return PermissionsKit.Permission.health.request(completion: completion)
#endif
        }
    }
}
