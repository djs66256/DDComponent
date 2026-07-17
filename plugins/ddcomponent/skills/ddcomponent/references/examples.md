# 完整示例

以下是 DDComponent 各场景的完整、可运行示例。这些示例展示了各模式在实际代码中的组合方式。

## 示例 1：Like 功能（固定视图）

展示 View 协议、Presenter、Service、Notify 的完整配合。

**结构：**
- `LikableResourceProtocol` — 数据模型协议
- `LikeService` — Service 协议（可替换的点赞 API）
- `LikeViewProtocol` — View 协议（按钮需要展示什么）
- `LikePresenterListener` — 监听协议（对外广播点赞变化）
- `LikePresenter` — 核心业务逻辑：状态管理、toggleLike、通过 Notify 广播
- `SuperPresenter` — 父 Presenter：`add(child:)` 加入 P-Tree，`bindView` 绑定子 View

**关键模式：**
- `likeInfo` setter 通过 `setState` 更新状态
- `toggleLike()` 调用 Service → 成功后 setState + notify 广播
- `onBindView` 设回调，`onUnbindView` 清回调
- `onUpdate` 同步状态到 View

```swift
// 核心流程示意
class LikePresenter: ViewPresenter<LikeViewProtocol> {
    var resource: LikableResourceProtocol?
    struct LikeInfo { var isLiked = false; var likeCount = 0 }
    private var _likeInfo = LikeInfo()

    var likeInfo: LikeInfo {
        set { setState { _likeInfo = newValue } context: { $0.animated = false } }
        get { _likeInfo }
    }

    func toggleLike() {
        guard let resource, let service = getService(LikeService.self) else { return }
        service.toggleLike(resource: resource, ...) { [weak self] isLiked, likeCount, error in
            guard let self else { return }
            self.set(likeInfo: LikeInfo(isLiked: isLiked, likeCount: likeCount), animated: true)
            notify(listener: LikePresenterListener.self) {
                $0.onLikeInfoChanged(presenter: self, isLiked: isLiked, likeCount: likeCount)
            }
        }
    }
}
```

## 示例 2：纯逻辑 Presenter

View 类型设为 `TraceService`，Presenter 退化为纯逻辑单元。

```swift
class LifecycleTracePresenter: ViewPresenter<TraceService>, PageLifecycle {
    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
        bindView(getService(TraceService.self)!)  // View 就是 Service
    }
    func viewDidDisappear(_ animated: Bool) { view?.trace(["event": "page_disappear"]) }
}
```

## 示例 3：UITableView 列表

完整的三层架构：`CommentItemPresenter`（ReusableViewPresenter）→ `CommentSectionPresenter`（CollectionSectionPresenter）→ `CommentListRootPresenter`（CollectionRootPresenter）→ `UITablePageViewController`

## 示例 4：IsolatedViewPresenter

在传统 UIViewController 中嵌入 DDComponent 组件，手动管理 Service 注册和生命周期转发。

## 示例 5：layoutInfo 布局配置

包含 UICollectionView Item 自动/手动计算尺寸、Section 间距/列数、Header/Footer 便捷 API、UITableView estimatedHeight。

## 示例 6：Service 注册方式

三种注册方式：`pageInstallers`（推荐）、`presenterDidLoad`、`register(service:)`。

## 示例 7：Animator 动画器

内置预设（SpringAnimator/EaseAnimator）和自定义 `ViewUpdateAnimator` 实现。

## 示例 8：use* API 完整用法

涵盖 `useState` 所有变体（基本、Equatable、AnyObject、Optional、Publisher、AsyncSequence、ObservableObject、updater、keyPath）、`useEffect`、`useUpdate`、`useService`。