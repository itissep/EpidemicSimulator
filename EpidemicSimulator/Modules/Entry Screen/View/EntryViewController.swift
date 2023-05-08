//
//  EntryViewController.swift
//  EpidemicSimulator
//
//  Created by Someone on 08.05.2023.
//

import UIKit
#warning("TODO: add insets for input view")
#warning("TODO: input view to custom view")
#warning("TODO: scroll for keyboard")

final class EntryViewController: UIViewController {
    
    private lazy var captureLabel = UILabel()
    
    private lazy var groupSizeLabel = UILabel()
    private lazy var groupSizeInput = UITextField()
    private lazy var infectionFactorLabel = UILabel()
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    private lazy var calculationFrequencyLabel = UILabel()
    private lazy var calculationFrequencyInput = UITextField()
    
    private lazy var runButton = UIButton()
    
    private var cellSize: CGFloat?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generalSetup()
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
    
    // MARK: - UI Setup
    
    private func generalSetup() {
        view.backgroundColor = Styles.Color.black
    }
    
    private func captureSetup() {
        captureLabel.text = "Fancy starting a new pandemic?".lowercased()
        captureLabel.numberOfLines = 0
        captureLabel.font = Styles.mainFont
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
        
        groupSizeInput.placeholder = "20"
        groupSizeInput.backgroundColor = Styles.Color.mustardWithAlpha
        groupSizeInput.keyboardType = .numberPad
        groupSizeInput.layer.cornerRadius = Styles.cornerRadius
        groupSizeInput.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            groupSizeInput.heightAnchor.constraint(equalToConstant: 50),
            groupSizeInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            groupSizeInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            groupSizeInput.bottomAnchor.constraint(equalTo: infectionFactorLabel.topAnchor, constant: -Styles.padding)
        ])
        
        groupSizeLabel.text = "group size (victims)"
        groupSizeLabel.font = Styles.mainFont
        groupSizeLabel.textColor = Styles.Color.yellow
        
        NSLayoutConstraint.activate([
            groupSizeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            groupSizeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            groupSizeLabel.bottomAnchor.constraint(equalTo: groupSizeInput.topAnchor, constant: -5)
        ])
    }
    
    private func infectionFactorSetup() {
        infectionFactorLabel.text = "infection factor"
        infectionFactorLabel.font = Styles.mainFont
        infectionFactorLabel.textColor = Styles.Color.yellow
        view.addSubviews([infectionFactorLabel])
        NSLayoutConstraint.activate([
            infectionFactorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            infectionFactorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            infectionFactorLabel.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -Styles.padding)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FactorCollectionCell.self,
                                forCellWithReuseIdentifier: FactorCollectionCell.identifier)
        
        collectionView.backgroundColor = Styles.Color.black
        
        view.addSubviews([collectionView])
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(equalToConstant: cellSize ?? 100),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            collectionView.bottomAnchor.constraint(equalTo: calculationFrequencyLabel.topAnchor, constant: -Styles.padding)
        ])
    }
    
    private func calculationFrequencySetup() {
        view.addSubviews([calculationFrequencyLabel, calculationFrequencyInput])
        
        calculationFrequencyInput.placeholder = "20"
        calculationFrequencyInput.backgroundColor = Styles.Color.mustardWithAlpha
        calculationFrequencyInput.keyboardType = .numberPad
        calculationFrequencyInput.layer.cornerRadius = Styles.cornerRadius
        calculationFrequencyInput.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            calculationFrequencyInput.heightAnchor.constraint(equalToConstant: 50),
            calculationFrequencyInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            calculationFrequencyInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            calculationFrequencyInput.bottomAnchor.constraint(equalTo: runButton.topAnchor, constant:-(2 * Styles.padding))
        ])
        
        
        calculationFrequencyLabel.text = "calculation frequency (secs)"
        calculationFrequencyLabel.font = Styles.mainFont
        calculationFrequencyLabel.textColor = Styles.Color.yellow
        
        NSLayoutConstraint.activate([
            calculationFrequencyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            calculationFrequencyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            calculationFrequencyLabel.bottomAnchor.constraint(equalTo: calculationFrequencyInput.topAnchor, constant: -5)
        ])
    }
    
    private func runButtonSetup() {
        runButton.setTitle("run", for: .normal)
        runButton.backgroundColor = Styles.Color.yellow
        runButton.layer.cornerRadius = Styles.cornerRadius
        runButton.layer.masksToBounds = true
        runButton.addTarget(self,
                            action: #selector(runButtonPressed),
                            for: .touchUpInside)
        runButton.setTitleColor(Styles.Color.black, for: .normal)
        
        view.addSubviews([runButton])
        NSLayoutConstraint.activate([
            runButton.heightAnchor.constraint(equalToConstant: 70),
            runButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.padding),
            runButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styles.padding),
            runButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Styles.padding)
        ])
    }
    
    // MARK: - Selectors
    
    @objc
    private func runButtonPressed() {
        print("runButtonPressed")
    }
}

// MARK: - UICollectionViewDelegate

extension EntryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

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
