//
//  CommentInputSheetViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 01.10.2025.
//

import UIKit
import Combine

final class CommentInputSheetViewController: BaseInputSheetViewController {
    
    // MARK: - VM
    
    private let viewModel: CommentInputSheetViewModelProtocol
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Callback
    
    var onSaveComment: ((String) -> Void)?
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Sizes {
            static let customDetentHeight: CGFloat = 400
            static let textViewHeight: CGFloat = 140
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let title = "Комментарий к заказу"
        static let placeholder = "Напишите пожелания курьеру…"
        static let save = "Сохранить"
    }
    
    // MARK: - UI
    
    private lazy var commentView: FormTextView = {
        let v = FormTextView(
            title: nil,
            placeholder: Texts.placeholder,
            initial: nil
        )
        v.fixedHeight = Metrics.Sizes.textViewHeight
        return v
    }()
    
    // MARK: - Init
    
    init(viewModel: CommentInputSheetViewModelProtocol) {
        self.viewModel = viewModel
        super.init(
            config: .init(
                title: Texts.title,
                saveTitle: Texts.save,
                customDetentHeight: Metrics.Sizes.customDetentHeight,
                titleAlignment: .left
            )
        )
        modalPresentationStyle = .pageSheet
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attachContentView(commentView)
        
        setupActions()
        bindViewModel()
    }
}

// MARK: - Setup

private extension CommentInputSheetViewController {
    func setupActions() {
        onSave  = { [weak self] in self?.saveTapped() }
        onClose = { [weak self] in self?.dismiss(animated: true) }
        
        commentView.onTextChanged = { [weak self] text in
            self?.viewModel.setComment(text)
        }
    }
    
    func bindViewModel() {
        viewModel.commentPublisher
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.commentView.setText(text)
            }
            .store(in: &bag)
        
        viewModel.errorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] message in
                self?.commentView.showError(message, force: message != nil)
            }
            .store(in: &bag)
    }
    
    func saveTapped() {
        if viewModel.validate() {
            onSaveComment?(viewModel.comment.trimmingCharacters(in: .whitespacesAndNewlines))
            dismiss(animated: true)
        } else {
            commentView.shake()
        }
    }
}
