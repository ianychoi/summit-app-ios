//
//  GeneralScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//


import UIKit
import XLPagerTabStrip
import SwiftSpinner

class GeneralScheduleViewController: ScheduleViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var noConnectivityView: UIView!
    @IBOutlet weak var retryButton: UIButton!
    
    var presenter: IGeneralSchedulePresenter! {
        get {
            return internalPresenter as! IGeneralSchedulePresenter
        }
        set {
            internalPresenter = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewLoad()
    }
    
    override func showActivityIndicator() {
        SwiftSpinner.show("Please wait...")
    }
    
    override func hideActivityIndicator() {
        SwiftSpinner.hide()
    }
    
    @IBAction func retryButtonPressed(sender: UIButton) {
        presenter.viewLoad()
    }
    
    override func toggleEventList(show: Bool) {
        scheduleView.hidden = !show
    }
    
    override func toggleNoConnectivityMessage(show: Bool) {
        noConnectivityView.hidden = !show
    }
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Schedule")
    }
}
