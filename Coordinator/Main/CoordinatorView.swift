//
//  CoordinatorView.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 09/02/2023.
//

import SwiftUI

struct CoordinatorView<T: CoordinatorObjectProtocol>: View {
    
    @StateObject var coordinatorObject: T
    
    var converterVM = ConverterViewModel()
    var selectorVM = CurrencySelectorViewModel()
    
    var body: some View {
        switch coordinatorObject.currentFlow {
        case .converter:
            converter
        case .selector:
            selector
        }
    }
}

extension CoordinatorView {
    var converter: some View {
        ConverterView(viewModel: converterVM)
    }
    
    var selector: some View {
        CurrencySelectorView(viewModel: selectorVM)
    }
}

struct CoordinatorView_Previews: PreviewProvider {
    static var previews: some View {
        CoordinatorView(coordinatorObject: MockCoordinatorObject())
    }
}


