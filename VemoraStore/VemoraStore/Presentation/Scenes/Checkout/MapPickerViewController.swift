//
//  MapPickerViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit
import MapKit
import CoreLocation

final class MapPickerViewController: UIViewController {

    // MARK: - Public
    var onPickAddress: ((Address) -> Void)?

    // MARK: - UI
    private let mapView = MKMapView()

    private let confirmButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Подтвердить адрес", for: .normal)
        b.backgroundColor = .brightPurple
        b.tintColor = .white
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.layer.cornerRadius = 12
        b.contentEdgeInsets = .init(top: 12, left: 20, bottom: 12, right: 20)
        return b
    }()

    private let centerPin: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
        iv.tintColor = .systemRed
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let zoomInButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("+", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        b.backgroundColor = .systemGray6
        b.tintColor = .label
        b.layer.cornerRadius = 8
        return b
    }()

    private let zoomOutButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("−", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        b.backgroundColor = .systemGray6
        b.tintColor = .label
        b.layer.cornerRadius = 8
        return b
    }()

    private let locationManager = CLLocationManager()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Выбор адреса"
        view.backgroundColor = .systemBackground
        setupMap()
        setupLayout()
        setupActions()
        requestLocation()
    }
}

// MARK: - Setup
private extension MapPickerViewController {
    func setupMap() {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Центровой пин
        view.addSubview(centerPin)
        NSLayoutConstraint.activate([
            centerPin.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerPin.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerPin.widthAnchor.constraint(equalToConstant: 32),
            centerPin.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    func setupLayout() {
        // Кнопка подтверждения
        view.addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Кнопки зума в правом нижнем углу
        let zoomStack = UIStackView(arrangedSubviews: [zoomInButton, zoomOutButton])
        zoomStack.axis = .vertical
        zoomStack.spacing = 8
        zoomStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(zoomStack)
        NSLayoutConstraint.activate([
            zoomStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            zoomStack.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -16),
            zoomInButton.widthAnchor.constraint(equalToConstant: 44),
            zoomInButton.heightAnchor.constraint(equalToConstant: 44),
            zoomOutButton.widthAnchor.constraint(equalToConstant: 44),
            zoomOutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    func setupActions() {
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        zoomInButton.addTarget(self, action: #selector(zoomInTapped), for: .touchUpInside)
        zoomOutButton.addTarget(self, action: #selector(zoomOutTapped), for: .touchUpInside)
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
}

// MARK: - Actions
private extension MapPickerViewController {
    @objc func confirmTapped() {
        let center = mapView.centerCoordinate
        let address = Address(
            street: "Неизвестная улица", // ⚡️ пока заглушка
            city: "Город",
            coordinate: center
        )
        onPickAddress?(address)
        navigationController?.popViewController(animated: true)
    }

    @objc func zoomInTapped() {
        var region = mapView.region
        region.span.latitudeDelta /= 2
        region.span.longitudeDelta /= 2
        mapView.setRegion(region, animated: true)
    }

    @objc func zoomOutTapped() {
        var region = mapView.region
        region.span.latitudeDelta *= 2
        region.span.longitudeDelta *= 2
        mapView.setRegion(region, animated: true)
    }
}
