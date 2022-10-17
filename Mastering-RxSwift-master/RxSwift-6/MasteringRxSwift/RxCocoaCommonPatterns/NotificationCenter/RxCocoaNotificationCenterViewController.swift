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
import RxCocoa

class RxCocoaNotificationCenterViewController: UIViewController {
    
    let bag = DisposeBag()
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var toggleButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toggleButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                if self.textView.isFirstResponder {
                    self.textView.resignFirstResponder()
                } else {
                    self.textView.becomeFirstResponder()
                }
            })
            .disposed(by: bag)
        
        let willShowObservable =
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .map { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0}
            
        let willHideObservable =
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .map { noti -> CGFloat in 0 }
        
        Observable.merge(willShowObservable, willHideObservable)
            .map { [unowned self] height -> UIEdgeInsets in
                var inset = self.textView.contentInset
                inset.bottom = height
                return inset
            }
            .subscribe(onNext: { [weak self] inset in
                UIView.animate(withDuration: 0.3) {
                    self?.textView.contentInset = inset
                }
            })
            .disposed(by: bag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        }
    }
}
