//
//  Publisher.swift
//  SUI Koober
//
//  Created by Dan on 6/11/2025.
//  Copyright © 2025 Razeware. All rights reserved.
//

import Combine

extension Publisher {
  func firstValue() async throws -> Output? {
    var result: Output?
    for try await value in first().values {
        result = value
    }
    return result
  }

  func firstError() async throws -> Failure? {
    do {
      for try await _ in first().values {
        return nil
      }
      return nil
    } catch let error as Failure {
      return error
    }
  }
}
