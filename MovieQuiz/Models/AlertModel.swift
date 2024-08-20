//  Created by Vitaly Wexler on 20.08.2024.


import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: (() -> Void)?
}
