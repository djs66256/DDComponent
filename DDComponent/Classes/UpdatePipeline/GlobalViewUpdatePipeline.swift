//
//  GlobalViewUpdatePipeline.swift
//  DDComponent
//
//  Created by daniel on 2024/1/5.
//

import Foundation

public protocol ViewUpdatePipelineQueue {
    func async(_ closure: @escaping @MainActor () -> Void)
}

struct ViewUpdatePipelineDispatchQueue: ViewUpdatePipelineQueue {
    func async(_ closure: @escaping @MainActor () -> Void) {
        DispatchQueue.main.async(execute: closure)
    }
}

//class ViewUpdatePipelineWhenEmptyQueue: ViewUpdatePipelineQueue {
//    
//    init() {
//    }
//    
//    var closures: [() -> Void] = []
//    func async(_ closure: @escaping @MainActor () -> Void) {
//        closures.append(closure)
//    }
//}

@MainActor
public class GlobalViewUpdatePipeline {
    public static let shared = GlobalViewUpdatePipeline()
    
    public var queue: ViewUpdatePipelineQueue = ViewUpdatePipelineDispatchQueue()
    
    private struct PipelineWrapper: Hashable {
        let value: ViewUpdatePipeline
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.value === rhs.value
        }
        
        var hashValue: Int {
            ObjectIdentifier(value).hashValue
        }
        
        func hash(into hasher: inout Hasher) {
            ObjectIdentifier(value).hash(into: &hasher)
        }
    }
    
    private var pipelines = Set<PipelineWrapper>()
    public private(set) var isDirty = false
    
    func markDirty(_ pipeline: ViewUpdatePipeline) {
        pipelines.insert(PipelineWrapper(value: pipeline))
        
        if !isDirty {
            isDirty = true
            queue.async {
                guard self.isDirty else { return }
                
                self.updateView(synchronize: false)
                self.isDirty = false
            }
        }
    }
    
    public func updateView(synchronize: Bool) {
        Logger.log("<GlobalViewUpdatePipeline> begin update view, synchronize: \(synchronize)")
        var pipelines = pipelines
        self.pipelines = Set<PipelineWrapper>()
        while !pipelines.isEmpty {
            for wrapper in pipelines {
                let pipeline = wrapper.value
                pipeline.updateViewIfNeeded(synchronize: synchronize)
            }
            
            pipelines = self.pipelines
            self.pipelines = Set<PipelineWrapper>()
        }
        Logger.log("<GlobalViewUpdatePipeline> end update view, synchronize: \(synchronize)")
    }
    
    func updateView(for pipeline: ViewUpdatePipeline, synchronize: Bool) {
        Logger.log("<GlobalViewUpdatePipeline> begin update view for \(pipeline), synchronize: \(synchronize)")
        if let wrapper = pipelines.remove(PipelineWrapper(value: pipeline)) {
            wrapper.value.updateViewIfNeeded(synchronize: synchronize)
        }
        Logger.log("<GlobalViewUpdatePipeline> end update view for \(pipeline), synchronize: \(synchronize)")
    }
}
