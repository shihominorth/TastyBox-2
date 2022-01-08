//
//  ProfileViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-19.
//

import UIKit
import Kingfisher
import SkeletonView
import RxSwift

class ProfileViewController: UIViewController, BindableType {
    
    typealias ViewModelType = ProfileVM
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: ProfileVM!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(ProfileMainRCV.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "profileMainRCV")
        collectionView.register(NumberProfileRCV.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "numberProfileRCV")
        
        collectionView.register(ProfileRecipeCVCell.self, forCellWithReuseIdentifier: "profileCVCell")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CollectionViewFlowLayoutType(.photos, frame: view.frame).sizeForItem
        flowLayout.sectionInset = CollectionViewFlowLayoutType(.photos, frame: view.frame).sectionInsets
        flowLayout.minimumInteritemSpacing = 2.0
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 1.0
        //        flowLayout.headerReferenceSize = CGSize(width: self.collectionView.frame.width, height: self.view.frame.height * 0.2)
        
        collectionView.collectionViewLayout = flowLayout
        
        collectionView.isSkeletonable = true
        
        collectionView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .concrete), animation: nil, transition: .crossDissolve(0.25))
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [unowned self] in
            
            self.collectionView.stopSkeletonAnimation()
            self.view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
            
            self.collectionView.reloadData()
            
        }
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        
    }
    
    
    func bindViewModel() {
        
        self.viewModel.getUserPostedRecipes()
            .subscribe(onNext: { [unowned self] recipes in
                
                self.viewModel.recipes = recipes
                
            })
            .disposed(by: viewModel.disposeBag)
        
        
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                
                self.viewModel.toRecipeDetail(recipe: self.viewModel.recipes[indexPath.row])
                
            })
            .disposed(by: viewModel.disposeBag)
        
        
        self.viewModel.isFollowingUser()
            .debug("is following")
            .bind(to: viewModel.isFollowingSubject)
            .disposed(by: viewModel.disposeBag)
        
        
        self.viewModel.getProfileImage()
            .bind(to: viewModel.profileImageDataSubject)
            .disposed(by: viewModel.disposeBag)
        
        viewModel.getFollowingsNum()
            .subscribe(onNext: { [unowned self] followings, followers in
                
                self.viewModel.followingsNumSubject.onNext(followings)
                self.viewModel.followersNumSubject.onNext(followers)
                
            })
            .disposed(by: viewModel.disposeBag)
        
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension ProfileViewController: SkeletonCollectionViewDataSource, SkeletonCollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "profileCVCell"
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, supplementaryViewIdentifierOfKind: String, at indexPath: IndexPath) -> ReusableCellIdentifier? {
        
        switch indexPath.section {
        case 0:
            return "profileMainRCV"
        case 1:
            return "numberProfileRCV"
        default:
            break
        }
        
        return nil
        
    }
    
    func numSections(in collectionSkeletonView: UICollectionView) -> Int {
        return 3
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
        case 2:
            return 15
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
        case 2:
            return viewModel.recipes.count
        default:
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        switch section {
        case 0:
            return CGSize(width: self.view.frame.width, height: self.view.frame.height * 0.2)
        case 1:
            return CGSize(width: self.view.frame.width, height: self.view.frame.height * 0.1)
            
        default:
            return CGSize.zero
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch indexPath.section {
        case 0:
            
            if kind == UICollectionView.elementKindSectionHeader {
                
                if let crv = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "profileMainRCV", for: indexPath) as? ProfileMainRCV {
                    
                    crv.userNameLbl.text = self.viewModel.profileUser.name
                    crv.userImgView.layer.cornerRadius = crv.userImgView.bounds.size.width / 2
                    
                    crv.followBtn.layer.masksToBounds = true
                    crv.followBtn.layer.cornerRadius = 15
                    crv.followBtn.layer.borderWidth = 2
                    
                    if let url = URL(string: viewModel.profileUser.imageURLString) {
                        
                        crv.userImgView.kf.setImage(with: url) { result in
                            
                            
                            switch result {
                                
                            case .failure(let err):
                                print(err)
                                
                            default:
                                break
                            }
                        }
                    }
                    
                    let tappedFollowBtn = crv.followBtn.rx.tap
                        .throttle(.microseconds(1000), scheduler: MainScheduler.instance)
                        .debug("tapped")
                        .withLatestFrom(self.viewModel.isFollowingSubject)
                        .debug("isFollowing what?")
                        .share(replay: 1, scope: .forever)
                    
                    
                    let willUnFollowing = tappedFollowBtn
                        .filter { $0 }
                    
                    let willFollowing = tappedFollowBtn
                        .filter { !$0 }
                    
                    
                    
                    willFollowing
                        .flatMapLatest { [unowned self] _ in
                            self.viewModel.followPublisher(user: self.viewModel.user, publisher: self.viewModel.profileUser)
                        }
                        .catch { err in
                            
                            print(err)
                            
                            return .empty()
                        }
                        .subscribe(onNext: { isCompleted in
                            
                            if isCompleted {
                                print("success")
                                
                                self.viewModel.isFollowingSubject.onNext(true)
                            }
                            else {
                                print("same uid")
                            }
                            
                        })
                        .disposed(by: viewModel.disposeBag)
                    
                    willUnFollowing
                        .flatMapLatest { [unowned self] _ in
                            self.viewModel.unFollowPublisher(user: self.viewModel.user, publisher: self.viewModel.profileUser)
                        }
                        .catch { err in
                            
                            print(err)
                            
                            return .empty()
                        }
                        .subscribe(onNext: { isCompleted in
                            
                            if isCompleted {
                                print("success")
                                self.viewModel.isFollowingSubject.onNext(false)
                            }
                            else {
                                print("same uid")
                            }
                            
                        })
                        .disposed(by: viewModel.disposeBag)
                    
                    
                    viewModel.isFollowingSubject
                        .subscribe(onNext: { isFollowing in
                            
                            crv.setUpFollowingBtn(isFollowing: isFollowing)
                            
                        })
                        .disposed(by: viewModel.disposeBag)
                    
                    viewModel.profileImageDataSubject
                        .subscribe(onNext: { data in
                            
                            guard let image = UIImage(data: data) else { return }
                            crv.userImgView.image = image
                            
                        })
                        .disposed(by: crv.disposeBag)
                    
                    return crv
                }
                
            }
            
        case 1:
            
            if kind == UICollectionView.elementKindSectionHeader {
               
                if let crv = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "numberProfileRCV", for: indexPath) as? NumberProfileRCV {
                    
                    viewModel.postedRecipesSubject
                        .subscribe(onNext: { recipes in
                            
                            crv.numPostedBtn.setTitle("\(recipes.count)\nRecipes", for: .normal)
                            
                        })
                        .disposed(by: crv.disposeBag)
                    
                    viewModel.followingsNumSubject
                        .subscribe(onNext: { followings in
                            
                            crv.numFollowingBtn.setTitle("\(followings)\nfollowings", for: .normal)

                        })
                        .disposed(by: crv.disposeBag)
                    
                    viewModel.followersNumSubject
                        .subscribe(onNext: { followers in
                            
                            crv.numFollowedBtn.setTitle("\(followers)\nfollowed", for: .normal)
                            
                        })
                        .disposed(by: crv.disposeBag)
                    
                    crv.numFollowingBtn.rx.tap
                        .subscribe(onNext: { [unowned self] in
                            
                            self.viewModel.toRelatedUsers()
                            
                        })
                        .disposed(by: crv.disposeBag)
                    
                    crv.numFollowedBtn.rx.tap
                        .subscribe(onNext: { [unowned self] in
                            
                            self.viewModel.toRelatedUsers()
                            
                        })
                        .disposed(by: crv.disposeBag)
                    
                    return crv
                }
                
            }
            
        default:
            break
        }
        
        return UICollectionReusableView()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCVCell", for: indexPath) as? ProfileRecipeCVCell {
            
            if let imgURL = URL(string: self.viewModel.recipes[indexPath.row].imgString) {
                
                cell.imgView.kf.setImage(with: imgURL)
                
            }
            
            return cell
            
        }
        
        return UICollectionViewCell()
    }
    
    
    
}

