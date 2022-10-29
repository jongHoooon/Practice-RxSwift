

# RxFlow Part 2: In Practice

RxFlow aims to
* navigation을 logical section들로 다듬을 수 있게해준다.
* view controller에서 navigation code를 제거할 수 있다.
* view controller의 재사용성을 권장합니다.
* 의존성 주입을 권장합니다.

<br>

terminology
* Flow: application 내부에서 Flow는 navigation 영역을 정의한다.
* Step: application에서 Step은 navigation state이다. Flow와 Step의 조합은 모든 가능한 navigation action들을 묘사합니다.
* Presentable: present될 수 있는 것들의 추상화 입니다. UIViewController and Flow는 Presentable입니다. 
* NextFlowItem: Coordinator에게 Reactive mechanism에서 새로운 Step들을 생산할 다음 일이 무엇인지 알려줍니다.
* Coordinator: 일관된 방식으로 Flow와 Step의 조합합니다.
  
<br>

RxFlow는 protocol 지향 프로그래밍을 사용해서 상속 구조에서 freeze하지 않게 하는게 중요합니다.

<br>

주로 사용되는 navigation type

* Navigation stack
* Tab bar
* Master / detail
* Modal popup

<br><br>

## 💡It's all about `States`

<br>

> RxFlow는 reactive 방법으로 navigation state 변화들을 주로 다룹니다.
> 다양한 상황에서 재사용되기 위해서 이 상태들은 사용자가 있는 현재의 navigation Flow를 인식하지 않아야 합니다. <br>
> state는 "이 화면에 가고싶어"라기 보다 `"누군가가 이 action을 했어"`라는 의미에 가깝습니다. RxFlow는 현재 navigation의 Flow에 따라 올바른 화면을 선택할 것입니다. RxFlow에서 이 navigation state를 Step이라 부릅니다.

<br>

Step은 주로 `enum`을 사용해서 표현합니다.
* enum은 사용하기 쉽습니다.
* 값은 한번만 정의될 수 있습니다. 그러므로 state는 유일합니다.
* switch문과 함께 사용하기 좋습니다.
* 화면에서 다른 화면으로 전달될 값을 품을 수 있습니다.(연관값?)
* value type임으로 shared reference가 발생하지 않습니다.

<br>

```swift
import RxFlow

enum DemoStep: Step {
    case apiKey
    case apiKeyIsComplete

    case movieList

    case moviePicked (withMovieId: Int)
    case castPicked (withCastId: Int)

    case settings
    case settingsDone
    case about
}
```

<br><br>

## 💡Go With the `Flow`

<br>

> RxFlow에서 모든 navigation code들(present, push)은 Flow에서 선언됩니다. Flow는 logical navigation section을 나타냅니다. 그리고 특정한 Step과 결합될 때 navigation action을 방출합니다.

<br>

따라서, Flow는 다음을 구현해야합니다

* navigate(to:) - Flow와 Step에 따라 navigation action을 만듭니다.
* root UIViewController - Flow에서 base가 되는 view controller

<br>

