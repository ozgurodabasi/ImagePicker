import UIKit

protocol ButtonPickerDelegate: AnyObject {
    func buttonDidPress()
}

class ButtonPicker: UIButton {

  struct Dimensions {
    static let borderWidth: CGFloat = 2
    static let buttonSize: CGFloat = 58
    static let buttonBorderSize: CGFloat = 68
  }

  let userDefaults = UserDefaults.standard
  var imagePickerConfiguration = ImagePickerConfiguration()
  var mandaCount = Int(0)
  var photosTakenWithoutSavingToCameraRoll : Int = 0
    
  lazy var numberLabel: UILabel = { [unowned self] in
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = self.imagePickerConfiguration.numberLabelFont
    label.text = "" // buna bak
    return label
    }()

  weak var delegate: ButtonPickerDelegate?

  // MARK: - Initializers

  public init(configuration: ImagePickerConfiguration? = nil) {
    if let configuration = configuration {
      self.imagePickerConfiguration = configuration
    }
    super.init(frame: .zero)
    configure()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  func configure() {
    addSubview(numberLabel)

    subscribe()
    setupButton()
    setupConstraints()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func subscribe() {
    NotificationCenter.default.addObserver(self,
      selector: #selector(recalculatePhotosCount(_:)),
      name: NSNotification.Name(rawValue: ImageStack.Notifications.imageDidPush),
      object: nil)

    NotificationCenter.default.addObserver(self,
      selector: #selector(recalculatePhotosCount(_:)),
      name: NSNotification.Name(rawValue: ImageStack.Notifications.imageDidDrop),
      object: nil)

    NotificationCenter.default.addObserver(self,
      selector: #selector(recalculatePhotosCount(_:)),
      name: NSNotification.Name(rawValue: ImageStack.Notifications.stackDidReload),
      object: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  func setupButton() {
    backgroundColor = UIColor.white
    layer.cornerRadius = Dimensions.buttonSize / 2
    accessibilityLabel = "Take photo"
    addTarget(self, action: #selector(pickerButtonDidPress(_:)), for: .touchUpInside)
    addTarget(self, action: #selector(pickerButtonDidHighlight(_:)), for: .touchDown)
  }

  // MARK: - Actions

  @objc func recalculatePhotosCount(_ notification: Notification) { // buna bak
//    guard let sender = notification.object as? ImageStack else { return }
//    numberLabel.text = sender.assets.isEmpty ? "" : String(sender.assets.count)
//    if (sender.assets.count > 2){
//       // numberLabel.textColor = UIColor.green
//        backgroundColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 0.8)
//    }else{
//       // numberLabel.textColor = UIColor.red
//        backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.8022527825)
//    }
    if let sender = notification.object as? ImageStack {
        
        numberLabel.text = (sender.assets.isEmpty && photosTakenWithoutSavingToCameraRoll == 0) ? "" : String(sender.assets.count + photosTakenWithoutSavingToCameraRoll)

      }
  }

  @objc func pickerButtonDidPress(_ button: UIButton) {
    
    backgroundColor = UIColor.white
    numberLabel.textColor = UIColor.black
    numberLabel.sizeToFit()
    mandaCount = userDefaults.integer(forKey: "mandaKey")
    print("manda_count", photosTakenWithoutSavingToCameraRoll)
    if (imagePickerConfiguration.savePhotosToCameraRoll == false) {
        if (photosTakenWithoutSavingToCameraRoll <= 7){
            numberLabel.text = numberLabel.text!.isEmpty ? "1" : String(Int(numberLabel.text ?? "0")! + 1)
        }
    NotificationCenter.default.post(name: Notification.Name(rawValue: "PickerButtonDidPressNotification"), object: self, userInfo: nil)
      photosTakenWithoutSavingToCameraRoll += 1
    }
   if (photosTakenWithoutSavingToCameraRoll <= 7){
    if ((Int(numberLabel.text ?? "0")!) >= mandaCount){
       // numberLabel.textColor = UIColor.green
        backgroundColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 0.8785049229)
    }else if ((Int(numberLabel.text ?? "0")!) < mandaCount){
       // numberLabel.textColor = UIColor.red
        backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.8022527825)
    }else if (mandaCount == 0){
        backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
    }else{
                    
    }
   }
    
    delegate?.buttonDidPress()
  }

  @objc func pickerButtonDidHighlight(_ button: UIButton) {
    numberLabel.textColor = UIColor.white
    backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
  }
}
