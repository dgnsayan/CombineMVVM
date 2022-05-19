//
//  combine_api_mockTests.swift
//  combine-api-mockTests
//
//  Created by Doğan Sayan on 19.05.2022.
//

import XCTest
import Combine
@testable import combine_api_mock

class combine_api_mockTests: XCTestCase {
    
    var sut:ViewModel!
    var userAPIService : MockUserAPIService!
    var viewModelOutput : MockViewModeOutput!

    override func setUp() {
        super.setUp()
        userAPIService = MockUserAPIService()
        viewModelOutput = MockViewModeOutput()
        sut = ViewModel(userAPIService: userAPIService)
        sut.output = viewModelOutput
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testUpdateText_onViewDidLoadWithSuccessAPI_isCalled(){
        //given
        let users : [User] = [
            .init(name: "Alice"),
            .init(name: "Brenda"),
            .init(name: "Charlie")
        ]
        userAPIService.fetchUsersResult = CurrentValueSubject(users).eraseToAnyPublisher()
        //when
        sut.onViewDidLoad()
        //then
        XCTAssertEqual(viewModelOutput.updateLabelArray.count, 1)
        XCTAssertEqual(viewModelOutput.updateLabelArray[0], "Alice,Brenda,Charlie")
    }
    
    func testUpdateText_onViewDidLoadWithFailedAPI_isNotCalled(){
        //given
        let error = NSError()
        userAPIService.fetchUsersResult = Fail(error: error).eraseToAnyPublisher()
        //when
        sut.onViewDidLoad()
        //then
        XCTAssertEqual(viewModelOutput.updateLabelArray.count, 1)
        XCTAssertEqual(viewModelOutput.updateLabelArray[0], "No users found")
    }
}

class MockUserAPIService:UserAPIService {
    
    var fetchUsersResult : AnyPublisher<[User], Error>?
    
    func fetchUsers() -> AnyPublisher<[User], Error> {
        if let result = fetchUsersResult {
            return result
        }else{
            fatalError("result must not be nil")
        }
    }
}

class MockViewModeOutput: ViewModelOutput {
    
    var updateLabelArray : [String] = []
    
    func updateLabel(text: String) {
        updateLabelArray.append(text)
    }
}
