//
//  CurrencySelectorView.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 14/02/2023.
//

import SwiftUI

struct CurrencySelectorView<T: CurrencySelectorViewModelProtocol>: View {
    
    @StateObject var viewModel: T
    
    var body: some View {
        ScrollView {
            ForEach(viewModel.availableCurrencies, id: \.self) { currency in
                Button {
                    viewModel.selectCurrency(currency)
                } label: {
                    VStack {
                        Text(currency)
                        
                        Divider()
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct CurrencySelectorView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencySelectorView(viewModel: MockCurrencySelectorViewModel())
    }
}
