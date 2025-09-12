//
//  TTCameraGuideViewController.swift
//
//
//  Created by Jay Lee on 5/30/24.
//

import UIKit
import WebKit

public class TTCameraGuideViewController: UIViewController {
    @IBOutlet weak var safeAreaDummyView: UIView!
    @IBOutlet weak var navigationContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    private var cameraType: TTCameraType?
    private var url: URL?
    private var contentsViewController: UIViewController?
    var navigationDelegate: WKNavigationDelegate?
    var uiDelegate: WKUIDelegate?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        initialized()
    }
    
    private func initialized() {
        setupView()
        configureContent()
        updateTitle()
    }
    
    private func setupView() {
        titleLabel.textColor = .ttBlack
        view.backgroundColor = .white
        safeAreaDummyView.backgroundColor = .white
        navigationContainer.backgroundColor = .white
    }
    
    private func configureContent() {
        if let url = self.url {
            setupWebViewController(url: url)
        } else if let contentsViewController = self.contentsViewController {
            setupContentViewController(contentsViewController)
        } else {
            close()
        }
    }
    
    private func setupWebViewController(url: URL) {
        let vc = TTWebViewController.instance(
            url: url,
            navigationDelegate: self.navigationDelegate ?? self,
            uiDelegate: self.uiDelegate ?? self)
        addChild(vc)
        view.addSubview(vc.view)
        setupConstraints(for: vc.view)
        vc.didMove(toParent: self)
    }
    
    private func setupContentViewController(_ vc: UIViewController) {
        addChild(vc)
        view.addSubview(vc.view)
        setupConstraints(for: vc.view)
        vc.didMove(toParent: self)
    }
    
    private func setupConstraints(for childView: UIView) {
        childView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: navigationContainer.bottomAnchor),
            childView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            childView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func updateTitle() {
        switch cameraType {
        case .eye:
            titleLabel.text = "눈 촬영 가이드".localized
        case .tooth:
            titleLabel.text = "치아 촬영 가이드".localized
        case .skin:
            titleLabel.text = "피부 촬영 가이드".localized
        case .joint:
            titleLabel.text = "관절 촬영 가이드".localized
        case nil:
            titleLabel.text = ""
        }
    }
    
    @IBAction func close(_ sender: Any? = nil) {
        if let navigationController {
            navigationController.popViewControllerWithModalDismissAnimation(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    public override var shouldAutorotate: Bool {
        return false
    }
}


extension TTCameraGuideViewController {
    static func instance(
        cameraType: TTCameraType,
        url: URL? = nil,
        navigationDelegate: WKNavigationDelegate? = nil,
        uiDelegate: WKUIDelegate? = nil
    ) -> TTCameraGuideViewController {
        guard let vc = UIStoryboard(name: "TTEtc", bundle: Bundle(for: Self.self))
            .instantiateViewController(withIdentifier: "TTCameraGuideViewController") as? TTCameraGuideViewController else {
            fatalError("Not found TTCameraGuideViewController in storyboard.")
        }
        vc.cameraType = cameraType
        vc.url = url
        vc.navigationDelegate = navigationDelegate
        vc.uiDelegate = uiDelegate
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}
extension TTCameraGuideViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Log.d.p("didStartProvisionalNavigation")
    }
    
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        Log.d.p("didReceiveServerRedirectForProvisionalNavigation")
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        Log.e.p("didFailProvisionalNavigation - [\(error.localizedDescription)]")
        Log.e.p(error)
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        Log.d.p("didCommit")
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Log.d.p("didFinish - " + (webView.url?.absoluteString ?? ""))
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        Log.e.p("didFail - [\(error.localizedDescription)]")
        Log.e.p(error)
    }
    
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        Log.d.p("webViewWebContentProcessDidTerminate")
        webView.reload()
    }
    
    @available(iOS 14.5, *)
    public func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        Log.d.p("navigationAction didBecome download")
    }
    
    @available(iOS 14.5, *)
    public func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        Log.d.p("navigationResponse didBecome download")
    }
}

extension TTCameraGuideViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        Log.d.p("createWebViewWith navigationAction")
        return nil
    }

    public func webViewDidClose(_ webView: WKWebView) {
        Log.d.p("webViewDidClose")
    }

    @available(iOS 15.0, *)
    public func webView(_ webView: WKWebView, decideMediaCapturePermissionsFor origin: WKSecurityOrigin, initiatedBy frame: WKFrameInfo, type: WKMediaCaptureType) async -> WKPermissionDecision {
        Log.d.p("decideMediaCapturePermissionsFor")
        return .prompt
    }
    
    @available(iOS 15.0, *)
    public func webView(_ webView: WKWebView, requestDeviceOrientationAndMotionPermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        Log.d.p("requestDeviceOrientationAndMotionPermissionFor")
    }
    
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, contextMenuConfigurationFor elementInfo: WKContextMenuElementInfo) async -> UIContextMenuConfiguration? {
        Log.d.p("contextMenuConfigurationFor")
        return nil
    }
    
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, contextMenuWillPresentForElement elementInfo: WKContextMenuElementInfo) {
        Log.d.p("contextMenuWillPresentForElement")
    }
    
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, contextMenuForElement elementInfo: WKContextMenuElementInfo, willCommitWithAnimator animator: any UIContextMenuInteractionCommitAnimating) {
        Log.d.p("contextMenuForElement")
    }
    
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, contextMenuDidEndForElement elementInfo: WKContextMenuElementInfo) {
        Log.d.p("contextMenuDidEndForElement")
    }
    
    @available(iOS 16.4, *)
    public func webView(_ webView: WKWebView, willPresentEditMenuWithAnimator animator: any UIEditMenuInteractionAnimating) {
        Log.d.p("willPresentEditMenuWithAnimator")
    }
    
    @available(iOS 16.4, *)
    public func webView(_ webView: WKWebView, willDismissEditMenuWithAnimator animator: any UIEditMenuInteractionAnimating) {
        Log.d.p("willDismissEditMenuWithAnimator")
    }
}