class ProfileMainRCV: UICollectionReusableView {
    
    var userImgView: UIImageView!
    var userNameLbl: UILabel!
    var followBtn: UIButton!
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        
        self.userImgView = {
            
            let imgView = UIImageView()
            imgView.isSkeletonable = true
            imgView.translatesAutoresizingMaskIntoConstraints = false
            imgView.clipsToBounds = true
            imgView.accessibilityIdentifier = "user image view"
            imgView.contentMode = .scaleAspectFill
            
            return imgView
            
        }()
        
        self.userNameLbl = {
            
            let lbl = UILabel()
            lbl.isSkeletonable = true
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.numberOfLines = 0
            lbl.accessibilityIdentifier = "user lbl"
            
            return lbl
        }()
        
        self.followBtn = {
            
            let btn = UIButton(type: .system)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.isSkeletonable = true
            btn.accessibilityIdentifier = "user following btn"
            
            return btn
            
        }()
        
        super.init(frame: frame)
        
        self.isSkeletonable = true
        
        
        self.addSubview(self.userImgView)
        self.addSubview(self.userNameLbl)
        self.addSubview(self.followBtn)
        
        
        NSLayoutConstraint.activate([
            
            self.userImgView.widthAnchor.constraint(equalToConstant: self.frame.height * 0.5),
            self.userImgView.heightAnchor.constraint(equalToConstant: self.frame.height * 0.5),
            self.userImgView.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: 10),
            self.userImgView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
        ])
        
        
        NSLayoutConstraint.activate([
            
            self.userNameLbl.leadingAnchor.constraint(equalTo: self.userImgView.trailingAnchor, constant: 30),
            self.userNameLbl.topAnchor.constraint(equalTo: self.userImgView.topAnchor),
            self.userNameLbl.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor, constant: -30)
            
        ])
        
        
        
        NSLayoutConstraint.activate([
            
            self.followBtn.heightAnchor.constraint(equalToConstant: 30.0),
            self.followBtn.leadingAnchor.constraint(equalTo: self.userNameLbl.leadingAnchor),
            self.followBtn.trailingAnchor.constraint(equalTo: self.userNameLbl.trailingAnchor),
            self.followBtn.bottomAnchor.constraint(equalTo: self.userImgView.bottomAnchor)
            
        ])
        
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        
        disposeBag = DisposeBag()
        
    }
    
    func setUpFollowingBtn(isFollowing: Bool) {
        
        let title = isFollowing ? "Followed" : "Follow"
        
        followBtn.setTitle(title, for: .normal)
        
        followBtn.backgroundColor = isFollowing ? #colorLiteral(red: 0.9978365302, green: 0.9878997207, blue: 0.7690339684, alpha: 1) : #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        followBtn.layer.borderColor = isFollowing ? #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1) : #colorLiteral(red: 0.9978365302, green: 0.9878997207, blue: 0.7690339684, alpha: 1)
        
        let color = isFollowing ? #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1) : #colorLiteral(red: 0.9978365302, green: 0.9878997207, blue: 0.7690339684, alpha: 1)
        followBtn.tintColor = color
        
    }
    
}


