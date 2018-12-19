//
//  DQRxSwift.swift
//  DQSwiftMaster
//
//  Created by wondertek on 2018/12/18.
//  Copyright © 2018年 deqing. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

struct Music {
    let name: String
    let singer: String
    
    init(name: String, singer: String) {
        self.name = name
        self.singer = singer
    }
}

extension Music:CustomStringConvertible {
    var description : String {
        return "name:\(name) singer:\(singer)"
    }
    
}

struct MusicListViewModel {
    let data = Observable.just([
        Music(name: "无条件", singer: "陈奕迅"),
        Music(name: "你曾是少年", singer: "S.H.E"),
        Music(name: "从前的我", singer: "陈洁仪"),
        Music(name: "在木星", singer: "朴树"),

        ])
}


class RxViewController: UIViewController {
    
    //tableView对象
    private lazy var tableView : UITableView = {
        let listTableView = UITableView(frame: CGRect.zero, style: .plain)
//        listTableView.dataSource = self
//        listTableView.delegate = self
        listTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        listTableView.backgroundColor = UIColor.white
        listTableView.separatorStyle = .none
        return listTableView
    }()
    
    let disposeBag = DisposeBag()
    
    //歌曲列表数据源
    let musicListViewModel = MusicListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        musicListViewModel.data.bind(to: tableView.rx.items(cellIdentifier: "cell")){_,music, cell in
            cell.textLabel?.text = music.name
            cell.detailTextLabel?.text = music.singer
            
        }.disposed(by: disposeBag)
        tableView.rx.modelSelected(Music.self).subscribe({music in
             print("你选中的歌曲信息【\(music)】")
        }).disposed(by: disposeBag)
    }
}

//extension RxViewController: UITableViewDataSource {
//    //返回单元格数量
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return musicListViewModel.data
//    }
//
//    //返回对应的单元格
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
//        -> UITableViewCell {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "musicCell")!
//            let music = musicListViewModel.data[indexPath.row]
//            cell.textLabel?.text = music.name
//            cell.detailTextLabel?.text = music.singer
//            return cell
//    }
//}
//
//extension RxViewController: UITableViewDelegate {
//    //单元格点击
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("你选中的歌曲信息【\(musicListViewModel.data[indexPath.row])】")
//    }
//}

// 订阅 Observable
//Observable<T>
//Observable<T> 这个类就是 Rx 框架的基础，我们可以称它为可观察序列。它的作用就是可以异步地产生一系列的 Event（事件），即一个 Observable<T> 对象会随着时间推移不定期地发出 event(element : T) 这样一个东西。
//而且这些 Event 还可以携带数据，它的泛型 <T> 就是用来指定这个 Event 携带的数据的类型。
//有了可观察序列，我们还需要有一个 Observer（订阅者）来订阅它，这样这个订阅者才能收到 Observable<T> 不时发出的 Event。
//Observable 从创建到终结流程
//（1）一个 Observable 序列被创建出来后它不会马上就开始被激活从而发出 Event，而是要等到它被某个人订阅了才会激活它。
//（2）而 Observable 序列激活之后要一直等到它发出了 .error 或者 .completed 的 event 后，它才被终结。
class Ob :UIViewController {
    override func viewDidLoad() {
        let observable = Observable.of("A","B")
        
        observable.subscribe { event in
            print(event)
        }
        
        do {
            let observable = Observable.of("A", "B", "C")
            
            observable.subscribe { event in
                print(event.element)
            }
        }
        
        do {
            let observable = Observable.of("A", "B", "C")
            observable.subscribe(onNext: { element in
                print(element)
            }, onError: { error in
                print(error)
            }, onCompleted: {
                print("completed")
            }, onDisposed: {
                print("disposed")
            }
            )
        }
        
        let observable1 = Observable.of("A", "B", "C")
        
        observable1
            .do(onNext: { element in
                print("Intercepted Next：", element)
            }, onError: { error in
                print("Intercepted Error：", error)
            }, onCompleted: {
                print("Intercepted Completed")
            }, onDispose: {
                print("Intercepted Disposed")
            })
            .subscribe(onNext: { element in
                print(element)
            }, onError: { error in
                print(error)
            }, onCompleted: {
                print("completed")
            }, onDisposed: {
                print("disposed")
            })
        
        let observable2 = Observable<Int>.interval(1, scheduler:MainScheduler.instance)
        
        observable2.map{"当前的索引数：\($0)"}
            .bind{ [weak self](text) in
                print(text)
        }.dispose()
    }
    
}


//其实 RxCocoa 在对许多 UI 控件进行扩展时，就利用 Binder 将控件属性变成观查者

extension Reactive where Base: UIControl {
    
    public var isEnabled:Binder<Bool> {
        return Binder(self.base) { control, value in
            control.isEnabled = value
        }
    }
    
//    let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
//    observable
//    .map { $0 % 2 == 0 }
//    .bind(to: button.rx.isEnabled)
//    .disposed(by: disposeBag)
}

extension UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder(self) { label, fontSize in
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}

extension Reactive where Base: UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder(self.base) { label, fontSize in
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}

extension Reactive where Base: UILabel {
    
    /// Bindable sink for `text` property.
    public var text: Binder<String?> {
        return Binder(self.base) { label, text in
            label.text = text
        }
    }
    
    /// Bindable sink for `attributedText` property.
    public var attributedText: Binder<NSAttributedString?> {
        return Binder(self.base) { label, text in
            label.attributedText = text
        }
    }
    
}
