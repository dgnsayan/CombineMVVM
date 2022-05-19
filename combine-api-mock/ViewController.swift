//
//  ViewController.swift
//  combine-api-mock
//
//  Created by Doğan Sayan on 19.05.2022.
//

import UIKit
import Combine

//3.1
//after get datas from service to update with it to UI
//delegate
protocol ViewModelOutput:AnyObject {
    func updateLabel(text:String)
}

class ViewModel {
    
    //3.1
    weak var output : ViewModelOutput?
    
    //3
    //after get datas from service to update with it to UI
    //closure
    //var userDidComplete: ((String) -> Void)?
    
    //2
    //Dependency Injection
    //  we are doing these way because we able to mock that in unittest
    private let userAPIService : UserAPIService
    
    private var subscribers = Set<AnyCancellable>()
    
    init(userAPIService : UserAPIService) {
        self.userAPIService = userAPIService
    }
    //2User
    
    func onViewDidLoad(){
        displayUsers()
    }
    
    //1
    //UserAPIService().fetchUsers().sink
    //dont use UserAPIService() directly.
    //  this is a concrete class for SOLID principle
    //      we want to use abstract class
    //          so we will manage that with protocol
    private func displayUsers(){
        userAPIService.fetchUsers().sink { completion in
            switch completion{
            case .failure:
                let text = "No users found"
                self.output?.updateLabel(text: text)
            case .finished: break
            }
        } receiveValue: { [weak self] users in
            let text = users.map({$0.name}).joined(separator: ",")
            //3.1
            self?.output?.updateLabel(text: text)
            //3
            //self?.userDidComplete?(text)
        }.store(in: &subscribers)
    }
    

}

class ViewController: UIViewController,ViewModelOutput {
    
    @IBOutlet weak var nameLabel : UILabel!
    
    private let viewModel : ViewModel = ViewModel(userAPIService: UserAPIServiceImp())
    
    private var subscribers = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onViewDidLoad()
        //3.1
        viewModel.output = self
        //3
        //observe()
    }
    
    /* 3
    private func observe(){
        viewModel.userDidComplete = { [weak self] text in
            self?.nameLabel.text = text
        }
    }*/
    
    //3.1
    // MARK: ViewModelOutput
    func updateLabel(text: String) {
        nameLabel.text = text
    }
    

}

protocol UserAPIService{
    func fetchUsers() -> AnyPublisher<[User],Error>
}

class UserAPIServiceImp:UserAPIService {
    func fetchUsers() -> AnyPublisher<[User],Error> {
        let urlString = "https://jsonplaceholder.typicode.com/users"
        let url = URL(string: urlString)!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map({$0.data})
            .decode(type: [User].self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

struct User:Decodable {
    let name : String
}
