import UIKit
import DDComponent

/// Demonstrates Service DI: getService(), lazy vs eager, downgrade.
final class ServiceDIRootPresenter: RootViewPresenter<ServiceDIViewable> {

    private var loadedData: String = "" { didSet { setState {} } }
    private var counterValue: Int = 0 { didSet { setState {} } }
    private var isLoading: Bool = false { didSet { setState {} } }

    override func onBindView(_ view: ServiceDIViewable) {
        super.onBindView(view)
        view.loadButton.addTarget(self, action: #selector(onLoad), for: .touchUpInside)
        view.incrementButton.addTarget(self, action: #selector(onIncrement), for: .touchUpInside)
    }

    override func onUpdate(view: ServiceDIViewable, context: ViewUpdateContext) {
        view.dataLabel.text = loadedData.isEmpty ? "Tap Load Data" : loadedData
        view.counterLabel.text = "Counter: \(counterValue)"
        view.statusLabel.text = isLoading ? "⏳ Loading..." : "Service status: idle"
    }

    @objc private func onLoad() {
        // getService walks the tree; first call triggers lazy instantiation
        guard let loader = getService(DataLoaderService.self) else {
            print("[ServiceDI] DataLoaderService not found!")
            return
        }
        isLoading = true
        loader.loadData { [weak self] result in
            self?.setState { self?.isLoading = false; self?.loadedData = result }
        }
    }

    @objc private func onIncrement() {
        // CounterService is eager (lazy: false) — already created
        guard let counter = getService(CounterService.self) else {
            print("[ServiceDI] CounterService not found!")
            return
        }
        setState { counterValue = counter.increment() }
    }
}
