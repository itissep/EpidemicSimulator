//
//  VisualizationViewController.swift
//  EpidemicSimulator
//
//  Created by Someone on 08.05.2023.
//

import UIKit
import Combine
#warning("TODO: stop button")
#warning("FIXIT: cornerRadius configuration for cells")
#warning("TODO: play and pause button")

final class VisualizationViewController: UIViewController {
    private lazy var groupSizeLabel = UILabel()
    private lazy var infectionFactorLabel = UILabel()
    private lazy var calculationFrequencyLabel = UILabel()
    
    private lazy var healthyLabel = UILabel()
    private lazy var sickLabel = UILabel()
    
    private lazy var titleLabel = UILabel()
    
    private lazy var plusButton = UIButton()
    private lazy var minusButton = UIButton()
    
    private lazy var stopButton = UIButton()
    private lazy var pauseButton = UIButton()
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    private var itemsPerLine: CGFloat = 16
    
    private var eventPublisher = PassthroughSubject<VisualizationViewEvent, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    private let viewModel: VisualizationViewModel
    
    // MARK: - Life Cycle
    
    init(viewModel: VisualizationViewModel){
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupCollectionView()
        setupTitle()
        
        setupInfoLabels()
        setupZoomButtons()
    }
    
    // MARK: - Binding
    
    private func setupBinding() {
        viewModel.attachEventListener(with: eventPublisher.eraseToAnyPublisher())
        viewModel.$cellModels
            .sink {[weak self] models in
                self?.collectionView.reloadData()
            }
            .store(in: &subscriptions)
        
        viewModel.$itemsPerLine
            .sink { [weak self] number in
                self?.itemsPerLine = number
                self?.collectionView.performBatchUpdates({
                    self?.collectionView.reloadData()
                }, completion: nil)
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - UI Setup
    
    private func generalSetup() {
        view.backgroundColor = Styles.Color.yellow
    }
    
    private func setupInfoLabels() {
        groupSizeLabel.text = "100"
        infectionFactorLabel.text = "4 neighbors"
        calculationFrequencyLabel.text = "per 10sec"
        
        groupSizeLabel.textColor = Styles.Color.black
        groupSizeLabel.font = Styles.titleFont
        groupSizeLabel.textAlignment = .right
        
        infectionFactorLabel.textColor = Styles.Color.mustard
        infectionFactorLabel.font = Styles.titleFont
        infectionFactorLabel.textAlignment = .right
        
        calculationFrequencyLabel.textColor = Styles.Color.mustard
        calculationFrequencyLabel.font = Styles.titleFont
        calculationFrequencyLabel.textAlignment = .right
        
        view.addSubviews([groupSizeLabel, infectionFactorLabel, calculationFrequencyLabel])
        NSLayoutConstraint.activate([
            groupSizeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            groupSizeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            groupSizeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Styles.padding),
            
            infectionFactorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            infectionFactorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            infectionFactorLabel.topAnchor.constraint(equalTo: groupSizeLabel.bottomAnchor),
            
            calculationFrequencyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            calculationFrequencyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            calculationFrequencyLabel.topAnchor.constraint(equalTo: infectionFactorLabel.bottomAnchor)
        ])
    }
    
    private func setupTitle() {
        titleLabel.text = "your playground"
        titleLabel.textColor = Styles.Color.black
        titleLabel.font = Styles.titleFont
        
        view.addSubviews([titleLabel])
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Styles.padding),
            titleLabel.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -Styles.padding)
        ])
    }
    
    private func setupZoomButtons() {
        let config = UIImage.SymbolConfiguration(
            pointSize: 40, weight: .medium, scale: .default)
        plusButton.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: config), for: .normal)
        minusButton.setImage(UIImage(systemName: "minus.circle.fill", withConfiguration: config), for: .normal)
        
        plusButton.addTarget(self, action: #selector(plusWasPressed), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(minusWasPressed), for: .touchUpInside)
        
        view.addSubviews([plusButton, minusButton])
        
        NSLayoutConstraint.activate([
            minusButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            plusButton.trailingAnchor.constraint(equalTo: minusButton.leadingAnchor, constant: -10),
            
            plusButton.heightAnchor.constraint(equalToConstant: 40),
            plusButton.widthAnchor.constraint(equalToConstant: 40),
            minusButton.heightAnchor.constraint(equalToConstant: 40),
            minusButton.widthAnchor.constraint(equalToConstant: 40),
            
            plusButton.topAnchor.constraint(equalTo: calculationFrequencyLabel.bottomAnchor, constant: Styles.padding),
            minusButton.topAnchor.constraint(equalTo: calculationFrequencyLabel.bottomAnchor, constant: Styles.padding),
            
            titleLabel.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -Styles.padding)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(VictimCollectionCell.self,
                                forCellWithReuseIdentifier: VictimCollectionCell.identifier)
        collectionView.allowsMultipleSelection = true
        
        collectionView.backgroundColor = Styles.Color.yellow
        
        view.addSubviews([collectionView])
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.45),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Styles.padding)
        ])
    }
    
    // MARK: - Selectors
    
    @objc
    private func plusWasPressed() {
        eventPublisher.send(.plusPressed)
    }
    
    @objc
    private func minusWasPressed() {
        eventPublisher.send(.minusPressed)
    }
}


// MARK: - UICollectionViewDelegate

extension VisualizationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        eventPublisher.send(.wasSelectedAt(indexPath))
    }
}

// MARK: - UICollectionViewDataSource

extension VisualizationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.cellModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VictimCollectionCell.identifier, for: indexPath)
        guard let cell = cell as? VictimCollectionCell else {
            fatalError("Error with CollectionCell")
        }
        cell.configure(with: viewModel.cellModels[indexPath.row].isSick)
        cell.configureAppearance(with: 20)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension VisualizationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: Styles.padding, bottom: 0, right: Styles.padding)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = (collectionView.frame.width) / CGFloat(itemsPerLine)
        return CGSize(width: side - 5, height: side - 5)
    }
}
