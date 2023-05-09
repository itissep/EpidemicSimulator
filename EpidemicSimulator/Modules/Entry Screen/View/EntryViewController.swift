//
//  EntryViewController.swift
//  EpidemicSimulator
//
//  Created by Someone on 08.05.2023.
//

import UIKit
import Combine

final class EntryViewController: UIViewController {
    private lazy var captureLabel = UILabel()
    private lazy var groupSizeLabel = UILabel()
    private lazy var groupSizeInput = CustomTextField()
    private lazy var infectionFactorLabel = UILabel()
    private lazy var calculationFrequencyLabel = UILabel()
    private lazy var calculationFrequencyInput = CustomTextField()
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private lazy var runButton = UIButton()
    private var bottomConstraint: NSLayoutConstraint?
    var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    private var cellSize: CGFloat?
    
    private var eventPublisher = PassthroughSubject<EntryViewEvent, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    private let viewModel: EntryViewModel
    
    // MARK: - Life Cycle
    
    init(viewModel: EntryViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generalSetup()
        setupBinding()
        setupInputPublishers()
        setupNotifications()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        runButtonSetup()
        calculationFrequencySetup()
        setupCollectionView()
        infectionFactorSetup()
        groupSizeSetup()
        captureSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barStyle = .black
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Binding
    
    private func setupBinding() {
        viewModel.attachEventListener(with: eventPublisher.eraseToAnyPublisher())
        viewModel.validationPublisher
            .sink {[weak self] areValid in
                self?.runButton.isEnabled = areValid
                self?.runButton.backgroundColor = areValid ? Styles.Color.yellow : Styles.Color.black
            }
            .store(in: &subscriptions)
    }
    
    private func setupInputPublishers() {
        calculationFrequencyInput.textPublisher()
            .sink {[weak self] text in
                self?.eventPublisher.send(.calculationFrequencyWasSet(text))
            }
            .store(in: &subscriptions)
        
        groupSizeInput.textPublisher()
            .sink {[weak self] text in
                self?.eventPublisher.send(.groupSizeWasSet(text))
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - UI Setup
    
    private func generalSetup() {
        view.backgroundColor = Styles.Color.black
    }
    
    private func captureSetup() {
        captureLabel.text = "Fancy starting a new pandemic?".lowercased()
        captureLabel.numberOfLines = 0
        captureLabel.font = Styles.inputFont
        captureLabel.textColor = Styles.Color.mustardWithAlpha
        
        view.addSubviews([captureLabel])
        NSLayoutConstraint.activate([
            captureLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            captureLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            captureLabel.bottomAnchor.constraint(equalTo: groupSizeLabel.topAnchor, constant: -(2 * Styles.padding))
        ])
    }
    
    private func groupSizeSetup() {
        view.addSubviews([groupSizeLabel, groupSizeInput])
        
        groupSizeInput.setPlaceholder("number of future victims")
        
        NSLayoutConstraint.activate([
            groupSizeInput.heightAnchor.constraint(equalToConstant: 50),
            groupSizeInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            groupSizeInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            groupSizeInput.bottomAnchor.constraint(equalTo: infectionFactorLabel.topAnchor, constant: -Styles.padding)
        ])
        
        groupSizeLabel.text = "group size"
        groupSizeLabel.font = Styles.inputFont
        groupSizeLabel.textColor = Styles.Color.yellow
        
        NSLayoutConstraint.activate([
            groupSizeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            groupSizeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            groupSizeLabel.bottomAnchor.constraint(equalTo: groupSizeInput.topAnchor, constant: -5)
        ])
    }
    
    private func infectionFactorSetup() {
        infectionFactorLabel.text = "infection factor"
        infectionFactorLabel.font = Styles.inputFont
        infectionFactorLabel.textColor = Styles.Color.yellow
        view.addSubviews([infectionFactorLabel])
        NSLayoutConstraint.activate([
            infectionFactorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            infectionFactorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            infectionFactorLabel.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -5)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FactorCollectionCell.self,
                                forCellWithReuseIdentifier: FactorCollectionCell.identifier)
        
        collectionView.backgroundColor = Styles.Color.black
        
        let heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: cellSize ?? 50)
        heightConstraint.priority = .defaultLow
        view.addSubviews([collectionView])
        NSLayoutConstraint.activate([
            heightConstraint,
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            collectionView.bottomAnchor.constraint(equalTo: calculationFrequencyLabel.topAnchor, constant: -Styles.padding)
        ])
    }
    
    private func calculationFrequencySetup() {
        view.addSubviews([calculationFrequencyLabel, calculationFrequencyInput])
        calculationFrequencyInput.setPlaceholder("potential DEADline for neighbors")
        
        NSLayoutConstraint.activate([
            calculationFrequencyInput.heightAnchor.constraint(equalToConstant: 50),
            calculationFrequencyInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            calculationFrequencyInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            calculationFrequencyInput.bottomAnchor.constraint(equalTo: runButton.topAnchor, constant:-(2 * Styles.padding))
        ])
        
        
        calculationFrequencyLabel.text = "calculation frequency (secs)"
        calculationFrequencyLabel.font = Styles.inputFont
        calculationFrequencyLabel.textColor = Styles.Color.yellow
        
        NSLayoutConstraint.activate([
            calculationFrequencyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            calculationFrequencyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            calculationFrequencyLabel.bottomAnchor.constraint(equalTo: calculationFrequencyInput.topAnchor, constant: -5)
        ])
    }
    
    private func runButtonSetup() {
        runButton.setTitle("run", for: .normal)
        runButton.setTitle("you should fill all fields", for: .disabled)
        runButton.setTitleColor(Styles.Color.black, for: .normal)
        runButton.setTitleColor(Styles.Color.mustardWithAlpha, for: .disabled)
        runButton.titleLabel?.font =  Styles.inputFont
        
        runButton.layer.cornerRadius = Styles.cornerRadius
        runButton.layer.masksToBounds = true
        runButton.addTarget(self,
                            action: #selector(runButtonPressed),
                            for: .touchUpInside)
        
        bottomConstraint = runButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Styles.padding)
        keyboardHeightLayoutConstraint = runButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Styles.padding)
        view.addSubviews([runButton])
        NSLayoutConstraint.activate([
            runButton.heightAnchor.constraint(equalToConstant: 70),
            runButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            runButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
        ])
        bottomConstraint?.isActive = true
    }
    
