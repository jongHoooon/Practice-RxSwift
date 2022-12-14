//
//  Mastering RxSwift
//  Copyright (c) KxCoding <help@kxcoding.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import RxSwift

/*:
 # distinctUntilChanged
 */

struct Person {
    let name: String
    let age: Int
}

let disposeBag = DisposeBag()
let numbers = [1, 1, 3, 2, 2, 3, 1, 5, 5, 7, 7, 7]
let tuples = [(1, "하나"), (1, "일"), (1, "one")]
let persons = [
    Person(name: "Sam", age: 12),
    Person(name: "Paul", age: 12),
    Person(name: "Tim", age: 56)
]

Observable.from(numbers)
    .distinctUntilChanged()
    .subscribe { print($0) }
    .disposed(by: disposeBag)

//Observable.from(numbers)
//    // 값이 홀수면 같은 값으로 생각 -> 연속된 홀수 제거
//    .distinctUntilChanged { !$0.isMultiple(of: 2) && !$1.isMultiple(of: 2) }
//    .subscribe { print($0) }
//    .disposed(by: disposeBag)

// 튜플에서 특정값을 기준으로 판단 가능
Observable.from(tuples)
    .distinctUntilChanged { $0.0 }
    .subscribe { print($0) }
    .disposed(by: disposeBag)

Observable.from(tuples)
    .distinctUntilChanged { $0.1 }
    .subscribe { print($0) }
    .disposed(by: disposeBag)


// keyPath 사용

Observable.from(persons)
    .distinctUntilChanged(at: \.age)
    .subscribe { print($0) }
    .disposed(by: disposeBag)
