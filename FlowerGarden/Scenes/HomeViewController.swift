//
//  ViewController.swift
//  FlowerGarden
//
//  Created by 박지용 on 2022/09/13.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import CoreLocation

class HomeViewController: UIViewController {

    @IBOutlet weak var bannerCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    var ownerList: [Owners] = []
    var currentCoordinate: CLLocationCoordinate2D?
    var nowPage: Int = 0
    
    let dataArray: Array<UIImage> = [UIImage(named: "Banner_0")!, UIImage(named: "Banner_1")!, UIImage(named: "Banner_2")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bannerTimer()
        
        saveCurrentCoordinate()
        
        MapViewController().dbLoad { [weak self] owners in
            guard let self = self else { return }

            self.ownerList = owners
            self.calculateDistances()
            self.ownerList.sort { $0.distance ?? 100000 < $1.distance ?? 100000}
            
            print(self.currentCoordinate?.latitude, self.currentCoordinate?.longitude)
            
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    /*
    private func welcomeText() {
        var ref: DatabaseReference!
        ref = Database.database().reference()

        if let userInfo = Auth.auth().currentUser?.providerData[0] {
            let user = Auth.auth().currentUser
            ref.child("user_list/\(user?.uid ?? "userID")/name").getData(completion:  { error, snapshot in
              guard error == nil else {
                print(error!.localizedDescription)
                return;
              }
                let userName = snapshot?.value as? String ?? "고객";
                self.userWelcome.text = "\(userInfo.displayName ?? userName) 님 환영합니다."
            });
        }
        else {
            userWelcome.text = "OOO 님 환영합니다."
        }
    }
    */
}

//MARK: setupLayout
extension HomeViewController {
    func setupLayout() {
        
        
        bannerCollectionView.layer.cornerRadius = 8.0
        bannerCollectionView.clipsToBounds = true
        
        bannerCollectionView.delegate = self
        bannerCollectionView.dataSource = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        tableView.rowHeight = 90.0
        
    }
}

//MARK: CollectionView
extension HomeViewController: UICollectionViewDelegate {
    
}

extension HomeViewController: UICollectionViewDataSource {
    
    // CollectionView 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    // CollectionView Cell 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = bannerCollectionView.dequeueReusableCell(withReuseIdentifier: "HomeBannerCollectionViewCell", for: indexPath) as! HomeBannerCollectionViewCell
        cell.imageView.image = dataArray[indexPath.row]
        
        return cell
    }
    
    // 3초마다 실행되는 타이머
    func bannerTimer() {
        let _: Timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (Timer) in
            self.bannerMove()
        }
    }
    // 배너 움직이는 매서드
    func bannerMove() {
        // 현재페이지가 마지막 페이지일 경우
        if nowPage == dataArray.count-1 {
        // 맨 처음 페이지로 돌아감
            bannerCollectionView.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .right, animated: true)
            nowPage = 0
            return
        }
        // 다음 페이지로 전환
        nowPage += 1
        bannerCollectionView.scrollToItem(at: NSIndexPath(item: nowPage, section: 0) as IndexPath, at: .right, animated: true)
    }
    
}

//MARK: TableView
extension HomeViewController: UITableViewDelegate {
    
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ownerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreListTableViewCell", for: indexPath) as? StoreListTableViewCell
        
        cell?.titleLabel.text = ownerList[indexPath.row].store_name
        cell?.addressLabel.text = ownerList[indexPath.row].store_address
        
        let imageUrlString = "gs://flowergarden-6d59b.appspot.com/\(ownerList[indexPath.row].store_name)"
        loadImage(imageUrlString) { (image) in
            DispatchQueue.main.async {
                cell?.storeImageView.image = image ?? UIImage(systemName: "leaf.circle.fill")
            }
        }
        
        return cell ?? UITableViewCell()
    }
    
}

extension HomeViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let cell = tableView.cellForRow(at: indexPath) as? StoreListTableViewCell
            
            let imageUrlString = "gs://flowergarden-6d59b.appspot.com/\(ownerList[indexPath.row].store_name)"
            loadImage(imageUrlString) { (image) in
                DispatchQueue.main.async {
                    cell?.storeImageView.image = image ?? UIImage(systemName: "leaf.circle.fill")
                }
            }
        }
    }
}

extension HomeViewController {
    func loadImage(_ imageUrlString: String, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: imageUrlString)
        
        if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) {
            completion(cachedImage)
            return
        }
        
        let storage = Storage.storage()
        storage.reference(forURL: imageUrlString).downloadURL { (url, error) in
            guard let url = url, error == nil else {
                completion(nil)
                return
            }
            
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    ImageCacheManager.shared.setObject(image, forKey: cacheKey)
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }
    }

    // 현재 좌표 저장
    func saveCurrentCoordinate() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            if let currentLocation = locationManager.location {
                currentCoordinate = currentLocation.coordinate
            }
        }
    }
    
    // 가게 거리계산
    func calculateDistances() {
        print("#1", #function)
        
        guard let currentCoordinate = currentCoordinate else {
            return
        }
        
        print("#2", #function)
        
        for index in 0..<ownerList.count {
            let currentLocation = CLLocation(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
            let dataLocation = CLLocation(latitude: Double(ownerList[index].y)!, longitude: Double(ownerList[index].x)!)
            
            let distance = currentLocation.distance(from: dataLocation)
            print(ownerList[index].x, ownerList[index].y, distance)
            ownerList[index].distance = distance
        }
    }
}