    // MARK: - Notifications setup
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_ :)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_ :)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func animateWithKeyboard(
        notification: Notification,
        animations: ((_ keyboardFrame: CGRect) -> Void)?
    ) {
        guard
            let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
            let curve = UIView.AnimationCurve(rawValue: curveValue)
        else {
            return
        }
        
        let animator = UIViewPropertyAnimator(
            duration: duration,
            curve: curve
        ) { [weak self] in
            animations?(keyboardFrameValue.cgRectValue)
            self?.view?.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    // MARK: - Selectors
    
    @objc
    private func keyboardWillShow(_ notification: Notification) {
        animateWithKeyboard(notification: notification) {[weak self] keyboardFrame in
            self?.view.frame.origin.y = -keyboardFrame.height
        }
    }
    
    @objc
    private func keyboardWillHide(_ notification: Notification) {
        animateWithKeyboard(notification: notification) { [weak self] _ in
            self?.view.frame.origin.y = 0
        }
    }
    
    @objc
    private func runButtonPressed() {
        eventPublisher.send(.run)
    }
}

// MARK: - UICollectionViewDelegate

extension EntryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        guard let cell = cell as? FactorCollectionCell else { return }
        cell.select()
        eventPublisher.send(.infectionFactorWasSet(indexPath.row))
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        guard let cell = cell as? FactorCollectionCell else { return }
        cell.deselect()
    }
}

// MARK: - UICollectionViewDataSource

extension EntryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FactorCollectionCell.identifier, for: indexPath)
        guard let cell = cell as? FactorCollectionCell else {
            fatalError("Error with FactorCollectionCell")
        }
        cell.setNumber(for: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension EntryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let widthPerItem = (view.frame.width - (Styles.padding * 2) - layout.minimumInteritemSpacing) / 9
        self.cellSize = widthPerItem
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
}
