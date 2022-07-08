//
//  ViewController.swift
//  ImageFeed
//
//  Created by Kalaiprabbha L on 12/02/22.
//

import UIKit
import UIScrollView_InfiniteScroll

class ImageFeedViewController: UIViewController {
    lazy var viewModel: ImageFeedViewModel = ImageFeedViewModel(service: DataNetworkService())
    
    var currentPage = 0
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    private func setView() {
        fetchPhotosFor(0)
    
        viewModel.reloadViewClosure = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        viewModel.showAlertClosure = { [weak self] in
            if let message = self?.viewModel.alertMessage {
                DispatchQueue.main.async {
                    self?.showAlert(message)
                }
            }
        }
        
        collectionView.addInfiniteScroll { [unowned self] collectionView in
            self.currentPage += 1
            self.fetchPhotosFor(self.currentPage)
            collectionView.finishInfiniteScroll()
        }
    }
    
    private func fetchPhotosFor(_ offset: Int = 0) {
        viewModel.fetchPhotosForOffset(currentPage, request: PhotoDataRequest(endPoint: URLEndPoint.list, page: currentPage))
    }
    
    private func showAlert( _ message: String ) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension ImageFeedViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell",
                                                            for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.setImageFor(viewModel.photos[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 200)
    }
}


