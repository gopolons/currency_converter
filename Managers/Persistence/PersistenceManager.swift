//
//  PersistenceManager.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 09/02/2023.
//

import Foundation
import Combine
import CoreData

protocol PersistenceManagerProtocol {
    func saveData(_ data: AccountData)
    func fetchData() -> AccountData
}

final class PersistenceManager: PersistenceManagerProtocol {
    private var accountData = AccountData()
    private let container = NSPersistentContainer(name: "PersistentAccountData")
    
    func saveData(_ data: AccountData) {
        // removing existing values in wallet DB
        let currencyWalletFetchRequest: NSFetchRequest<CoreCurrencyWallet> = CoreCurrencyWallet.fetchRequest()
        let currencyWalletResults = try? container.viewContext.fetch(currencyWalletFetchRequest)
        if let cwr = currencyWalletResults {
            for x in cwr {
                container.viewContext.delete(x)
            }
        }
        
        // removing existing values in operation DB
        let operationHistoryFetchRequest: NSFetchRequest<CoreOperationHistory> = CoreOperationHistory.fetchRequest()
        let operationHistoryResults = try? container.viewContext.fetch(operationHistoryFetchRequest)
        if let ohr = operationHistoryResults {
            for x in ohr {
                container.viewContext.delete(x)
            }
        }
        
        // creating objects for all user wallets
        for x in data.wallet {
            let ccw = CoreCurrencyWallet(context: container.viewContext)
            ccw.currency = x.currency
            ccw.availableAmount = x.availableAmount
        }
        
        // creating objects for all user operations
        for x in data.history {
            let coh = CoreOperationHistory(context: container.viewContext)
            let op = x.operation
            coh.buyAmount = op.buyAmount!
            coh.sellAmount = op.sellAmount
            coh.buyCurrency = op.buyCurrency
            coh.sellCurrency = op.sellCurrency
            coh.commission = op.commission!
            coh.date = x.date
        }
        
        try? container.viewContext.save()
        
        self.accountData = data
    }
    
    func fetchData() -> AccountData {
        let currencyWalletFetchRequest: NSFetchRequest<CoreCurrencyWallet> = CoreCurrencyWallet.fetchRequest()
        let currencyWalletResults = try? container.viewContext.fetch(currencyWalletFetchRequest)
        
        let operationHistoryFetchRequest: NSFetchRequest<CoreOperationHistory> = CoreOperationHistory.fetchRequest()
        let operationHistoryResults = try? container.viewContext.fetch(operationHistoryFetchRequest)
        
        var wallets = [CurrencyWallet]()
        var history = [OperationHistory]()
        
        if let currencyWalletResults = currencyWalletResults {
//            print("fetched currency wallets from coredata: \(currencyWalletResults)")
            for x in currencyWalletResults {
                guard let cur = x.currency else {
                    fatalError("Error when building a wallet from a coredata fetch information")
                }
                let am = x.availableAmount
                let wallet = CurrencyWallet(currency: cur, availableAmount: am)
                wallets.append(wallet)
            }
        }
        
        if let operationHistoryResults = operationHistoryResults {
//            print("fetched operations from coredata: \(operationHistoryResults)")
            for x in operationHistoryResults {
                guard let sellC = x.sellCurrency, let buyC = x.buyCurrency, let opD = x.date else {
                    fatalError("Error when building a history struct from a coredata fetch information")
                }
                
                let conv = Conversion(sellCurrency: sellC, buyCurrency: buyC, sellAmount: x.sellAmount, buyAmount: x.buyAmount, commission: x.commission)
                let opHis = OperationHistory(date: opD, operation: conv)
                history.append(opHis)
            }
        }
        
        let newacc = AccountData(wallets: wallets, history: history)
        
        if !wallets.isEmpty || !history.isEmpty {
            self.accountData = newacc
        } else {
            self.accountData = AccountData()
        }
        
        return self.accountData
    }
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
