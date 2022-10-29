# RxFlow Part 1: In Theory

## 💡The facts

<br>

iOS application에서 navigation 화면전환에 2가지 방법이있다.


* Builtin mechanism: storyboard and segues로 구현
* custom mechanism: 코드로 구현

<br>

2가지 방법의 단점
* Builtin mechanism: navigation은 static하고 storyboard는 거대합니다. navigation code는 UIViewControllers를 오염시킵니다. (?)
* custom mechanism: 코드는 설정하기 어려워질 수 있다. 그리고 선택하는 design pattern에 따라 복잡해질 수 있다.(Router, Coordinator)

<br><br>

## 💡The aim

<br>

* storyboard를 작게 다듬어 협력할수 있게 해주고 UIViewController들을 재사용할 수 있게해줍니다.
* navigation 맥락에 따라서 다른 방법으로 UIViewController의 present를 허락합니다.
* 의존성 주입의 실행을 쉽게해줍니다.
* UIViewController들에서  navigation 메카니즘을 제거합니다.
* reactive programing을 촉진합니다.
* navigation 경우들의 대다수를 전달하는동안에 선언적인 방법으로 navigation을 표현합니다.
* application을 navigation의 logical block들로 다듬을 수 있게합니다.

<br>
<br>

## 💡The key principles

<br>

Coordinator 패턴의 단점
* application을 만들때마다 mechanism을 작성해야합니다.
* delegation 패턴 때문에 boilerplate code가 많아질 수 있습니다.

<br>

RxFlow는 Coordinator패턴의 반응형 구현입니다.
* navigation을 더 declarative(선언적)으로 만듭니다.
* built-in Coordinator를 제공합니다.
* Coordinator들의 이슈와 의사소통을 전달하기 위해 반응형 프로그래밍을 사용합니다

<br>

RxFolow를 이해하기 위해 필요한 6가지 용어

* Flow: `Flow`는 application안에 있는 navigation area를 정의합니다. 이곳은 navigation action들을 선언하는 장소입니다.(presenting UIViewController or another Flow)
* Step: `Step`은 application에서 navigationd의 state입니다. Flow들과 Step들의 조합은 모든 가능한 navigation action들을 설명합니다. Step은 내부의 Flow 안에서 선언된 screen에 전파된 내부값(Ids, URLs, ...)을 끼워 넣을 수 있습니다.
* Presentable: presnt될 수 있는 것들의 추상화입니다. Presentable은 Coordinator가 구독할 UIkit 호환 방법으로 다루기 위해서 Coordinator가 구독할 reactive ovservable을 제공합니다.
* Flowable: Presentable과 stepper가 결합한 간단한 자료 구조입니다. Flowable은 Coordinator에게 reactive mechanism에서 새로운 Step들을 생산하는 다음 일이 무엇이 말해줍니다.
* Coordinator: Flow, navigation의 possibility를 나타내는 Step들이 정의 되면 Coordinator가 일정한 방법으로 두개를 잘 섞어서 조합합니다.