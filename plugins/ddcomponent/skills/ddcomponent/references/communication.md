# Service 与 Notify 通信指南

## 选择：Notify vs Service

| 场景 | 用 Notify | 用 Service |
|---|---|---|
| 父 ↔ 子 Presenter 通信 | ✅ | ❌ |
| 网络请求 | ❌ | ✅ |
| 页面跳转 | ❌ | ✅ |
| 埋点上报 | ❌ | ✅ |
| 全局事件（主题切换、登录状态） | ✅ | ❌ |

核心原则：**Service 用于可替换的外部能力，Notify 用于 Presenter 间通信。**

## Notify 用法

### 子 Presenter 通知父 Presenter

```swift
// 定义监听协议
protocol LikeListener: AnyObject {
    func onLikeChanged(isLiked: Bool, count: Int)
}

// 发送方（子 Presenter）
notify(listener: LikeListener.self) {
    $0.onLikeChanged(isLiked: true, count: 10)
}

// 接收方（父 Presenter 实现协议即可）
extension MyRootPresenter: LikeListener {
    func onLikeChanged(isLiked: Bool, count: Int) {
        updateTotalLikeCount()
    }
}
```

### 父 Presenter 通知所有子 Presenter

```swift
notifyChildren(listener: ThemeListener.self) {
    $0.onThemeChanged(.dark)
}
```

### Notify 作用域

| 作用域 | 方法 | 用途 |
|---|---|---|
| `.global` | `notify(listener:scope:.global)` | 同一页面内 Presenter 间通信 |
| `.children` | `notifyChildren(listener:)` | 父 Presenter 通知子 Presenter |
| `.childrenAndSelf` | — | 通知子 Presenter 和自己 |
| `.parents` | — | 向父链传递 |
| `.reusable` | — | 列表 Cell 内通信 |

## Service 用法

### 获取 Service

```swift
getService(DataLoader.self)?.fetch { ... }
getService(RouterService.self)?.navigate(to: .profile)
```

### 注册 Service

```swift
// 方式一：pageInstallers（推荐）
@PageInstallerBuilder override var pageInstallers: PageInstaller {
    ServiceInstaller(LikeService.self, { LikeServiceImpl() })
    ServiceInstaller(DataLoader.self, lazy: false, { DataLoaderImpl() })
}

// 方式二：presenterDidLoad
override func presenterDidLoad() {
    super.presenterDidLoad()
    presenter.install {
        ServiceInstaller(LikeService.self, { LikeServiceImpl() })
    }
}

// 方式三：直接调用 register
presenter.register(service: MyService.self) { MyServiceImpl() }
```

### Service 查找链

当前 Presenter → 父 Presenter → ... → RootPresenter → 全局降级查找