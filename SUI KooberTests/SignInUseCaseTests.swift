//
//  SignInUseCaseTests.swift
//  SignInUseCase Tests
//
//  Created by Dan on 5/11/2025.
//  Copyright © 2025 Razeware. All rights reserved.
//

import Testing
import Combine
@testable import SUI_Koober

// MARK: Mocks
class MockUserAuthenticationRemoteAPI: UserAuthenticationRemoteAPI {
  let shouldSucceed: Bool
  let userSession: UserSession
  let error: SignInError

  init(shouldSucceed: Bool = true,
       userSession: UserSession = .fake,
       error: SignInError = .unauthorized) {
      self.shouldSucceed = shouldSucceed
      self.userSession = userSession
      self.error = error
  }

  func signIn(username: String, password: String) -> Future<UserSession, SignInError> {
    return Future { promise in
      if self.shouldSucceed {
        promise(.success(self.userSession))
      } else {
          promise(.failure(self.error))
      }
    }
  }
}

class MockUserSessionStore: UserSessionStore {
  let shouldSucceed: Bool
  private(set) var wasCalled = false
  private(set) var storedSession: UserSession?

  init(shouldSucceed: Bool = true) {
    self.shouldSucceed = shouldSucceed
  }

  func getStoredAuthenticatedUserSession() -> Future<UserSession?, GetStoredAuthenticatedUserSessionError> {
    return Future { promise in
        promise(.success(nil))
    }
  }

  func store(_ authenticatedUserSession: UserSession) -> Future<UserSession, StoreAuthenticatedUserSessionError> {
    wasCalled = true
    storedSession = authenticatedUserSession

    return Future { promise in
      if self.shouldSucceed {
          promise(.success(authenticatedUserSession))
      } else {
          promise(.failure(.unknown))
      }
    }
  }
}

// MARK: SignUserCase Tests
@Suite("SignInUseCase Tests")
struct SignInUseCaseTests {
  @Test func testSignInSuccess() async throws {
    let remoteAPI = MockUserAuthenticationRemoteAPI(shouldSucceed: true)
    let userStore = MockUserSessionStore(shouldSucceed: true)
    let signInUseCase = SignInUseCase(username: "test@test.com", password: "password123", remoteAPI: remoteAPI, userSessionStore: userStore)

    let userSession = try await signInUseCase.start().firstValue()

    #expect(userSession?.user.displayName == User.fake.displayName)
    #expect(userSession?.user.fullName == User.fake.fullName)
    #expect(userSession?.user.email == User.fake.email)
    #expect(userSession?.user.phone == User.fake.phone)
    #expect(userStore.wasCalled, "Expected store to be called after successful sign in")
    #expect(userStore.storedSession == userSession, "Expected stored session to match returned session")
  }

  @Test func testSignInFailure() async throws {
    let remoteAPI = MockUserAuthenticationRemoteAPI(shouldSucceed: false, error: .unauthorized)
    let userStore = MockUserSessionStore(shouldSucceed: true)
    let signInUseCase = SignInUseCase(username: "wrong@test.com", password: "wrong", remoteAPI: remoteAPI, userSessionStore: userStore)

    let errorMessage = try await signInUseCase.start().firstError()

    #expect(errorMessage?.message == SignInError.unauthorized.errorMessage.message, "Expected unauthorized error message")
    #expect(!userStore.wasCalled, "Expected store to not be called when sign in fails")
  }

  @Test func testSignInSuccessStoreFailure() async throws {
    let remoteAPI = MockUserAuthenticationRemoteAPI(shouldSucceed: true)
    let userStore = MockUserSessionStore(shouldSucceed: false)
    let signInUseCase = SignInUseCase(username: "test@test.com", password: "password123", remoteAPI: remoteAPI, userSessionStore: userStore)

    let errorMessage = try await signInUseCase.start().firstError()

    #expect(userStore.wasCalled, "Expected store to be called after successful sign in")
    #expect(errorMessage?.message == StoreAuthenticatedUserSessionError.unknown.errorMessage.message, "Expected store error message")
  }
}


