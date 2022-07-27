//
//  NodeViewCell.swift
//  NordicDemoApp
//
//  Created by Eliseo on 7/26/22.
//

import UIKit
import nRFMeshProvision
import Foundation

class NodeViewCell: UITableViewCell {
    @IBOutlet weak var nodeName: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var elements: UILabel!
    @IBOutlet weak var models: UILabel!
    
    var node: Node! {
        didSet {
            nodeName.text = node.name ?? "Unknown Device"
            address.text = node.unicastAddress.asString()
            elements.text = "\(node.elements.count)"
            
            if let companyIdentifier = node.companyIdentifier {
                company.text = CompanyIdentifier.name(for: companyIdentifier) ?? "Unknown"
                let modelCount = node.elements.reduce(0, { (result, element) -> Int in
                    result + element.models.count
                })
                models.text = "\(modelCount)"
            } else {
                company.text = "Unknown"
                models.text = "Configuration not complete"
            }
        }
    }
}
