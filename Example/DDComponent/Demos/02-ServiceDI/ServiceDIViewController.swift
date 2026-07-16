import UIKit
import DDComponent

final class ServiceDIViewController: PageViewController<ServiceDIView, ServiceDIRootPresenter, ServiceDIViewable> {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "02  Service & DI"
    }

    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        // lazy: DataLoaderService created on first getService() call
        ServiceInstaller(DataLoaderService.self, lazy: true) { MockDataLoaderService() }
        // eager: CounterService created immediately when presenter loads
        ServiceInstaller(CounterService.self, lazy: false) { DefaultCounterService() }
    }
}
