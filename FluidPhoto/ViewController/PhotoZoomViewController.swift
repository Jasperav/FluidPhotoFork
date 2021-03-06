import UIKit
import JVConstraintEdges

class ImageViewConstraints: UIImageView {
    
    private (set) var topConstraint: NSLayoutConstraint!
    private (set) var bottomConstraint: NSLayoutConstraint!
    private (set) var leadingConstraint: NSLayoutConstraint!
    private (set) var trailingConstraint: NSLayoutConstraint!
    
    init(image: UIImage) {
        super.init(image: image)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fill(to: UIView) {
        addAsSubview(to: to)
        
        topConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: to, attribute: .top, multiplier: 1, constant: 0)
        bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: to, attribute: .bottom, multiplier: 1, constant: 0)
        leadingConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: to, attribute: .leading, multiplier: 1, constant: 0)
        trailingConstraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: to, attribute: .trailing, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }
}

open class PhotoZoomViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate, ZoomAnimatorDelegate {
    private enum Mode {
        case focus, unfocused
        
        static let transitionDuration: TimeInterval = 0.25
    }
    
    private let transitionController: ZoomTransitionController
    var firstTimeLoaded = true
    
    private var correctedZoomScale: CGFloat = 1.0
    private var mode = Mode.unfocused
    private let scrollView = UIScrollView()
    private let imageView: ImageViewConstraints
    private var doubleTapGestureRecognizer: UITapGestureRecognizer!
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var singleTapGestureRecognizer: UITapGestureRecognizer!
    
    init(image: UIImage, originalImageIsRounded: Bool, presenter: ZoomAnimatorDelegate & UIViewController) {
        imageView = ImageViewConstraints(image: image)
        transitionController = ZoomTransitionController(originalImageIsRounded: originalImageIsRounded)
        
        super.init(nibName: nil, bundle: nil)
        
        assert(presenter.navigationController!.delegate == nil)
        
        presenter.navigationController!.delegate = transitionController
        transitionController.fromDelegate = presenter
        transitionController.toDelegate = self
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanWith(gestureRecognizer:)))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
        
        singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didSingleTapWith(gestureRecognizer:)))
        view.addGestureRecognizer(singleTapGestureRecognizer)
        
        scrollView.fill(toSuperview: view)
        imageView.fill(to: scrollView)
        
        view.backgroundColor = .white
        
        scrollView.maximumZoomScale = 4
        
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapWith(gestureRecognizer:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
         singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        
        scrollView.delegate = self
        imageView.frame = CGRect(x: imageView.frame.origin.x,
                                 y: imageView.frame.origin.y,
                                 width: image.size.width,
                                 height: image.size.height)
        view.addGestureRecognizer(doubleTapGestureRecognizer)
        
        scrollView.contentInsetAdjustmentBehavior = .never
        
        imageView.setContentHugging(251)
        
        //Update the constraints to prevent the constraints from
        //being calculated incorrectly on certain iOS devices
        updateConstraintsForSize(view.frame.size)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == scrollView.panGestureRecognizer {
            if scrollView.contentOffset.y == 0 {
                return true
            }
        }
        
        return false
    }
    
    @objc func didSingleTapWith(gestureRecognizer: UITapGestureRecognizer) {
        switch mode {
        case .focus:
            change(mode: .unfocused)
        case .unfocused:
            change(mode: .focus)
        }
    }
    
    @objc func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            scrollView.isScrollEnabled = false
            transitionController.isInteractive = true
            let _ = navigationController!.popViewController(animated: true)
        default:
            transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func change(mode: Mode) {
        guard self.mode != mode else { return }
        
        self.mode = mode
        
        let hidden: Bool
        let backgroundColor: UIColor
        
        switch mode {
        case .focus:
            hidden = true
            backgroundColor = .black
        case .unfocused:
            hidden = false
            backgroundColor = .white
        }
        
        navigationController!.setNavigationBarHidden(hidden, animated: true)
        
        UIView.animate(withDuration: Mode.transitionDuration, animations: {
            self.view.backgroundColor = backgroundColor
        })
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateZoomScaleForSize(view.bounds.size)
    }
    
    @objc func didDoubleTapWith(gestureRecognizer: UITapGestureRecognizer) {
        let pointInView = gestureRecognizer.location(in: imageView)
        var newZoomScale = scrollView.maximumZoomScale
        
        if scrollView.zoomScale >= newZoomScale || abs(scrollView.zoomScale - newZoomScale) <= 0.01 {
            newZoomScale = scrollView.minimumZoomScale
        }
        
        let width = scrollView.bounds.width / newZoomScale
        let height = scrollView.bounds.height / newZoomScale
        let originX = pointInView.x - (width / 2.0)
        let originY = pointInView.y - (height / 2.0)
        
        let rectToZoomTo = CGRect(x: originX, y: originY, width: width, height: height)
        
        scrollView.zoom(to: rectToZoomTo, animated: true)
    }
    
    private func updateZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        correctedZoomScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = correctedZoomScale
        
        //scrollView.zoomScale is only updated once when
        //the view first loads and each time the device is rotated
        if firstTimeLoaded {
            scrollView.zoomScale = correctedZoomScale
            firstTimeLoaded = false
        }
        
        scrollView.maximumZoomScale = correctedZoomScale * 4
    }
    
    private func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        let contentHeight = yOffset * 2 + imageView.frame.height
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        
        imageView.topConstraint.constant = yOffset
        imageView.bottomConstraint.constant = yOffset
        imageView.leadingConstraint.constant = xOffset
        imageView.trailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
        
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width,
                                        height: contentHeight)
    }
}

public extension PhotoZoomViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.zoomScale != scrollView.minimumZoomScale {
            change(mode: .focus)
        }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print(scale)
        if scale > correctedZoomScale + 0.01 {
            change(mode: .focus)
            
            return
        }
        
        change(mode: .unfocused)
    }
}

public extension PhotoZoomViewController {
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        return imageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        return scrollView.convert(imageView.frame, to: view)
    }
}
