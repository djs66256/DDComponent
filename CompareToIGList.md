
在我们的项目中大量使用了列表以及模块化的思想，所以才有了[`DDComponent`](https://github.com/djs66256/DDComponent)，这个的原理在之前的[美学的表现层组件化之路](http://djs66256.github.io/2017/04/09/2017-04-09-%E7%BE%8E%E5%AD%A6%E7%9A%84%E8%A1%A8%E7%8E%B0%E5%B1%82%E7%BB%84%E4%BB%B6%E5%8C%96%E4%B9%8B%E8%B7%AF/)详细的说明了使用方式。最近翻了翻`IGListKit`的代码，发现他的思想和我的思想非常的类似，但也有部分区别，这里就来分析下`IGListKit`的场景。

## 首先，来看看IGListKit的使用

IGListKit封装了`UICollectionView`的Api，下面是一个最简单的例子。

```swift
let dataSource = [1, 2, 3, 4, 5, 6]

func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
    return dataSource
}

func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
    return DisplaySectionController()
}

func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
```

虽然经过封装，但还是逃不过回调布局，我觉得这是`IGListKit`没有做好的一步。

根据官方说明，这是一个数据驱动(data drive)的组件化实现。

那么数据驱动体现在哪儿呢？

所有组件均对应于一个`viewModel`，而每个`viewModel`均对应于一个`controller`，每个`controller`实现视图，所以接口概括起来应该是

```
Model -> ViewModel -> Controller <-> View
```

所有的组件都基于`viewModel`来组装和实现。所以如果需要更新列表就必须更新`dataSource`。这样设计有它的优点，也有它的一些缺点，在之后的内容中会展开分析。

IGListKit把各种回调`dataSource`和`delegate`都细分成各个组成部分，也就是说具体数据和事件还可以再细分下去（其实经过这一层的切分，每个controller一般不会太笨重）。

## 对比DDComponent的优劣

两者的目的都是一样的，利用`UICollectionView`来布局一个内容非常多，非常长的页面，以减少复杂度。同时又将数据按照结构进行切分，分散到各个模块，然后加以重用。

`IGListKit`是一个备受关注的项目，而`DDComponent`在我们的项目中应用的非常广泛，可以说两者都具备很好的实践检验。

### 学习成本

`IGListKit`基于系统API自己又封装了一层，目的是为了拆分后的`dataSource`和`index`能够一一对应，同时又把各种回调都拆成单个属性。这样做进一步的细化了每个组件的实现。

而`DDComponent`则完全使用了系统的API，使用上仅需要关心本模块的实现就好了。和`UICollectionViewController`一样，`delegate`和`dataSource`都是自身，可以看做是Controller的拆分。由于采用系统方法，所以暴露的是`indexPath`，和一个模块内的数据源可能不是一一对应的，这需要使用者自己处理。

总的来说，`DDComponent`和系统接口相似，学习成本较低。

### 拆分粒度

`IGListKit`相当于`把臃肿的dataSource和delegate移出controller`和`把UICollectionViewController拆分为多个子controller`。所以`IGListKit`的粒度是要更细一些的。但是我们从实用程度来看看需要什么粒度。

根据我目前项目里的经验，controller中`UICollectionView`相关的功能都已经已到component中实现，目前只负责部分业务逻辑，所以一般不会超过500行。而每个component也只是负责本模块的展示与业务逻辑，也基本不会超过500行，所以从粒度来看，一次拆分已经足够了，应该能够满足绝大部分场景了。

### 结构

`IGListKit`就如以上所说的

```
Model -> ViewModel -> Controller <-> View
```

而`DDComponent`则较为简单，这里的Component对应于`IGListKit`的`Controller`+`viewModel`，这两者的功能都是类似的，相当于子controller，但两者都没有继承于`UIViewController`。

```
Model -> Component <-> View
```

所以在使用上`DDComponent`不需要必须为每个组件创建一个对应的`viewModel`，也就更为方便。

### 使用上

虽然`IGListKit`将列表拆分为组件，但是依然还是依赖于`numberOf`和`sectionControllerFor`这样的回调来映射每个viewModel，这就导致了如果一个列表有太多类型的viewModel，依然会导致回调的代码膨胀。

同时`IGListKit`仅支持到section，不支持嵌套，也就是不能在组件中再放组件，所以灵活性上来说并不如`DDComponent`。

`DDComponent`组装结构依靠的是component数组，同时并没有限定一个component所对应的section或者item的数量，所以可以支持到每个item，并且支持嵌套。所以很容易支持到下面的结构。这种组合方式可以让我们将组件进一步拆分为子组件，使每个组件唯一对应于一种view。

```
RootComponent
  |-- SectionComponent(1)
  |-- SectionComponent(2-5)
  |-- SectionComponent(6)
         |-- ItemComponent(1)
         |-- ItemComponent(2-5)
```

同时`DDComponent`的思想是组成`viewModel-component-view`的一一对应，也就是说一个component所负责展示的只有一种类型，像header, footer这种也是完全拆分开来，完全根据配置和组合来建立页面。相比会更加灵活。

### 出发点

`IGListKit`的思想来源应该是`MVVM`，核心是数据，界面按照数据来排布。

而`DDComponent`的思想来源则是传统的`MVC`，以controller为核心，通过各种形式的组合形成一个整体界面，组合是组件化的关键。

按照数据来切分(`IGListKit`)的优势在于对于数据的操作处理上会更加简单，比如增加、删除某条数据。而按照结构来切分(`DDComponent`)则在状态切换(Loading, Error...)，界面组合(Header, Footer)上更方便。

### 可扩展性

两者都可以通过传递方法回调来进行功能扩展，不仅仅是delegate，可以是任意的协议。

两者都需要自己去增加传递的代码，都会比较麻烦，这一点希望未来我能解决`DDComponent`的消息传递问题。

### 复用性

两者都是为了复用而产生的，所以双方的复用性都非常不错。不同的是`IGListKit`是强制依赖`viewModel`和`controller`两者来进行，而`DDComponent`必须的是`component`，当然也可以拆分为`viewModel-component`。

## 最后

`IGListKit`我使用的并不多，所以有些地方的观点有些偏颇，可能有办法解决他不能灵活配置的问题。但是从我的观点来说，如果你的应用中有大量相同或者相似的列表模块，同时组合方式又是比较随机，我相信你会更喜欢`DDComponent`。如果你的列表数据源经常变化，比如编辑功能，`IGListKit`会做的更好一些。

以上谈到的`DDComponent`的组件化思想，经过半年时间，以及在自己项目中的使用和积累的心得，其实真正应用的场景比最初设计的场景要少得多，接口可以再进一步的简化和改善（indexPath的问题），将来会再做一次重构。同时解决一些扩展性的问题。相信可以完全媲美并且替代`IGListKit`。