```swift
import RxFlow
import UIKit

class WatchedFlow: Flow {

    var root: UIViewController {
        return self.rootViewController
    }

    private let rootViewController = UINavigationController()
    private let service: MoviesService

    init(withService service: MoviesService) {
        self.service = service
    }

    func navigate(to step: Step) -> [NextFlowItem] {
        guard let step = step as? DemoStep else {
            return NextFlowItem.noNavigation
        }

        switch step {

        case .movieList:
            return navigateToMovieListScreen()
        case .moviePicked(let movieId):
            return navigateToMovieDetailScreen(with: movieId)
        case .castPicked(let castId):
            return navigateToCastDetailScreen(with: castId)
        default:
            return NextFlowItem.noNavigation
        }
    }

    private func navigateToMovieListScreen () -> [NextFlowItem] {
        let viewModel = WatchedViewModel(with: self.service)
        let viewController = WatchedViewController.instantiate(with: viewModel)
        viewController.title = "Watched"
        self.rootViewController.pushViewController(viewController, animated: true)
        return [NextFlowItem(nextPresentable: viewController, nextStepper: viewModel)]
    }

    private func navigateToMovieDetailScreen (with movieId: Int) -> [NextFlowItem] {
        let viewModel = MovieDetailViewModel(withService: self.service, andMovieId: movieId)
        let viewController = MovieDetailViewController.instantiate(with: viewModel)
        viewController.title = viewModel.title
        self.rootViewController.pushViewController(viewController, animated: true)
        return [NextFlowItem(nextPresentable: viewController, nextStepper: viewModel)]
    }

    private func navigateToCastDetailScreen (with castId: Int) -> [NextFlowItem] {
        let viewModel = CastDetailViewModel(withService: self.service, andCastId: castId)
        let viewController = CastDetailViewController.instantiate(with: viewModel)
        viewController.title = viewModel.name
        self.rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItem.noNavigation
    }
}
```

<br>
<br>

## 💡Navigation is a `side effect`

<br>

> Functional Reactive Programming은 `event`를 전파하고 `event`를 모든 과정에서 `function`을 적용하는데 집중합니다. <br><br>
> `function`은 event를 `transform`하고 결국 당신이 원하는 feature을 수행하는 코드를 실행합니다(필수는 아님) - networking, 파일 저장, alert표시 등 이런것을 `side effect`라고 합니다.

<br>

> RxFlow는 Reactive Programming에 의존하기 때문에, 우리는 내부 개념을 쉽게 파악할 수 있습니다.

* events: 방출된 `Step`
* function: `navigate(to:)` 함수
* transformation: navigate(to:) 함수는 `Step`을 `NextFlowItem`으로 변환합니다.
* side effect: navigatie(to:) 함수에서 수행되는 `navigation action` (push new UIViewController..)

<br><br>

## 💡Navigating consists in making `NextFlowItems`

<br>

> NextFlowItem은 `Prsentable`과 `Stepper`을 지닌 간단한 자료구조 입니다.
> <br><br>
> Presentable은 Coordinator에게 당신이 `다음에 present할 것`을 알려줍니다. Stepper은 Coordinator에게 `다음에 방출할 Step`을 알려줍니다.
> <br><br>
> 모든 UIViewController와 Flow는 Presentable 입니다. 어느 시점에서 당신은 Flow 자체에서 만들어진 완전히 새로운 navigation 영역을 시작하기 원할 것입니다. 그래서 RxFlow는 presented될 수 있다고 생각합니다. <br><br>
> Coordinator는 왜 Presentable에 대해 알아야 하나요??
> <br><br>
> Presentable은 presented될 수 있는것들의 추상화 입니다. Step은 Step의 연관된 Presentable이 표시되지 않으면 방출될 수 없기 때문에 Presentable은 Coordinator가 구독할 reactive observable을 제공합니다. (그래서 Coordinator은 Presentable의 presentation state를 알고있습니다.)
> Coordinator의 Presentable이 아직 완전히 표시되기 전에 Step이 발사될 위험이 없습니다.
> <br><br>
> Stepper은 cutom UIViewController, ViewModel, Presnte등 Coordinator에 등록되면 뭐든지 될 수 있습니다. Stepper은 자신의 `step` property를 통해 Step을 방출할 수 있습니다.(RxSwift subject). Cooedinator는 이런 Step을 듣고 Flow의 navigate(to:) 함수를 호출합니다.

<br>

```swift
import RxFlow
import RxSwift

class WatchedViewModel: Stepper {

    let movies: [MovieViewModel]

    init(with service: MoviesService) {
        // we can do some data refactoring in order to display
        // things exactly the way we want (this is the aim of a ViewModel)
        self.movies = service.watchedMovies().map({ (movie) -> MovieViewModel in
            return MovieViewModel(id: movie.id,
                                  title: movie.title,
                                  image: movie.image)
        })
    }

    public func pick (movieId: Int) {
        self.step.onNext(DemoStep.moviePicked(withMovieId: movieId))
    }
}
```

