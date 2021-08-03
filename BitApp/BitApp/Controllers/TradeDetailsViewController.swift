//
//  TradeDetailsViewController.swift
//  BitApp
//
//  Created by ashokdy on 01/08/2021.
//

import UIKit

class TradeDetailsViewController: UIViewController {
    @IBOutlet weak var tickerCollectionView: UICollectionView?
    @IBOutlet weak var tradeTableView: UITableView?
    @IBOutlet weak var textfieldForPickerHolder: UITextField?
    
    var symbolPicker = UIPickerView()
    var pickerSymbol = ""
    let viewModel = TradeDetailsViewModel()
    var symbols = [String]()
    var symbol: String? {
        didSet {
            viewModel.configureWebSocket(symbol: symbol)
            self.title = symbol
            configureNavBarItem()
        }
    }
    let margin: CGFloat = 10
    
    var tickerDataSource: [NameValue] {
        return viewModel.getTickerDataSource()
    }
    
    var tradeDataSource: [NameValueDetail] {
        return viewModel.getTradeDataSource()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tradeTableView?.register(UINib(nibName: "TradeTableCell", bundle: nil), forCellReuseIdentifier: "TradeTableCell")
        tradeTableView?.register(UINib(nibName: "TradeTableCell", bundle: nil), forCellReuseIdentifier: "TradeHeader")
        viewModel.dataFetched = {[weak self] reload in
            switch reload {
            case .ticker:
                DispatchQueue.main.async {
                    self?.tickerCollectionView?.reloadData()
                }
            default:
                DispatchQueue.main.async {
                    self?.tradeTableView?.reloadData()
                }
            }
        }
        configureCollectionView()
        configureNavBarItem()
        configurePickerView()
    }
    
    func configureCollectionView() {
        guard let collectionView = tickerCollectionView, let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
    }
    
    func configureNavBarItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: symbol, style: .plain, target: self, action: #selector(changeSymbol))
    }
    
    func configurePickerView() {
        symbolPicker = UIPickerView(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 300))
        symbolPicker.backgroundColor = .white
        
        symbolPicker.delegate = self
        symbolPicker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(doneChangeSymbol))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelChangeSymbol))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textfieldForPickerHolder?.inputView = symbolPicker
        textfieldForPickerHolder?.inputAccessoryView = toolBar
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.webSocketConnection?.disconnect()
    }
    
    @objc func doneChangeSymbol() {
        textfieldForPickerHolder?.resignFirstResponder()
        symbol = pickerSymbol
    }
    
    @objc func changeSymbol() {
        textfieldForPickerHolder?.becomeFirstResponder()
    }
    
    @objc func cancelChangeSymbol() {
        textfieldForPickerHolder?.resignFirstResponder()
    }
}

extension TradeDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tickerDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TickerCell", for: indexPath) as? TickerCollectionCell else { return UICollectionViewCell() }
        let nameValue = tickerDataSource[indexPath.row]
        cell.nameLabel?.text = nameValue.name
        cell.valueLabel?.text = nameValue.value
        return  cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let noOfCellsInRow = 2   //number of column you want
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: 65)
    }
}

extension TradeDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: "TradeHeader") as? TradeTableCell else { return UIView() }
        headerView.amountInBTCLabel?.text = "Amount(BTC)"
        headerView.amountInBTCLabel?.font = .boldSystemFont(ofSize: 15)
        headerView.priceLabel?.text = "Price(AED)"
        headerView.priceLabel?.font = .boldSystemFont(ofSize: 15)
        headerView.timeLabel?.text = "Time"
        headerView.timeLabel?.font = .boldSystemFont(ofSize: 15)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tradeDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TradeTableCell") as? TradeTableCell else { return UITableViewCell() }
        let trade = tradeDataSource[indexPath.row]
        cell.amountInBTCLabel?.text = trade.name
        cell.priceLabel?.text = trade.value
        cell.timeLabel?.text = trade.detail
        return cell
    }
}

extension TradeDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        symbols.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        symbols[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerSymbol = symbols[row]
    }
}