class NumberProfileRCV: UICollectionReusableView {
    
    let numStackView: UIStackView
    let numPostedBtn: UIButton
    let numFollowingBtn: UIButton
    let numFollowedBtn: UIButton
    var disposeBag = DisposeBag()

    
    override init(frame: CGRect) {
        
        numStackView = {
            
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.distribution = .equalSpacing
            stackView.isSkeletonable = true
            
            return stackView
        }()
        
        numPostedBtn = {
            
            let btn = UIButton(type: .system)

            btn.tintColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            btn.titleLabel?.numberOfLines = 0
            btn.titleLabel?.textAlignment = .center
            btn.isSkeletonable = true
            
            return btn
        }()
        
        numFollowingBtn =  {
            
            let btn = UIButton(type: .system)

            btn.tintColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            btn.titleLabel?.numberOfLines = 0
            btn.titleLabel?.textAlignment = .center
            btn.isSkeletonable = true
            
            return btn
        }()
        
        
        numFollowedBtn =  {
            
            let btn = UIButton(type: .system)

            btn.tintColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            btn.titleLabel?.numberOfLines = 0
            btn.titleLabel?.textAlignment = .center
            btn.isSkeletonable = true
            
            return btn
            
        }()
        
        disposeBag = DisposeBag()
        
        super.init(frame: frame)
        
        self.numStackView.addArrangedSubview(numPostedBtn)
        self.numStackView.addArrangedSubview(numFollowingBtn)
        self.numStackView.addArrangedSubview(numFollowedBtn)
        
        self.addSubview(numStackView)
        
        NSLayoutConstraint.activate([
            
            self.numStackView.widthAnchor.constraint(equalToConstant: self.frame.width * 0.7),
            self.numStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.numStackView.topAnchor.constraint(lessThanOrEqualTo: self.layoutMarginsGuide.topAnchor),
            self.numStackView.bottomAnchor.constraint(lessThanOrEqualTo: self.layoutMarginsGuide.bottomAnchor)
            
        ])
        
        self.isSkeletonable = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        
        disposeBag = DisposeBag()
        
    }
    
}

class ProfileRecipeCVCell: UICollectionViewCell {
    
    var imgView: UIImageView!
    
    override init(frame: CGRect) {
        
        self.imgView = UIImageView()
        
        super.init(frame: frame)
        
        self.addSubview(self.imgView)
        self.imgView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            self.imgView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.imgView.topAnchor.constraint(equalTo: self.topAnchor),
            self.imgView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.imgView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            
        ])
        
        self.contentView.isSkeletonable = true
        self.imgView.isSkeletonable = true
        self.isSkeletonable = true
        
    }
    //
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    
}
