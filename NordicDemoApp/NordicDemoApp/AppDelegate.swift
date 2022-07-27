//
//  AppDelegate.swift
//  NordicDemoApp
//
//  Created by Eliseo on 7/26/22.
//

import UIKit
import nRFMeshProvision
import os.log

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var meshNetworkManager: MeshNetworkManager!
    var connection: NetworkConnection!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Create the main MeshNetworkManager instance and customize
        // configuration values.
        meshNetworkManager = MeshNetworkManager()
        meshNetworkManager.acknowledgmentTimerInterval = 0.150
        meshNetworkManager.transmissionTimerInterval = 0.600
        meshNetworkManager.incompleteMessageTimeout = 10.0
        meshNetworkManager.retransmissionLimit = 2
        meshNetworkManager.acknowledgmentMessageInterval = 4.2
        
        meshNetworkManager.acknowledgmentMessageTimeout = 40.0
        meshNetworkManager.logger = self
        
        var loaded = false
        do {
            loaded = try meshNetworkManager.load()
        } catch {
            print(error)
            // ignore
        }
        
        // If load failed, create a new MeshNetwork.
        if !loaded {
            createNewMeshNetwork()
        } else {
            meshNetworkDidChange()
        }
        
        return true
    }
    
    /// This method creates a new mesh network with a default name and a
    /// single Provisioner. When done, if calls `meshNetworkDidChange()`.
    func createNewMeshNetwork() {
        // TODO: Implement creator
        let provisioner = Provisioner(name: UIDevice.current.name,
                                      allocatedUnicastRange: [AddressRange(0x0001...0x199A)],
                                      allocatedGroupRange:   [AddressRange(0xC000...0xCC9A)],
                                      allocatedSceneRange:   [SceneRange(0x0001...0x3333)])
        _ = meshNetworkManager.createNewMeshNetwork(withName: "nRF Mesh Network", by: provisioner)
        _ = meshNetworkManager.save()
        
        meshNetworkDidChange()
    }
    
    /// Sets up the local Elements and reinitializes the `NetworkConnection`
    /// so that it starts scanning for devices advertising the new Network ID.
    func meshNetworkDidChange() {
        connection?.close()
        
        let meshNetwork = meshNetworkManager.meshNetwork!

        // Generic Default Transition Time Server model:
        let defaultTransitionTimeServerDelegate = GenericDefaultTransitionTimeServerDelegate(meshNetwork)
        // Scene Server and Scene Setup Server models:
        let sceneServer = SceneServerDelegate(meshNetwork,
                                              defaultTransitionTimeServer: defaultTransitionTimeServerDelegate)
        let sceneSetupServer = SceneSetupServerDelegate(server: sceneServer)
        
        // Set up local Elements on the phone.
        let element0 = Element(name: "Primary Element", location: .first, models: [
            // Scene Server and Scene Setup Server models (client is added automatically):
            Model(sigModelId: .sceneServerModelId, delegate: sceneServer),
            Model(sigModelId: .sceneSetupServerModelId, delegate: sceneSetupServer),
            // Sensor Client model:
            Model(sigModelId: .sensorClientModelId, delegate: SensorClientDelegate()),
            // Generic Power OnOff Client model:
            Model(sigModelId: .genericPowerOnOffClientModelId, delegate: GenericPowerOnOffClientDelegate()),
            // Generic Default Transition Time Server model:
            Model(sigModelId: .genericDefaultTransitionTimeServerModelId,
                  delegate: defaultTransitionTimeServerDelegate),
            Model(sigModelId: .genericDefaultTransitionTimeClientModelId,
                  delegate: GenericDefaultTransitionTimeClientDelegate()),
            // 4 generic models defined by Bluetooth SIG:
            Model(sigModelId: .genericOnOffServerModelId,
                  delegate: GenericOnOffServerDelegate(meshNetwork,
                                                       defaultTransitionTimeServer: defaultTransitionTimeServerDelegate,
                                                       elementIndex: 0)),
            Model(sigModelId: .genericLevelServerModelId,
                  delegate: GenericLevelServerDelegate(meshNetwork,
                                                       defaultTransitionTimeServer: defaultTransitionTimeServerDelegate,
                                                       elementIndex: 0)),
            Model(sigModelId: .genericOnOffClientModelId, delegate: GenericOnOffClientDelegate()),
            Model(sigModelId: .genericLevelClientModelId, delegate: GenericLevelClientDelegate()),
            // A simple vendor model:
//            Model(vendorModelId: .simpleOnOffModelId,
//                  companyId: .nordicSemiconductorCompanyId,
//                  delegate: SimpleOnOffClientDelegate())
        ])
        let element1 = Element(name: "Secondary Element", location: .second, models: [
            Model(sigModelId: .genericOnOffServerModelId,
                  delegate: GenericOnOffServerDelegate(meshNetwork,
                                                       defaultTransitionTimeServer: defaultTransitionTimeServerDelegate,
                                                       elementIndex: 1)),
            Model(sigModelId: .genericLevelServerModelId,
                  delegate: GenericLevelServerDelegate(meshNetwork,
                                                       defaultTransitionTimeServer: defaultTransitionTimeServerDelegate,
                                                       elementIndex: 1)),
            Model(sigModelId: .genericOnOffClientModelId, delegate: GenericOnOffClientDelegate()),
            Model(sigModelId: .genericLevelClientModelId, delegate: GenericLevelClientDelegate())
        ])
        meshNetworkManager.localElements = [element0, element1]
        
        connection = NetworkConnection(to: meshNetwork)
        connection!.dataDelegate = meshNetworkManager
        connection!.logger = self
        meshNetworkManager.transmitter = connection
        connection!.open()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension MeshNetworkManager {
    
    static var instance: MeshNetworkManager {
        if Thread.isMainThread {
            return (UIApplication.shared.delegate as! AppDelegate).meshNetworkManager
        } else {
            return DispatchQueue.main.sync {
                return (UIApplication.shared.delegate as! AppDelegate).meshNetworkManager
            }
        }
    }
    
    static var bearer: NetworkConnection! {
        if Thread.isMainThread {
            return (UIApplication.shared.delegate as! AppDelegate).connection
        } else {
            return DispatchQueue.main.sync {
                return (UIApplication.shared.delegate as! AppDelegate).connection
            }
        }
    }
    
}

// MARK: - Logger

extension AppDelegate: LoggerDelegate {
    
    func log(message: String, ofCategory category: LogCategory, withLevel level: LogLevel) {
        if #available(iOS 10.0, *) {
            os_log("%{public}@", log: category.log, type: level.type, message)
        } else {
            NSLog("%@", message)
        }
    }
    
}

extension LogLevel {
    
    /// Mapping from mesh log levels to system log types.
    var type: OSLogType {
        switch self {
        case .debug:       return .debug
        case .verbose:     return .debug
        case .info:        return .info
        case .application: return .default
        case .warning:     return .error
        case .error:       return .fault
        }
    }
    
}

extension LogCategory {
    
    var log: OSLog {
        return OSLog(subsystem: Bundle.main.bundleIdentifier!, category: rawValue)
    }
    
}

