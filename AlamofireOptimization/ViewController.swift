import UIKit
import Alamofire

class ViewController: UIViewController {
    
    private let sliderData: [SliderItem] = [
        SliderItem(color: .systemMint, title: "Оптимизаци Alamofire", text: "UImageView+Alamofire и Alamofire+Gzip", animationName: "Cat"),
        SliderItem(color: .systemOrange, title: "Загрузка и отображение изображений в UIImageView", text: "'af_setImage'", animationName: "Image"),
        SliderItem(color: .systemBrown, title: "Демонстрация", text: "'af_setImage'", animationName: "no"),
        SliderItem(color: .gray, title: "Отправка HTTP-запросов с сжатием данных Gzip.", text: "'requestGzipped'", animationName: "Package"),
        SliderItem(color: .black, title: "Сравнение скорости обработки запросов.", text: "'requestGzipped'", animationName: "Time"),
    ]
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.isPagingEnabled = true
        
        return collection
    }()
    
    lazy var hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 0
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 5
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    private let shape = CAShapeLayer()
    private var curentPageIndex: CGFloat = 0
    private var fromValue: CGFloat = 0
    
    lazy var skipBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Пропустить", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(moveToLast), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var nextBtn: UIView = {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nextSlide))
        let nextImg = UIImageView()
        nextImg.image = UIImage(systemName: "chevron.right.circle.fill")
        nextImg.tintColor = .white
        nextImg.contentMode = .scaleAspectFit
        nextImg.translatesAutoresizingMaskIntoConstraints = false
        nextImg.widthAnchor.constraint(equalToConstant: 45).isActive = true
        
        nextImg.widthAnchor.constraint(equalToConstant: 45).isActive = true
        nextImg.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        let btn = UIView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.isUserInteractionEnabled = true
        btn.addGestureRecognizer(tapGesture)
        btn.addSubview(nextImg)
        
        nextImg.centerXAnchor.constraint(equalTo: btn.centerXAnchor).isActive = true
        nextImg.centerYAnchor.constraint(equalTo: btn.centerYAnchor).isActive = true
        return btn
    }()
    
    private var pagers: [UIView] = []
    private var curentSlide = 0
    private var widthAnhor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollection()
        setShape()
        setControll()
    }
    
    private func setShape() {
        
        curentPageIndex = CGFloat(1) / CGFloat(sliderData.count)
        
        let nextStroke = UIBezierPath(arcCenter: CGPoint(x: 25, y: 25), radius: 23, startAngle: -(.pi/2), endAngle: 5, clockwise: true)
        
        let trackShape = CAShapeLayer()
        trackShape.path = nextStroke.cgPath
        trackShape.fillColor = UIColor.clear.cgColor
        trackShape.lineWidth = 3
        trackShape.strokeColor = UIColor.white.cgColor
        trackShape.opacity = 0.1
        nextBtn.layer.addSublayer(trackShape)
        
        shape.path = nextStroke.cgPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.white.cgColor
        shape.lineWidth = 3
        shape.lineCap = .round
        shape.strokeStart = 0
        shape.strokeEnd = 0
        
        nextBtn.layer.addSublayer(shape)
    }
    
    private func setControll() {
        
        view.addSubview(hStack)
        
        let pagerStack = UIStackView()
        pagerStack.axis = .horizontal
        pagerStack.spacing = 5
        pagerStack.alignment = .center
        pagerStack.distribution = .fill
        pagerStack.translatesAutoresizingMaskIntoConstraints = false
        
        for tag in 1...sliderData.count {
            let pager = UIView()
            pager.tag = tag
            
            pager.translatesAutoresizingMaskIntoConstraints = false
            pager.backgroundColor = .white
            pager.layer.cornerRadius = 5
            pager.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scrollToSlide(sender: ))))
            self.pagers.append(pager)
            pagerStack.addArrangedSubview(pager)
        }
        
        vStack.addArrangedSubview(pagerStack)
        vStack.addArrangedSubview(skipBtn)
        hStack.addArrangedSubview(vStack)
        hStack.addArrangedSubview(nextBtn)
        
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            hStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])
    }

    private func setupCollection() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    let url = "https://eojhre9wbydsbgl.m.pipedream.net"
    let parameters: Parameters = ["id": 1, "Title": "title", "body": "Body"]
    
    private func testGzip() {
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                    case .success(let value):
                    print("Успешно отправлено: \(value)")
                    if let httpResponse = response.response {
                        print("Статусный код: \(httpResponse.statusCode)")
                    }
                    case .failure(let error):
                        print("Ошибка отправки запроса: \(error)")
                    }
            }

        AF.requestGzipped(url, method: .post, parameters: parameters)
            .responseJSON { response in
                switch response.result {
                    case .success(let value):
                    print("Успешно отправлено: \(value)")
                    if let httpResponse = response.response {
                        print("Статусный код: \(httpResponse.statusCode)")
                    }
                    case .failure(let error):
                    print("Ошибка отправки запроса: \(error)")
                }
            }
    }
    
    @objc func nextSlide() {
        let maxSlide = sliderData.count
        
        if curentSlide < maxSlide-1 {
            curentSlide += 1
            collectionView.scrollToItem(at: IndexPath(item: curentSlide, section: 0), at: .centeredHorizontally, animated: true)
        }
        
        //testGzip()
    }
    
    @objc func moveToLast() {
        collectionView.scrollToItem(at: IndexPath(item: sliderData.count - 1, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    @objc func scrollToSlide(sender: UIGestureRecognizer) {
        if let index = sender.view?.tag {
            collectionView.scrollToItem(at: IndexPath(item: index-1, section: 0), at: .centeredHorizontally, animated: true)
            curentSlide = index - 1
        }
    }

}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sliderData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionViewCell {
            
            cell.contentView.backgroundColor = sliderData[indexPath.item].color
            cell.titleLabel.text = sliderData[indexPath.item].title
            cell.textLabel.text = sliderData[indexPath.item].text
            if sliderData[indexPath.item].animationName == "no" {
                cell.imageSetup()
            } else {
                cell.animationSetup(animationName: sliderData[indexPath.item].animationName)
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        curentSlide = indexPath.item
        
        pagers.forEach { page in
            let tag = page.tag
            let viewTag = indexPath.row + 1
            page.constraints.forEach { conts in
                page.removeConstraint(conts)
            }
            if viewTag == tag {
                page.layer.opacity = 1
                widthAnhor = page.widthAnchor.constraint(equalToConstant: 20)
            } else {
                page.layer.opacity = 0.5
                widthAnhor = page.widthAnchor.constraint(equalToConstant: 10)
            }
            widthAnhor?.isActive = true
            page.heightAnchor.constraint(equalToConstant: 10).isActive = true
        }
        
        let curentIndex = curentPageIndex * CGFloat(indexPath.item + 1)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = fromValue
        animation.toValue = curentIndex
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.duration = 0.5
        shape.add(animation, forKey: "animation")
        
        fromValue = curentIndex
    }
}