<br>

위 예제에서 pick 함수는 사용자가 list안의 movie를 선택할때 호출됩니다. 이 함수는 `self.step` Rx 흐름 안에서 새로운 값을 방출합니다.

<br>

navigation 과정을 요약해보면
* navigate(to:) 함수는 Step 변수와 함께 호출됩니다.
* Step에 따라 navigation 코드가 호출됩니다.(side effects)
* Step에 따라 NextFlowItems도 생산됩니다. 그럼으로 Presentable과 Stepper는 Coordinator안에 등록됩니다.
* Stepper은 새로운 Step을 방출하고 다시 반복합니다.

<br><br>

## 💡Why is it produce multiple NextFlowItems for a single combination of Flow and Step

<br>

>동시에 여러개의 navigation을 갖을 수 있습니다. 탭바의 각각의 item은 각각의 navigation stack으로 이어집니다.

<br>

```swift
private func navigationToDashboardScreen () -> [NextFlowItem] {
    let tabbarController = UITabBarController()
    let wishlistStepper = WishlistStepper()
    let wishListFlow = WishlistWarp(withService: self.service,
                                    andStepper: wishlistStepper)
    let watchedFlow = WatchedFlow(withService: self.service)

    Flows.whenReady(flow1: wishListFlow, flow2: watchedFlow, block: { [unowned self]
    (root1: UINavigationController, root2: UINavigationController) in
        let tabBarItem1 = UITabBarItem(title: "Wishlist",
                                       image: UIImage(named: "wishlist"),
                                       selectedImage: nil)
        let tabBarItem2 = UITabBarItem(title: "Watched",
                                       image: UIImage(named: "watched"),
                                       selectedImage: nil)
        root1.tabBarItem = tabBarItem1
        root1.title = "Wishlist"
        root2.tabBarItem = tabBarItem2
        root2.title = "Watched"

        tabbarController.setViewControllers([root1, root2], animated: false)
        self.rootViewController.pushViewController(tabbarController, animated: true)
    })

    return ([NextFlowItem(nextPresentable: wishListFlow,
                      nextStepper: wishlistStepper),
             NextFlowItem(nextPresentable: watchedFlow,
                      nextStepper: OneStepper(withSingleStep: DemoStep.movieList))])
}
```

<br>

타입함수 `Flows.whenReady()`는 이 Flow를 실행하고 이 Flow들이 표시될 준비가 됐을때 호출될 클로저를 실행합니다. (즉 이 흐름의 첫번째 screen이 선택됐을때)

<br><br>

## 💡Why is it OK to produce no NextFlowItem at all for a combination of Flow and Step?

<br>

> navigation Flow은 끝이 있어야합니다. navigation stack의 마지막은 화면은 back action 말고 더 이상의 navigation을 허락하지 않습니다. 이런 경우 navigate(to:) 함수는 `NextFlowItem(noNavigation)`을 return 합니다.

<br><br>

## 💡What happens in a Flow ... stays in a Flow!

<br>

> 동시에 여러개의 Flow를 navigate할 수 있습니다. navigation stack의 한 화면은 또다른 navigation stack을 갖는 팝업을 실행할 수 있습니다. UIKit 관점에서, UIViewController 질서는 매우 중요합니다. 그리고 우리는 Coordinator안에서 질서를 망칠 수 없습니다. <br><br>
> Flow가 현재 표시되지 않을때(예제에서, 첫번쨰 navigation stack이 popup 아래에 있을때), 방출될 Step은 Coordinator에 의해서 무시됩니다.

<br><br>

## 💡Dependency Injection made easy

<br>

>`DI(Dependency Injection)의존성 주입`은 RxFlow의 주요 목적입니다. 의존성 주입은 생성자의 변수 또는 메소드(또는 property)를 이용해서 service, maneger등 을 구현할때 넘겨줄 수 있습니다. <br><br>

