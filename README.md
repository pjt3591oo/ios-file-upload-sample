#  file upload sample

* tableView

* URLSession

* Photo

[목업서버](https://github.com/pjt3591oo/mockup-server-express)

### 적용 아키텍처

MVVM(Model View View Model) 패턴

### 고민 포인트

extension에서 deletegate와 datasource를 채택한 후 해당 extension은 어느 레이어에서 관리를 해야하나...

ViewController를 폴더로 만들고 ViewController, 각 datasource, deletegate를 채택한 extension을 별도의 파일로 관리를 하는게 좋은건가? -> 일단은 하나의 파일에서 관리
