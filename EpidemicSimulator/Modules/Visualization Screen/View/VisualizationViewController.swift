//
//  VisualizationViewController.swift
//  EpidemicSimulator
//
//  Created by Someone on 08.05.2023.
//

import UIKit
import Combine

final class VisualizationViewController: UIViewController {
    
    private lazy var groupSizeLabel = UILabel()
    private lazy var sickPopulationLabel = UILabel()
    private lazy var infectionFactorLabel = UILabel()
    private lazy var calculationFrequencyLabel = UILabel()
    
    private lazy var progressLabel = UILabel()
    
    private lazy var healthyLabel = UILabel()
    private lazy var sickLabel = UILabel()
    
    private lazy var titleLabel = UILabel()
    
    private lazy var plusButton = UIButton()
    private lazy var minusButton = UIButton()
    
    private lazy var pauseButton = UIButton()
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        
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
        setupPauseButton()
        
        setupInfoLabels()
        setupZoomButtons()
        setupProgressLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        eventPublisher.send(.delete)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barStyle = .default
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
        
        viewModel.$isRunning
            .sink {[weak self] isRunning in
                self?.configurePauseButton(isRunning)
            }
            .store(in: &subscriptions)
        
        viewModel.$isFinished
            .sink { [weak self] isOn in
                self?.pauseButton.isEnabled = !isOn
            }
            .store(in: &subscriptions)
        
        viewModel.$parameters
            .sink {[weak self] data in
                self?.configureInfoLabels(data)
            }
            .store(in: &subscriptions)
        
        viewModel.$progress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.configureProgress(with: progress)
            }
            .store(in: &subscriptions)
    }
    
    private func configureInfoLabels(_ data: (group: Int, factor: Int, interval: Int)?) {
        guard let data else {
            return }
        groupSizeLabel.text = "\(data.group)"
        infectionFactorLabel.text = "\(data.factor) neighbors"
        calculationFrequencyLabel.text = "per \(data.interval)sec"
    }
    
    // MARK: - UI Setup
    
    private func generalSetup() {
        view.backgroundColor = Styles.Color.yellow
    }
    
    private func setupInfoLabels() {
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
    
    private func setupProgressLabel() {
        progressLabel.textColor = Styles.Color.black
        progressLabel.font = Styles.titleFont
        
        view.addSubviews([progressLabel])
        NSLayoutConstraint.activate([
            progressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            progressLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor),
        ])
    }
    
    private func configureProgress(with progress: CGFloat) {
        progressLabel.isHidden = progress == 0.0
        let value = Int(progress * 100)
        progressLabel.text = "\(value)%"
    }
    
    private func setupTitle() {
        titleLabel.text = "simulation"
        titleLabel.textColor = Styles.Color.black
        titleLabel.font = Styles.titleFont
        
        view.addSubviews([titleLabel])
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            titleLabel.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -Styles.padding)
        ])
    }
    
    private func setupPauseButton() {
        pauseButton.addTarget(self, action: #selector(pauseWasPressed), for: .touchUpInside)
        
        view.addSubviews([pauseButton])
        NSLayoutConstraint.activate([
            pauseButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            pauseButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            pauseButton.heightAnchor.constraint(equalToConstant: 40),
            pauseButton.widthAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    private func configurePauseButton(_ isRunning: Bool) {
        let config = UIImage.SymbolConfiguration(
            pointSize: 40, weight: .medium, scale: .default)
        let imageName = isRunning ? "pause.fill" : "play.fill"
        pauseButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
    }
    
    private func setupZoomButtons() {
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        plusButton.setImage(UIImage(systemName: "plus",
                                    withConfiguration: config),
                            for: .normal)
        minusButton.setImage(UIImage(systemName: "minus",
                                     withConfiguration: config),
                             for: .normal)
        
        plusButton.addTarget(self, action: #selector(plusWasPressed), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(minusWasPressed), for: .touchUpInside)
        
        view.addSubviews([plusButton, minusButton])
        
        NSLayoutConstraint.activate([
            minusButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            plusButton.trailingAnchor.constraint(equalTo: minusButton.leadingAnchor, constant: -10),
            
            plusButton.heightAnchor.constraint(equalToConstant: 35),
            plusButton.widthAnchor.constraint(equalToConstant: 40),
            minusButton.heightAnchor.constraint(equalToConstant: 35),
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
    private func pauseWasPressed() {
        eventPublisher.send(.pause)
    }
    
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
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension VisualizationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: Styles.padding, bottom: 2, right: Styles.padding)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let marginsAndInsets = 2 * 2 + collectionView.safeAreaInsets.top + collectionView.safeAreaInsets.bottom + 2 * CGFloat(itemsPerLine - 1)
        let itemWidth = ((collectionView.bounds.size.height - marginsAndInsets) / CGFloat(itemsPerLine)).rounded(.down)
        return CGSize(width: itemWidth, height: itemWidth)
    }
}