RxFlow에서 개발자는 UIVewController, ViewModel, Presenter 동을 초기화할 때 주의해야 합니다. 당신이 필요한것을 주입할 휼룡한 기회입니다. 

<br>

```swift
import RxFlow
import UIKit

class WatchedFlow: Flow {

    ...
    private let service: MoviesService

    init(withService service: MoviesService) {
        self.service = service
    }
    ...
    private func navigateToMovieListScreen () -> [NextFlowItem] {
        // inject Service into ViewModel
        let viewModel = WatchedViewModel(with: self.service)

        // injecy ViewMNodel into UIViewController
        let viewController = WatchedViewController.instantiate(with: viewModel)

        viewController.title = "Watched"
        self.rootViewController.pushViewController(viewController, animated: true)
        return [NextFlowItem(nextPresentable: viewController, nextStepper: viewModel)]
    }
    ...
}
```

<br><br>

## 💡How to bootstrap a navigation process

<br>

> 당신은 thing을 함께 연결하는 방법과 navigation actiom을 발생하고 NextFlowItem을 생성하기 위해 Flow와 Step을 섞는 방법을 알있지만 한가지 남았습니다 -  application이 시작할때 navigation process를 `bootstrap`합니다.

<br>


AppDelegate에서 작성하고 매우 직관적입니다.(지금은 SceneDelegate 에서 ?)
* Coordinator를 초기화 합니다.
* navigate될 첫번째 Flow를 초기화합니다.
* Coordinator가 이 Flow와 첫번째 Step을 coordinate 하도록 요구합니다.
* 첫번째 Flow가 준비됐을때, Window의 rootViewController로써 root를 설정해줍니다

<br>

```swift
import UIKit
import RxFlow
import RxSwift
import RxCocoa

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let disposeBag = DisposeBag()
    var window: UIWindow?
    var coordinator = Coordinator()
    let movieService = MoviesService()
    lazy var mainFlow = {
        return MainFlow(with: self.movieService)
    }()

    func application(_ application: UIApplication,
                     didFinishWithOptions options: [UIApplicationLaunchOptionsKey: Any]?)
                     -> Bool {

        guard let window = self.window else { return false }

        Flows.whenReady(flow: mainFlow, block: { [unowned window] (root) in
            window.rootViewController = root
        })

        coordinator.coordinate(flow: mainFlow,
                               withStepper: OneStepper(withSingleStep: DemoStep.apiKey))

        return true
    }
}
```

<br><br>


## 💡Bonus 

<br>

>Coordinator에는 2가지 reactive extension이 있습니다: willNavigate, didNavigate. 예를 들어 당신은 AppDelegate에서 구독할 수 있습니다.

<br>

```swift
coordinator.rx.didNavigate.subscribe(onNext: { (flow, step) in
    print ("did navigate to flow=\(flow) and step=\(step)")
}).disposed(by: self.disposeBag)
```

<br>

```swift
did navigate flow=RxFlowDemo.MainFlow step=apiKeyIsComplete
did navigate flow=RxFlowDemo.WishlistFlow step=movieList
did navigate flow=RxFlowDemo.WatchedFlow step=movieList
did navigate flow=RxFlowDemo.WishlistFlow step=moviePicked(23452)
did navigate flow=RxFlowDemo.WishlistFlow step=castPicked(2)
did navigate flow=RxFlowDemo.WatchedFlow step=moviePicked(55423)
did navigate flow=RxFlowDemo.WatchedFlow step=castPicked(5)
did navigate flow=RxFlowDemo.WishlistFlow step=settings
did navigate flow=RxFlowDemo.SettingsFlow step=settings
did navigate flow=RxFlowDemo.SettingsFlow step=apiKey
did navigate flow=RxFlowDemo.SettingsFlow step=about
did navigate flow=RxFlowDemo.SettingsFlow step=apiKey
did navigate flow=RxFlowDemo.SettingsFlow step=settingsDone
```

<br>

분석과 debug에 도움이 될겁니다.

