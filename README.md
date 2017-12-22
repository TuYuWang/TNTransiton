# TNTransiton
transition between the two viewController

## PreView

![image](https://github.com/TuYuWang/TNTransiton/blob/master/showTime.gif)

## Usage

~~~
//fromViewController
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    tn_setup()
}

//magic
@IBAction func JumpToDetailByMagic(_ sender: UITapGestureRecognizer) {
    let type = TNTransitionType.magic(reverse: false)
    tn_transition(by: type, from: fromView, to: "toView")
    navigationController?.pushViewController(DetailViewController(), animated: true)
}

//circle
@IBAction func JumpToDetailByCircle(_ sender: UITapGestureRecognizer) {
    let type = TNTransitionType.circle(reverse: false)
    tn_transition(by: type, from: circleFromView)
    navigationController?.pushViewController(DetailViewController(), animated: true)
}

//page
@IBAction func JumpToDetailByPage(_ sender: Any) {
    let type = TNTransitionType.page(reverse: false)
    tn_transition(by: type)
    navigationController?.pushViewController(DetailViewController(), animated: true)
}

//toViewController
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    tn_setup()
    tn_transition(by: .magic(reverse: true))
}
~~~
