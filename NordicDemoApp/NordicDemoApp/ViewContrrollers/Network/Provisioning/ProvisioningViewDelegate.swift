//
//  ProvisioningViewDelegate.swift
//  NordicDemoApp
//
//  Created by Eliseo on 7/27/22.
//

import Foundation
import nRFMeshProvision

protocol ProvisioningViewDelegate: AnyObject {
    
    /// Callback called when a new device has been provisioned.
    func provisionerDidProvisionNewDevice(_ node: Node)
    
}
