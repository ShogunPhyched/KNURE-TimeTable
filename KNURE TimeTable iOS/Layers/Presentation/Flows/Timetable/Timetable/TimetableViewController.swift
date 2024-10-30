//
//  TimetableViewController.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 22/12/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import UIKit
import SwiftUI

struct TimetableView: UIViewControllerRepresentable {
	func makeUIViewController(context: Context) -> TimetableViewController {
		TimetableViewController()
	}

	func updateUIViewController(_ uiViewController: TimetableViewController, context: Context) {
	}
}

protocol TimetableViewControllerOutput {
}

final class TimetableViewController: UIViewController {

	var interactor: TimetableInteractorInput?

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
