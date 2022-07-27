//
//  EditProvisionerViewController.swift
//  NordicDemoApp
//
//  Created by Eliseo on 7/27/22.
//

import UIKit
import nRFMeshProvision

protocol EditProvisionerDelegate {
    /// Notifies the delegate that the Provisioner was added to the mesh network.
    ///
    /// - parameter provisioner: The new Provisioner.
    func provisionerWasAdded(_ provisioner: Provisioner)
    /// Notifies the delegate that the given Provisioner was modified.
    ///
    /// - parameter provisioner: The Provisioner that has been modified.
    func provisionerWasModified(_ provisioner: Provisioner)
}
