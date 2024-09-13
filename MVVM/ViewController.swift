//
//  ViewController.swift
//  MVVM
//
//  Created by Ulises Omar Prieto Dominguez on 30/08/24.
//

import UIKit
import Combine

final class ViewController: UIViewController {

  @IBOutlet private weak var firstCounterLabel: UILabel!
  @IBOutlet private weak var secondCounterLabel: UILabel!
  @IBOutlet private weak var thirdCounterLabel: UILabel!
  @IBOutlet private weak var fourthCounterLabel: UILabel!
  @IBOutlet private weak var fifthCounterLabel: UILabel!
  @IBOutlet private weak var sixthCounterLabel: UILabel!
  lazy var button: UIButton = UIButton()

  private var blueCounter: Int = .zero {
    didSet {
      firstCounterLabel.text = String(blueCounter)
    }
  }

  private var greenCounter: Int = .zero {
    didSet {
      secondCounterLabel.text = String(greenCounter)
    }
  }

  private var redCounter: Int = .zero {
    didSet {
      thirdCounterLabel.text = String(redCounter)
    }
  }

  private var yellowCounter: Int = .zero {
    didSet {
      fourthCounterLabel.text = String(yellowCounter)
    }
  }

  private var purpleCounter: Int = .zero {
    didSet {
      fifthCounterLabel.text = String(purpleCounter)
    }
  }

  private var indigoCounter: Int = .zero {
    didSet {
      sixthCounterLabel.text = String(indigoCounter)
    }
  }

  private let bluePublisher: Future<Int, Never> = Future() { promise in
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      promise(.success(2))
    }
  }

  private let greenPublisher: PassthroughSubject<Int, Never> = PassthroughSubject()

  private let redPublisher: CurrentValueSubject<Int, Never> = CurrentValueSubject(1)

  private let yellowPublisher: Timer.TimerPublisher = Timer.publish(every: 2.0, on: .main, in: .default)

  private let purplePublisher: NotificationCenter.Publisher = NotificationCenter.default.publisher(for: .activatePurpleCounter)

  private let indigoPublisher: URLSession.DataTaskPublisher = URLSession.shared.dataTaskPublisher(for: .juanGabrielImage)

  private var anyPublisher: AnyPublisher<Int, Never>?

  private var cancellables: Set<AnyCancellable> = []

  override func viewDidLoad() {
    super.viewDidLoad()
    addSubscribers()
    addGestures()
  }

  private func addGestures() {
    secondCounterLabel.isUserInteractionEnabled = true
    secondCounterLabel.addGestureRecognizer(
      UITapGestureRecognizer(
        target: self,
        action: #selector(didTapGreenLabel)
      )
    )
    thirdCounterLabel.isUserInteractionEnabled = true
    thirdCounterLabel.addGestureRecognizer(
      UITapGestureRecognizer(
        target: self,
        action: #selector(didTapRedLabel)
      )
    )
    fifthCounterLabel.isUserInteractionEnabled = true
    fifthCounterLabel.addGestureRecognizer(
      UITapGestureRecognizer(
        target: self,
        action: #selector(didTapPurpleLabel)
      )
    )
  }

  private func addSubscribers() {
    anyPublisher = redPublisher.eraseToAnyPublisher()

    bluePublisher
      .sink(
        receiveValue: { newValue in
          print("El nuevo valor para el contador azul es: \(newValue)")
          self.blueCounter = newValue
        }
      )
      .store(in: &cancellables)

    if let anyPublisher {
      anyPublisher
        .sink(
          receiveValue: { newValue in
            print("El nuevo valor para el contador rojo es: \(newValue)")
            self.redCounter = newValue
          }
        )
        .store(in: &cancellables)
    }

    yellowPublisher
      .autoconnect()
      .sink(
        receiveValue: { newValue in
          self.yellowCounter += 1
        }
      )
      .store(in: &cancellables)

    purplePublisher
      .sink(
        receiveValue: { notification in
          if let newValue: Int = notification.userInfo?["integerValue"] as? Int {
            self.purpleCounter = newValue
          }
        }
      )
      .store(in: &cancellables)

    indigoPublisher
      .map(\.data)
      .replaceError(with: Data())
      .receive(on: DispatchQueue.main)
      .sink(
        receiveValue: { data in
          print("Descargué de internet: \(data)")
          self.indigoCounter += 1
        }
      )
      .store(in: &cancellables)
  }

  @objc private func didTapGreenLabel() {
    let currentGreenCounterValue: Int = greenCounter
    greenPublisher.send(currentGreenCounterValue + 1)
  }

  @objc private func didTapRedLabel() {
    let currentGreenCounterValue: Int = redCounter
    redPublisher.send(currentGreenCounterValue + 1)
  }

  @objc private func didTapPurpleLabel() {
    let currentPurpleCounterValue: Int = purpleCounter
    let alert: UIAlertController = UIAlertController(title: "Hola", message: "Es un mensaje", preferredStyle: .actionSheet)
    alert.addAction(.init(title: "Ok", style: .default, handler: { _ in
      NotificationCenter.default.post(
        name: .activatePurpleCounter,
        object: nil,
        userInfo: ["integerValue": currentPurpleCounterValue + 1]
      )
    }))
    self.present(alert, animated: true)
  }

  @IBAction private func didTapResetButton(_ sender: UIButton) {
    blueCounter = 0
    greenCounter = 0
    redCounter = 0
    yellowCounter = 0
    purpleCounter = 0
    indigoCounter = 0
  }
}

private extension Notification.Name {
  static let activatePurpleCounter = Notification.Name("PurpleCounterNotification")
}

private extension URL {

  static var juanGabrielImage: URL! {
    URL(
      string: "https://lincolnliontales.com/wp-content/uploads/2016/09/juan-gabriel-seconday-art-x750d.jpeg"
    )
  }
}
