# TNTransiton
transition between the two viewController

## PreView

![image](https://github.com/TuYuWang/TNTransiton/blob/master/showTime.gif)

## Usage

~~~
//fromViewController
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    tn.setup()
}

//magic
@IBAction func JumpToDetailByMagic(_ sender: UITapGestureRecognizer) {
    tn.transition(by: .magic(reverse: false), from: fromView, to: "toView")
    navigationController?.pushViewController(DetailViewController(), animated: true)
}

//circle
@IBAction func JumpToDetailByCircle(_ sender: UITapGestureRecognizer) {
    tn.transition(by: .circle(reverse: false), from: circleFromView)
    navigationController?.pushViewController(DetailViewController(), animated: true)
}

//page
@IBAction func JumpToDetailByPage(_ sender: Any) {
    tn.transition(by: .page(reverse: false))
    navigationController?.pushViewController(DetailViewController(), animated: true)
}

//toViewController
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    tn.setup()
    tn.transition(by: .magic(reverse: true))
}
~~~
