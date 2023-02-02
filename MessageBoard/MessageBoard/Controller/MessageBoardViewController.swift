//
//  MessageBoardViewController.swift
//  MessageBoard
//
//  Created by imac-1681 on 2023/1/17.
//

import UIKit
import RealmSwift
import UserNotifications
class MessageBoardViewController: UIViewController {
    
    @IBOutlet weak var messagePeopleLabel: UILabel!
    @IBOutlet weak var messagePeopleTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var arangeBtn: UIButton!
    
    var messageArray: [Message] = []
    var optionsArray:[String] = ["預設","舊到新","新到舊"]
    
    var isUpData : Bool = false
    var upDataIndex : Int = 0
    
    enum SortRule{
        //
        case `default`
        //
        case oldToNew
        //
        case newToOld
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFromDatabase()
    }
    
    func setupUI(){
        messagePeopleLabel.text = "留言人"
        messageLabel.text = "留言內容"
        setupTableView()
        setupButton()
        setupNavigationBarStyle()
        setupNavigationBarButtonItems()
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    private func setupTableView(){
        messageTableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: MessageTableViewCell.identifier)
        messageTableView.dataSource = self
        messageTableView.delegate = self
    }
    
    private func setupNavigationBarButtonItems(){
        let sortItem = UIBarButtonItem(image: UIImage(systemName: "lineweight"), style: .done, target: self, action: #selector(sortBtnClicked))
        navigationItem.leftBarButtonItem = sortItem
        
        let addItem = UIBarButtonItem(image: UIImage(systemName: "plus.message"), style: .done, target: self, action: #selector(sendBtnClicked))
        navigationItem.rightBarButtonItem = addItem
    }
    
    private func setupNavigationBarStyle(){
        let appearance = UINavigationBarAppearance()
        self.navigationController?.navigationBar.standardAppearance = appearance
    }
    
    private func setupButton(){
        submitBtn.setTitle("送出", for: .normal)
        arangeBtn.setTitle("排序", for: .normal)
        submitBtn.layer.cornerRadius = 10
        submitBtn.layer.backgroundColor = UIColor.lightGray.cgColor
        arangeBtn.layer.cornerRadius = 10
        arangeBtn.layer.backgroundColor = UIColor.lightGray.cgColor
    }
    
    func sortMessage(rule:SortRule){
        let realm = try! Realm()
        var results:Results<MessageTable>
        switch rule{
        case .`default`:
            results = realm.objects(MessageTable.self).sorted(byKeyPath: "updateTimestamp",ascending: true)
        case .oldToNew:
            results = realm.objects(MessageTable.self).sorted(byKeyPath: "updateTimestamp",ascending: true)
        case .newToOld:
            results = realm.objects(MessageTable.self).sorted(byKeyPath: "updateTimestamp",ascending: false)
        }
        
        if results.count > 0 {
            messageArray = []
            for i in results{
                messageArray.append(Message(name: i.name, content: i.content, createTimestamp: i.createTimestamp, updateTimestamp: i.updateTimestamp))
            }
            DispatchQueue.main.async {
                self.messageTableView.reloadData()
            }
        }
    }
    
//    @objc func sortItemClicked(){
//        showActionSheet(title: "請選擇排序方式", message: "", options: optionsArray){
//            index in
//            switch index{
//            case 0:
//                print("選擇預設排序方式")
//                self.sortMessage(rule: .default)
//            case 1:
//                print("選擇舊到新排序方式")
//                self.sortMessage(rule: .oldToNew)
//            case 3:
//                print("選擇新到舊排序方式")
//                self.sortMessage(rule: .newToOld)
//            default:
//                break
//            }
//        }
//    }
    
    @IBAction @objc func sortBtnClicked(_ sender: Any) {
        showActionSheet(title: "請選擇排序方式", message: "", options: optionsArray){
            index in
            switch index{
            case 0:
                print("選擇預設排序方式")
                self.sortMessage(rule: .default)
            case 1:
                print("選擇舊到新排序方式")
                self.sortMessage(rule: .oldToNew)
            case 3:
                print("選擇新到舊排序方式")
                self.sortMessage(rule: .newToOld)
            default:
                break
            }
        }
    }
    
    
    @IBAction @objc func sendBtnClicked(_ sender: Any) {
        closeKeyboard()
        guard let messagePeople = messagePeopleTextField.text,!(messagePeople.isEmpty) else{
            showAlert(title: "錯誤", message: "請輸入留言人", confirmTitle: "關閉")
            return
        }
        guard let message = messageTextView.text,!(message.isEmpty) else{
            showAlert(title: "錯誤", message: "請輸入留言", confirmTitle: "關閉")
            return
        }
        
        print("留言人：\(messagePeopleTextField.text!)")
        print("留言內容：\(messageTextView.text!)")
        
        if isUpData == true{
            messageArray[upDataIndex].name = messagePeople
            messageArray[upDataIndex].content = message
            messageArray[upDataIndex].updateTimestamp = Int64(Date().timeIntervalSince1970)
        
            LocalDatabase.DataDao.updateData(message: messageArray[upDataIndex])
            
            isUpData.toggle()
            createNotification(msgTitle: self.messagePeopleTextField.text, msgbody: self.messageTextView.text)
            showAlert(title: "成功", message: "留言更新成功", confirmTitle: "關閉"){
                self.messagePeopleTextField.text = ""
                self.messageTextView.text = ""
            }
            
        }else{
            let msg = Message(name: messagePeople, content: message, createTimestamp: Int64(Date().timeIntervalSince1970),updateTimestamp: Int64(Date().timeIntervalSince1970))
            LocalDatabase.DataDao.addData(message: msg)
            createNotification(msgTitle: self.messagePeopleTextField.text, msgbody: self.messageTextView.text)
            showAlert(title: "成功", message: "留言已送出",confirmTitle: "關閉"){
                self.messagePeopleTextField.text = ""
                self.messageTextView.text = ""
            }
//            let content = UNMutableNotificationContent()
//            content.title = "123"
//            content.subtitle = "456"
//            content.body = "789"
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//            let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
//
//            UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
//                print("成功建立通知...")
//            })
        }
        
        fetchFromDatabase()
    }
    
    //關鍵盤
    @objc func closeKeyboard(){
        view.endEditing(true)
    }
    //從Database撈資料
    func fetchFromDatabase(){
        DispatchQueue.global().async {
            let realm = try! Realm()
            let results = realm.objects(MessageTable.self)
            if results.count > 0 {
                self.messageArray = []
                for i in results{
                    self.messageArray.append(Message(name: i.name, content: i.content, createTimestamp: i.createTimestamp,updateTimestamp:i.updateTimestamp))
                }
                DispatchQueue.main.async {
                    self.messageTableView.reloadData()
                }
            }
        }
    }
    
//    func addMessage(message:Message){
//        let realm = try! Realm()
//        let table = MessageTable()
//        table.name = message.name
//        table.content = message.content
//        table.createTimestamp = message.createTimestamp
//
//        do{
//            try realm.write{
//                realm.add(table)
//                print("File url :\(String(describing: realm.configuration.fileURL?.absoluteString))")
//            }
//        }catch{
//            print("Realm Add Failed:\(error.localizedDescription)")
//        }
//    }
//
//    func updataMessage(message:Message){
//        let realm = try! Realm()
//        let upDataMessage = realm.objects(MessageTable.self).where{$0.createTimestamp == self.messageArray[upDataIndex].createTimestamp}
//        do{
//            try realm.write{
//                upDataMessage[0].name = message.name
//                upDataMessage[0].content = message.content
//                upDataMessage[0].updateTimestamp = message.createTimestamp
//            }
//        }catch{
//            print("Realm updata Failed:\(error.localizedDescription)")
//        }
//    }
//
//    func deleteMessage(message:MessageTable){
//        let realm = try! Realm()
//        do{
//            try realm.write{
//                realm.delete(message)
//            }
//        }catch{
//            print("Realm Delete Failed:\(error.localizedDescription)")
//        }
//    }
    
    func showAlert(title:String?,message:String?,confirmTitle:String,confirm:(() -> Void)? = nil ){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: confirmTitle, style: .default){ _ in
            confirm?()
        }
        alertController.addAction(confirmAction)
        present(alertController, animated: true)
    }
    
    func showActionSheet(title:String?,message:String?,options:[String],confirm:((Int)->Void)? = nil){
        let alerController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for i in options{
            let index = options.firstIndex(of: i)
            let action = UIAlertAction(title: i, style: .default){ _ in
                confirm?(index!)
            }
            alerController.addAction(action)
        }
        let cancelAction = UIAlertAction(title:"取消",style:.cancel)
        alerController.addAction(cancelAction)
        present(alerController, animated: true)
    }
    
}

extension MessageBoardViewController:UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection senction:Int) -> Int{
        return messageArray.count
    }

    func tableView(_ tableView:UITableView,cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier, for: indexPath) as? MessageTableViewCell else{
            
            fatalError("MessageTableViewCell Load Failed")
            
        }
        cell.messagePeopleLabel.text = "留言人：" + messageArray[indexPath.row].name
        cell.messageLabel.text = "留言內容：" + messageArray[indexPath.row].content
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->CGFloat {
        return 100
    }
    //右滑
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .destructive, title: "編輯") {action,sourceView,completionHandler in
            //bool相反的精簡寫法
            //isUpData.toggle()
            self.isUpData = true
            self.upDataIndex = indexPath.row
            self.messagePeopleTextField.text = self.messageArray[indexPath.row].name
            self.messageTextView.text = self.messageArray[indexPath.row].content
            completionHandler(true)
        }
        editAction.image = UIImage(systemName:"rays")
        editAction.backgroundColor = UIColor(red: 52/255, green: 120/255,blue: 246/255,alpha: 1)
        let configuration = UISwipeActionsConfiguration(actions:[editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    //左滑
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let renewAction = UIContextualAction(style: .destructive, title: "刪除") { action,sourceView,completionHandler in
            let realm = try! Realm()
//            let deleteMessage = realm.objects(MessageTable.self).filter({$0.createTimestamp == self.messageArray[indexPath.row].createTimestamp}).first
//            self.deleteMessage(message: deleteMessage!)
            LocalDatabase.DataDao.deleteData(message: self.messageArray[indexPath.row])
            self.fetchFromDatabase()
            completionHandler(true)
            self.deleteNotification()
        }
        renewAction.image = UIImage(systemName:"trash.square")
        renewAction.backgroundColor = UIColor(red: 246/255, green: 100/255,blue: 52/255,alpha: 1)
        let configuration = UISwipeActionsConfiguration(actions:[renewAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func createNotification(msgTitle:String?,msgbody:String?){
        let content = UNMutableNotificationContent()
        content.title = msgTitle!
//        content.subtitle = "456"
        content.body = msgbody!
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
                
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
            print("成功建立通知...")
        })
    }
    
    func deleteNotification(){
        let content = UNMutableNotificationContent()
        content.title = "刪除通知"
//        content.subtitle = "456"
        content.body = "刪除訊息"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
                
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
            print("成功建立通知...")
        })
    }
}
