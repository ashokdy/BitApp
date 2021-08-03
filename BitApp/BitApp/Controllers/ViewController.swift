//
//  ViewController.swift
//  BitApp
//
//  Created by ashokdy on 01/08/2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView?
    
    var viewModel = TradingPairsViewModel()
    let margin: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAppsList()
        
        guard let collectionView = collectionView, let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
    }
    
    func fetchAppsList() {
        viewModel.getAppList { [weak self] (result, error) in
            guard error == nil else { return }
            self?.collectionView?.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tradeDetailsVC = segue.destination as? TradeDetailsViewController,
           let indexPath = sender as? IndexPath {
            tradeDetailsVC.symbols = viewModel.appsList?.map( { $0.symbol } ) ?? []
            tradeDetailsVC.symbol = viewModel.appsList?[indexPath.row].symbol
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.appsList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TradePairCell", for: indexPath) as? TradePairCollectionCell else { return UICollectionViewCell() }
        let symbol = viewModel.appsList?[indexPath.row]
        cell.nameLabel?.text = symbol?.symbol
        cell.priceLabel?.text = symbol?.price
        cell.percentageLabel?.text = symbol?.percentage
        cell.priceLabel?.textColor = symbol?.valueColor
        cell.percentageLabel?.textColor = symbol?.valueColor
        return  cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "Details", sender: indexPath)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let noOfCellsInRow = 2   //number of column you want
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: 80)
    }
}
