//
//  AsyncOperation.swift
//  App
//
//  Created by r.gladkikh on 01.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

/// Represents an asynchronous operation.
/// - Important: Do not use this operation directly. Inherit your own operation from this class.
open class AsyncOperation: Operation {
    public enum State: String {
        case ready, executing, finished
        
        fileprivate var keyPath: String { "is" + rawValue.capitalized }
    }
    
    public var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
    
    public override init() {
        state = .ready
        super.init()
    }
}

extension AsyncOperation {
    open override var isReady: Bool { super.isReady && state == .ready }
    open override var isExecuting: Bool { state == .executing }
    open override var isFinished: Bool { state == .finished }
    open override var isAsynchronous: Bool { true }
    
    open override func start() {
        if isCancelled {
            state = .finished
            return
        }
        
        main()
        state = .executing
    }
    
    open override func cancel() {
        super.cancel()
        state = .finished
    }
}
