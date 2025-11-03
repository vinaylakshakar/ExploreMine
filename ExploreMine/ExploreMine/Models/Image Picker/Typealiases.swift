//
//  Typealiases.swift
//  ARDemo
//
//  Created by Silstone on 17/09/19.
//  Copyright © 2019 Silstone. All rights reserved.
//

import Foundation

public typealias EmptyCompletion = () -> Void
public typealias CompletionObject<T> = (_ response: T) -> Void
public typealias CompletionOptionalObject<T> = (_ response: T?) -> Void
public typealias CompletionResponse = (_ response: Result<Void, Error>) -> Void

