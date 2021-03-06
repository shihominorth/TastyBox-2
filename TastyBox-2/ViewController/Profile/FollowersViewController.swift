//
//  FlolowedUsersViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-11.
//

import UIKit
import Firebase
import RxSwift
import RxCocoa

class FollowersViewController: UIViewController, BindableType {
    
    typealias ViewModelType = FollowersVM
    
    
    // table view cell should be xib file or building progmatically.
    // cuz the views in the cell is different depending on my following user or other's
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: FollowersVM!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.viewModel.getFollowers()
            .bind(to: viewModel.usersSubject)
            .disposed(by: viewModel.disposeBag)
        
    }
    
    func bindViewModel() {
        
        let isMyFollowings = self.viewModel.user.uid == self.viewModel.userID
        
        bindToTableView(isMyRelatedUsers: isMyFollowings)
        
        tableView.rx.itemSelected
            .do(onNext: { indexPath in
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            .withLatestFrom(viewModel.usersSubject) { indexPath, users in
                return users[indexPath.row]
            }
            .subscribe(onNext: { [unowned self] user in
                
                self.viewModel.toProfile(user: user)
                
            })
            .disposed(by: viewModel.disposeBag)
        
    }
    
    func bindToTableView(isMyRelatedUsers: Bool) {
        
        if isMyRelatedUsers {
            
            let identifier = "myFollowingsTVCell"
            
            tableView.register(FollowerTVCell.self, forCellReuseIdentifier: identifier)
            
            let dataSource = RxDefaultTableViewDataSource<RelatedUser, FollowerTVCell>(identifier: identifier, configure: { row, follower, cell in
                
                cell.userNameLbl.text = follower.user.name
                
                cell.layoutIfNeeded()
                cell.userImgView.layer.cornerRadius = cell.userImgView.frame.width / 2
                
                guard let url = URL(string: follower.user.imageURLString) else { return }
                
                cell.userImgView.kf.setImage(with: url)
                
                
                cell.userManageBtn.rx.tap
                    .withLatestFrom(follower.isRelatedUserSubject)
//                    .withLatestFrom(self.viewModel.usersSubject) { isFollowing, users in
//
//                        return (isFollowing, users[row])
//
//                    }
//                    .flatMapLatest { isFollowings, user in
                    .flatMapLatest { isFollowings in
                        self.viewModel.updateRelatedUserStatus(isFollowing: isFollowings, updateUser: follower.user)
                    }
                    .subscribe(onNext: { isFollowing in

                        follower.isRelatedUserSubject.onNext(!isFollowing)

                    })
                    .disposed(by: cell.disposeBag)
                
                cell.deleteBtn.rx.tap
                    .withLatestFrom(follower.isRelatedUserSubject)
                    .subscribe(onNext: { [unowned self] isFollowing in
                        
                        self.viewModel.toManageRelatedUserVC(user: follower, isFollowing: isFollowing)
                        
                    })
                    .disposed(by: cell.disposeBag)

                follower.isRelatedUserSubject
                    .subscribe(onNext: { isFollowing in

                        cell.setUpUserManageBtn(isFollowing: isFollowing)

                    })
                    .disposed(by: cell.disposeBag)
                
            })
            
            viewModel.usersSubject
                .skip(1)
                .bind(to: tableView.rx.items(dataSource: dataSource))
                .disposed(by: viewModel.disposeBag)
            
        }
        else {
            
            let identifier = "userFollowingsTVCell"
            
            tableView.register(UserFollowingTVCell.self, forCellReuseIdentifier: identifier)
            
            let dataSource = RxDefaultTableViewDataSource<RelatedUser, UserFollowingTVCell>(identifier: identifier, configure: { row, follower, cell in
                
                cell.userNameLbl.text = follower.user.name
                
                cell.layoutIfNeeded()
                cell.userImgView.layer.cornerRadius = cell.userImgView.frame.width / 2
                
                guard let url = URL(string: follower.user.imageURLString) else { return }
                
                cell.userImgView.kf.setImage(with: url)
                
                cell.userManageBtn.isHidden = self.viewModel.user.uid == follower.user.userID

                if self.viewModel.user.uid != follower.user.userID {
                    
                    cell.setUpUserManageBtn(isFollowing: true)
                    
                        follower.isRelatedUserSubject
                        .subscribe(onNext: { isFollowing in
                            
                            cell.setUpUserManageBtn(isFollowing: isFollowing)
                            
                        })
                        .disposed(by: cell.disposeBag)
                    
                }

                
            })
            
            viewModel.usersSubject
                .skip(1)
                .bind(to: tableView.rx.items(dataSource: dataSource))
                .disposed(by: viewModel.disposeBag)
            
        }
        
        
        
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

extension FollowersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * 0.07
    }
    
}


class FollowerTVCell: UITableViewCell {
    
    let userImgView: UIImageView
    let userNameLbl: UILabel
    let userManageBtn: UIButton
    let deleteBtn: UIButton
    var disposeBag: DisposeBag
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        userImgView = {
            
            let imgView = UIImageView()
            imgView.translatesAutoresizingMaskIntoConstraints = false
            imgView.clipsToBounds = true
            
            return imgView
        }()
        
        userNameLbl = {
            
            let lbl = UILabel()
            lbl.translatesAutoresizingMaskIntoConstraints = false
            
            return lbl
            
        }()
        
        userManageBtn = {
            
            let btn = UIButton(type: .system)
            btn.translatesAutoresizingMaskIntoConstraints = false
            
            btn.layer.borderColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            btn.layer.borderWidth = 2
            btn.layer.cornerRadius = 10
            
            btn.setTitle("Following", for: .normal)
            btn.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            
            
            return btn
            
        }()
        
        deleteBtn = {
            
            let btn = UIButton()
            btn.translatesAutoresizingMaskIntoConstraints = false
            
            if let img = UIImage(systemName: "ellipsis.circle") {
                
                btn.setBackgroundImage(img, for: .normal)
                
            }
            
            btn.tintColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            
            return btn
        
        }()
        
        
        disposeBag = DisposeBag()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(userImgView)
        self.contentView.addSubview(userNameLbl)
        self.contentView.addSubview(userManageBtn)
        self.contentView.addSubview(deleteBtn)
        
        NSLayoutConstraint.activate([
            
            userImgView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
            userImgView.centerYAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.centerYAnchor),
            userImgView.widthAnchor.constraint(equalToConstant: self.contentView.frame.height * 0.95),
            userImgView.heightAnchor.constraint(equalToConstant: self.contentView.frame.height * 0.95)
            
        ])
        
        NSLayoutConstraint.activate([
            
            deleteBtn.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
            deleteBtn.centerYAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.centerYAnchor),
            deleteBtn.widthAnchor.constraint(equalToConstant: self.contentView.frame.height * 0.7),
            deleteBtn.heightAnchor.constraint(equalToConstant: self.contentView.frame.height * 0.7)
        
        ])
        
        NSLayoutConstraint.activate([
            
            userManageBtn.trailingAnchor.constraint(equalTo: self.deleteBtn.leadingAnchor, constant: -10),
            userManageBtn.centerYAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.centerYAnchor),
            userManageBtn.widthAnchor.constraint(equalToConstant: self.contentView.frame.width * 0.3),
            userManageBtn.heightAnchor.constraint(equalToConstant: self.contentView.frame.height * 0.7)
            
        ])
        
        NSLayoutConstraint.activate([
            
            userNameLbl.leadingAnchor.constraint(equalTo: self.userImgView.trailingAnchor, constant: 20),
            userNameLbl.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
            userNameLbl.trailingAnchor.constraint(equalTo: self.userManageBtn.leadingAnchor, constant: -20),
            userNameLbl.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor)
            
        ])
        
    }
    
    override func awakeFromNib() {
        
        disposeBag = DisposeBag()
        
    }
    
    
    func setUpUserManageBtn(isFollowing: Bool) {
        
        if isFollowing {
            
            self.userManageBtn.setTitle("Following", for: .normal)
            self.userManageBtn.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            self.userManageBtn.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
        }
        else {
            
            self.userManageBtn.setTitle("Follow", for: .normal)
            self.userManageBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            self.userManageBtn.tintColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            
        }
    }
    
}
