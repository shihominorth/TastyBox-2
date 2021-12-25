//
//  FollowingUsersViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-11.
//

import UIKit
import DifferenceKit
import Kingfisher
import SkeletonView
import RxSwift


class FollowingsViewController: UIViewController, BindableType {
    
    typealias ViewModelType = FolllowingsVM
    
    
    // table view cell should be xib file or building progmatically.
    // cuz the views in the cell is different depending on my following user or other's
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: FolllowingsVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        
        
    }
    
    
    func bindViewModel() {
        
        let isMyFollowings = self.viewModel.user.uid == self.viewModel.userID
        
        bindToTableView(isMyRelatedUsers: isMyFollowings)
        
        self.viewModel.getFollowings()
            .bind(to: viewModel.usersSubject)
            .disposed(by: viewModel.disposeBag)
        
    }
    
    
    
    func bindToTableView(isMyRelatedUsers: Bool) {
        
        if isMyRelatedUsers {
            
            let identifier = "myFollowingsTVCell"
            
            tableView.register(MyFollowingTVCell.self, forCellReuseIdentifier: identifier)
            
            let dataSource = RxDefaultTableViewDataSource<RelatedUser, MyFollowingTVCell>(identifier: identifier, configure: { row, user, cell in
                
                cell.userNameLbl.text = user.name
                
                cell.layoutIfNeeded()
                cell.userImgView.layer.cornerRadius = cell.userImgView.frame.width / 2
                
                guard let url = URL(string: user.imageURLString) else { return }
                
                cell.userImgView.kf.setImage(with: url)
                
                
                cell.userManageBtn.rx.tap
                    .withLatestFrom(user.isRelatedUserSubject)
                    .withLatestFrom(self.viewModel.usersSubject) { isFollowing, users in
                        
                        return (isFollowing, users[row])
                        
                    }
                    .flatMapLatest { isFollowings, user in
                        self.viewModel.updateRelatedUserStatus(isFollowing: isFollowings, updateUser: user)
                    }
                    .subscribe(onNext: { isFollowing in
                        
                        user.isRelatedUserSubject.onNext(!isFollowing)

                    })
                    .disposed(by: cell.disposeBag)
                
                user.isRelatedUserSubject
                    .subscribe(onNext: { isFollowing in
                        
                        cell.setUpUserManageBtn(isFollowing: isFollowing)
                        
                    })
                    .disposed(by: cell.disposeBag)
                
            })
            
            viewModel.usersSubject
                .bind(to: tableView.rx.items(dataSource: dataSource))
                .disposed(by: viewModel.disposeBag)
            
        }
        else {
            
            let identifier = "userFollowingsTVCell"
            
            tableView.register(UserFollowingTVCell.self, forCellReuseIdentifier: identifier)
            
            let dataSource = RxDefaultTableViewDataSource<RelatedUser, UserFollowingTVCell>(identifier: identifier, configure: { row, user, cell in
                
                cell.userNameLbl.text = user.name
                
                cell.layoutIfNeeded()
                cell.userImgView.layer.cornerRadius = cell.userImgView.frame.width / 2
                
                guard let url = URL(string: user.imageURLString) else { return }
                
                cell.userImgView.kf.setImage(with: url)
                
                cell.setUpUserManageBtn(isFollowing: true)
                
                user.isRelatedUserSubject
                    .subscribe(onNext: { isFollowing in
                        
                        cell.setUpUserManageBtn(isFollowing: isFollowing)
                        
                    })
                    .disposed(by: cell.disposeBag)
                
            })
            
            viewModel.usersSubject
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

extension FollowingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * 0.07
    }
    
}

class MyFollowingTVCell: UITableViewCell {
    
    let userImgView: UIImageView
    let userNameLbl: UILabel
    let userManageBtn: UIButton
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
        
        disposeBag = DisposeBag()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(userImgView)
        self.contentView.addSubview(userNameLbl)
        self.contentView.addSubview(userManageBtn)
        
        NSLayoutConstraint.activate([
            
            userImgView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
            userImgView.centerYAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.centerYAnchor),
            userImgView.widthAnchor.constraint(equalToConstant: self.contentView.frame.height * 0.95),
            userImgView.heightAnchor.constraint(equalToConstant: self.contentView.frame.height * 0.95)
            
        ])
        
        
        
        NSLayoutConstraint.activate([
            
            userManageBtn.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
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
        
        //        userManageBtn.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.setUpUserManageBtn(isFollowing: true)

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

class UserFollowingTVCell: UITableViewCell {
    
    let userImgView: UIImageView
    let userNameLbl: UILabel
    let userManageBtn: UIButton
    var disposeBag: DisposeBag
    
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        userImgView = {
            
            let imgView = UIImageView()
            
            return imgView
        }()
        
        userNameLbl = {
            
            let lbl = UILabel()
            
            return lbl
            
        }()
        
        userManageBtn = {
            
            let btn = UIButton(type: .system)
            
            btn.layer.borderColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            btn.layer.borderWidth = 2
            
            btn.layer.cornerRadius = 10
            
            return btn
            
        }()
        
        disposeBag = DisposeBag()
        
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(userImgView)
        self.contentView.addSubview(userNameLbl)
        self.contentView.addSubview(userManageBtn)
        
        NSLayoutConstraint.activate([
            
            userImgView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
            userImgView.centerYAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.centerYAnchor),
            userImgView.widthAnchor.constraint(equalToConstant: self.contentView.frame.height * 0.95),
            userImgView.heightAnchor.constraint(equalToConstant: self.contentView.frame.height * 0.95)
            
        ])
        
        
        NSLayoutConstraint.activate([
            
            userManageBtn.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
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
        //        userManageBtn.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
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
