## 💡Why
---

<br>

>RxSwift를 사용해도 기존의 data source를 대체할 수 있다. 하지만 복잡한 데이터를 bind하거나 아이템을 추가/수정/삭제 할때 >animation을 수행하는경우 대체하기 어렵다.

<br>

```swift
let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Int>>(configureCell: configureCell)
Observable.just([SectionModel(model: "title", items: [1, 2, 3])])
    .bind(to: tableView.rx.items(dataSource: dataSource))
    .disposed(by: disposeBag)
```

<br>
<br>

## 💡How
---

<br>


```swift
struct CustomData {
  var anInt: Int
  var aString: String
  var aCGPoint: CGPoint
}
```

<br>

1. `SectionModelType` protocol을 따르는 struct로 section을 정의한다.

* `Item` typealias를 section에 추가될 item들의 type과 같게 정의합니다.
* items를 [Item] 형태로 선언합니다.

<br>

```swift
struct SectionOfCustomData {
  var header: String    
  var items: [Item]
}
extension SectionOfCustomData: SectionModelType {
  typealias Item = CustomData

   init(original: SectionOfCustomData, items: [Item]) {
    self = original
    self.items = items
  }
}
```

<br>

2. dataSource 객체를 생성하고 `SectionOfCustomData` type을 전달합니다.

<br>

```swift
let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData>(
  configureCell: { dataSource, tableView, indexPath, item in
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = "Item \(item.anInt): \(item.aString) - \(item.aCGPoint.x):\(item.aCGPoint.y)"
    return cell
})
```

<br>

3. 필요에따라 dataSouce의 closure들을 커스텀합니다.

<br>

```swift
dataSource.titleForHeaderInSection = { dataSource, index in
  return dataSource.sectionModels[index].header
}

dataSource.titleForFooterInSection = { dataSource, index in
  return dataSource.sectionModels[index].footer
}

dataSource.canEditRowAtIndexPath = { dataSource, indexPath in
  return true
}

dataSource.canMoveRowAtIndexPath = { dataSource, indexPath in
  return true
}
```

<br>

4. CustomData 객체들의 Observable sequence로써 실제 데이터를 정의하고 tableView에 bind한다.

```swift
let sections = [
  SectionOfCustomData(
    header: "First section",
    items: [CustomData(anInt: 0, aString: "zero",
    aCGPoint: CGPoint.zero), 
    CustomData(anInt: 1, aString: "one", aCGPoint: CGPoint(x: 1, y: 1)) ]
    ),
  SectionOfCustomData(
    header: "Second section", 
    items: [CustomData(anInt: 2, aString: "two", 
    aCGPoint: CGPoint(x: 2, y: 2)), 
    CustomData(anInt: 3, aString: "three", aCGPoint: CGPoint(x: 3, y: 3)) ]
    )
]

Observable.just(sections)
  .bind(to: tableView.rx.items(dataSource: dataSource))
  .disposed(by: disposeBag)
```

