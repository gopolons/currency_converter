//
//  ConverterView.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 09/02/2023.
//

import SwiftUI

struct ConverterView<T: ConverterViewModelProtocol>: View {
    
    @StateObject var viewModel: T
    
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 25) {
                    myBalancesSection
                    
                    exchangeSection
                    
                    ctaButton
                    
                    commissionDisplay
                }
                
            }
            .padding(.top, 75)
            
            navBar
        }
        
        .alert(isPresented: $viewModel.showAlert) {
            conversionAlert
        }
    }
}

extension ConverterView {
    var walletScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if let wallet = viewModel.wallet {
                    ForEach(wallet, id: \.self) { currency in
                        HStack {
                            Text("\(currency.availableAmount.truncate(places: 2))")
                            
                            Text(currency.currency)
                        }
                    }
                }
            }
            .padding(.horizontal, 25)
        }
    }
    
    var navBar: some View {
        VStack {
            RoundedRectangle(cornerRadius: 0)
                .frame(height: safeAreaInsets.top + 50)
                .foregroundColor(.blue)
                .overlay(
                    VStack {
                        Spacer()
                        
                        Text("converter.navbar.title".localized())
                            .foregroundColor(.white)
                            .font(.body.bold())
                    }
                    .padding()
                )
                .ignoresSafeArea(.all)
            
            Spacer()
        }
    }
    
    var tradedCurrencyCell: some View {
        HStack {
            Image(systemName: "arrow.up.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.red)
            
            Text("converter.currency.sell".localized())
            
            Spacer()
           
            TextField("", text: $viewModel.sellAmount)
                .keyboardType(.decimalPad)
                .font(.body.bold())
                .multilineTextAlignment(.trailing)
            
            Text(viewModel.sellCurrency)
                .font(.body.bold())
            
            Button {
                viewModel.selectCurrency(.selectSell)
            } label: {
                Image(systemName: "chevron.down")
                    .font(.body.bold())
            }
        }
    }
    
    var purchasedCurrencyCell: some View {
        HStack {
            Image(systemName: "arrow.down.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.green)
            
            Text("converter.currency.buy".localized())
            
            Spacer()
            
            Text("+ \(viewModel.buyAmount)")
                .font(.body.bold())
                .foregroundColor(.green)
            
            Text(viewModel.buyCurrency)
                .font(.body.bold())
           
            Button {
                viewModel.selectCurrency(.selectBuy)
            } label: {
                Image(systemName: "chevron.down")
                    .font(.body.bold())
            }
        }
    }
    
    var exchangeSection: some View {
        VStack(spacing: 25) {
            HStack {
                Text("converter.section.exchange.header".localized())
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.gray)
                
                Spacer()
            }
            
            tradedCurrencyCell
            
            purchasedCurrencyCell
        }
        .padding(.horizontal, 25)
    }
    
    var myBalancesSection: some View {
        VStack(spacing: 25) {
            HStack {
                Text("converter.section.balances.header".localized())
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding(.horizontal, 25)
            
            walletScrollView
        }
    }
    
    var ctaButton: some View {
        Button {
            viewModel.executeConversion()
        } label: {
            RoundedRectangle(cornerRadius: 25)
                .frame(height: 50)
                .padding(.horizontal, 25)
                .overlay(
                    Text("ui.button.submit".localized())
                        .foregroundColor(.white)
                )
        }
        .disabled(!viewModel.isConversionAvailable)
    }
    
    var conversionAlert: Alert {
        Alert(
            title: Text("ui.alert.title".localized()),
            message: Text("ui.alert.body1".localized()) + Text("\(viewModel.performedConversion!.sellAmount.truncate(places: 2)) \(viewModel.performedConversion!.sellCurrency)") + Text("ui.alert.body2".localized()) + Text("\(viewModel.performedConversion!.buyAmount!.truncate(places: 2)) \(viewModel.performedConversion!.buyCurrency).") + Text("ui.alert.body3".localized()) +  Text("\(viewModel.performedConversion!.commission!.truncate(places: 2)) \(viewModel.performedConversion!.sellCurrency)."),
            dismissButton: .default(Text("ui.button.ok".localized()), action: {
                viewModel.dismissAlert()
            })
        )
    }
    
    var commissionDisplay: some View {
        Text("converter.footer.commission".localized()) + Text("\(viewModel.commissionAmount) \(viewModel.sellCurrency)")
    }
}

struct ConverterView_Previews: PreviewProvider {
    static var previews: some View {
        ConverterView(viewModel: MockConverterViewModel())
    }
}
