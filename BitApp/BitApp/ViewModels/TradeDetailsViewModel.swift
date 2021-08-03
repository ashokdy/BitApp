//
//  TradeDetailsViewModel.swift
//  BitApp
//
//  Created by ashokdy on 01/08/2021.
//

import UIKit

enum Reload {
    case ticker
    case trade
}

typealias DataFetched = ((Reload) -> Void)

class TradeDetailsViewModel {
    
    var dataSourceArray = SocketResponse()
    var dataSource: UITableViewDiffableDataSource<String, SocketResponse>?
    var webSocketConnection: WebSocketConnection?
    var dataFetched: DataFetched?
    var symbol: String?
    init() { }
    
    func configureWebSocket(symbol: String?) {
        self.symbol = symbol
        guard let url = URL(string: webSocketURL) else { return }
        webSocketConnection?.disconnect()
        dataSourceArray = SocketResponse()
        webSocketConnection = WebSocketTaskConnection(url: url)
        webSocketConnection?.delegate = self
        webSocketConnection?.connect()
    }
    
    private func subscribeToStocks() {
        let dict: [String: String] = [
            "event": "subscribe",
            "channel": "ticker",
            "symbol": symbol ?? ""
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed) {
            webSocketConnection?.send(data: data)
        }
    }
    
    func assignChannelID(_ channelId: Double) {
        if dataSourceArray.tickerChannelID == nil {
            dataSourceArray.tickerChannelID = channelId
            let dict2: [String: String] = [
                "event": "subscribe",
                "channel": "trades",
                "symbol": "tBTCUSD"
            ]
            
            if let data = try? JSONSerialization.data(withJSONObject: dict2, options: .fragmentsAllowed) {
                webSocketConnection?.send(data: data)
            }
        } else {
            dataSourceArray.tradeChannelID = channelId
        }
    }
    
    func parseAndUpdate(data: Data) {
        do {
            let jsonDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            if let channelId = jsonDict?["chanId"] as? Double {
                assignChannelID(channelId)
            }
            // It should be the socket response of updates for trades and tickers
            if jsonDict == nil {
                let responseDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Any]
                if responseDict?.first as? Double == dataSourceArray.tickerChannelID {
                    if let ticker = responseDict?.last as? [Double] {
                        parseTickerData(ticker: ticker)
                    }
                } else if responseDict?.first as? Double == dataSourceArray.tradeChannelID {
                    if let ticker = responseDict?.last as? [[Double]] {
                        parseTradeData(ticker: ticker)
                    } else if let ticker = responseDict?.last as? [Double] {
                        parseSingleArrayTrade(ticker: ticker)
                    }
                }
            }
        }
        catch {
            print(error)
        }
    }
    
    func parseTickerData(ticker: [Double]) {
        do {
            var tickerDict = [String: Double]()
            let keys = ["bid", "bidSize", "ask", "askSize", "dailyChange", "dailyChangeRelative", "lastPrice", "volume", "high", "low"]
            for (index, tickerValue) in ticker.enumerated() {
                tickerDict[keys[index]] = tickerValue
            }
            let tickerData = try JSONSerialization.data(withJSONObject: tickerDict, options: .fragmentsAllowed)
            let tickerObject = try JSONDecoder().decode(Ticker.self, from: tickerData)
            dataSourceArray.ticker = tickerObject
            dataFetched?(.ticker)
        } catch {
            print(error)
        }
    }
    
    func parseTradeData(ticker: [[Double]]) {
        do {
            var tickerArrayDict = [[String: Double]]()
            let keys = ["id", "mts", "amount", "price"]
            for tickerValue in ticker {
                var tickerDict = [String: Double]()
                for (index, tickerActualValue) in tickerValue.enumerated() {
                    tickerDict[keys[index]] = tickerActualValue
                }
                tickerArrayDict.append(tickerDict)
            }
            let tickerData = try JSONSerialization.data(withJSONObject: tickerArrayDict, options: .fragmentsAllowed)
            let tickerObject = try JSONDecoder().decode([Trade].self, from: tickerData)
            dataSourceArray.trade = tickerObject
            dataFetched?(.trade)
        } catch {
            print(error)
        }
    }
    
    func parseSingleArrayTrade(ticker: [Double]) {
        do {
            var tickerDict = [String: Double]()
            let keys = ["id", "mts", "amount", "price"]
            for (index, tickerActualValue) in ticker.enumerated() {
                tickerDict[keys[index]] = tickerActualValue
            }
            let tickerData = try JSONSerialization.data(withJSONObject: tickerDict, options: .fragmentsAllowed)
            let tickerObject = try JSONDecoder().decode(Trade.self, from: tickerData)
            dataSourceArray.trade?.append(tickerObject)
            dataFetched?(.trade)
        } catch {
            print(error)
        }
    }
    
    func getTickerDataSource() -> [NameValue] {
        guard let ticker = dataSourceArray.ticker else { return [] }
        var tickerDataSourceArray = [NameValue]()
        tickerDataSourceArray.append(NameValue(name: "Open Price(UTC)", value: "\(ticker.bid.convertDoubleToCurrency())"))
        tickerDataSourceArray.append(NameValue(name: "Daily Change(UTC)", value: "\(ticker.bid.convertDoubleToCurrency()) (\(ticker.dailyChangeString))"))
        tickerDataSourceArray.append(NameValue(name: "Top Bid", value: "\(ticker.bid.with2Fractions())"))
        tickerDataSourceArray.append(NameValue(name: "Top Ask", value: "\(ticker.ask.with2Fractions())"))
        tickerDataSourceArray.append(NameValue(name: "Last Price", value: "\(ticker.lastPrice.convertDoubleToCurrency())"))
        tickerDataSourceArray.append(NameValue(name: "24hr range", value: "\(ticker.low.with2Fractions()) - \(ticker.high.with2Fractions())"))
        return tickerDataSourceArray
    }
    
    func getTradeDataSource() -> [NameValueDetail] {
        guard let trades = dataSourceArray.trade else { return [] }
        var tickerDataSourceArray = [NameValueDetail]()
        for trade in trades {
            tickerDataSourceArray.append(NameValueDetail(name: "\(trade.amountString)", value: "\(trade.price.convertDoubleToCurrency())", detail: "\(trade.mtsActualValue)"))
        }
        return tickerDataSourceArray
    }
}

extension TradeDetailsViewModel: WebSocketConnectionDelegate {
    func onConnected(connection: WebSocketConnection) {
        print("Web Socket Connected")
        // UnSubscribe to any stocks if any before reConnecting to webSocket
        subscribeToStocks() // Subscribe to given stocks now
    }
    
    func onDisconnected(connection: WebSocketConnection, error: Error?) {
        if let error = error {
            print("Disconnected with error:\(error)")
        } else {
            print("Disconnected by User action")
        }
    }
    
    func onError(connection: WebSocketConnection, error: Error) {
        print("Connection error:\(error)")
    }
    
    func onMessage(connection: WebSocketConnection, text: String) {
        if let data = text.data(using: .utf8) {
            parseAndUpdate(data: data)
        }
    }
    
    func onMessage(connection: WebSocketConnection, data: Data) {
        parseAndUpdate(data: data)
    }
}
