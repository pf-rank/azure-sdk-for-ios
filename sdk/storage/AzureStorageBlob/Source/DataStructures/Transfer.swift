// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import AzureCore
import Foundation

// MARK: Classes

open class ResumableTransfer: ResumableOperation {
    // MARK: Properties

    public weak var transfer: Transfer?
    public weak var operationQueue: ResumableOperationQueue?

    internal func notifyDelegate(withTransfer transfer: Transfer) {
        switch transfer {
        case let transfer as BlockTransfer:
            if let parent = transfer.parent?.operation?.transfer {
                notifyDelegate(withTransfer: parent)
                return
            }
        case let transfer as BlobTransfer:
            if let parent = transfer.parent?.operation?.transfer {
                notifyDelegate(withTransfer: parent)
                return
            }
        default:
            break
        }
        delegate?.operation(self, didChangeState: transfer.state)
    }

    internal func notifyDelegate(withTransfer transfer: BlockTransfer) {
        // Notify the delegate of the block change AND the parent change.
        // This allows the developer to decide which events to respond to.
        delegate?.operation(self, didChangeState: transfer.state)
        if let parent = transfer.parent?.operation, let parentState = parent.transfer?.state {
            delegate?.operation(parent, didChangeState: parentState)
        }
    }
}

// MARK: Protocols

public protocol Transfer: AnyObject {
    var rawState: Int16 { get set }
    var state: TransferState { get set }
    var operation: ResumableTransfer? { get set }
    var debugString: String { get }
    var hash: Int { get }
}

public protocol TransferProgress {
    var asPercent: Int { get }
    var asFloat: Float { get }
}

// MARK: Extensions

extension Transfer {
    public var hash: Int {
        return self.hash
    }

    public var state: TransferState {
        get {
            let state = TransferState(rawValue: rawState) ?? .unknown
            return state
        }

        set {
            rawState = newValue.rawValue
        }
    }
}
