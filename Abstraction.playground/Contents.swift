enum TestPHAccessLevel {
  case addOnly
  case readWrite
}
enum TestPHAuthorizationStatus {
  case notDetermined
  case restricted
  case denied
  case authorized
  case limited
}

protocol CameraRollRequestable {
  func authorizationStatus(
    for accessLevel: TestPHAccessLevel
  ) -> TestPHAuthorizationStatus
  
  func requestAuthorization(
    for: TestPHAccessLevel,
    handler: (TestPHAuthorizationStatus) -> Void
  )
}

final class CameraRollFacade: CameraRollRequestable {
  func authorizationStatus(
    for accessLevel: TestPHAccessLevel
  ) -> TestPHAuthorizationStatus {
    return .authorized
  }
  
  func requestAuthorization(
    for: TestPHAccessLevel,
    handler: (TestPHAuthorizationStatus) -> Void
  ) {
    handler(authorizationStatus(for: `for`))
  }
}

final class CameraRollMock {
  private let api: CameraRollRequestable
  
  init(api: CameraRollRequestable) {
    self.api = api
  }
  
  func authorizationStatus(
    for accessLevel: TestPHAccessLevel
  ) -> TestPHAuthorizationStatus {
    api.authorizationStatus(for: accessLevel)
  }
  
  func requestAuthorization(
    for: TestPHAccessLevel,
    handler: (TestPHAuthorizationStatus) -> Void
  ) {
    api.requestAuthorization(for: `for`, handler: handler)
  }
}

import XCTest

final class CameraRollTest: XCTestCase {
  var api: CameraRollRequestable!
  var cameraRollMock: CameraRollMock!
  
  override func setUp() {
    super.setUp()
    
    api = CameraRollFacade()
    cameraRollMock = CameraRollMock(api: api)
  }
  
  func testAuthorizationStatus() {
    let status = cameraRollMock.authorizationStatus(for: .readWrite)
    XCTAssertEqual(status, .authorized)
  }
  
  func testRequestAuthorization() {
    var status: TestPHAuthorizationStatus?
    
    let expectation = self.expectation(description: "Authorization")
    
    api.requestAuthorization(for: .readWrite) {
      status = $0
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1, handler: nil)
    
    XCTAssertEqual(status, .authorized)
  }
}

