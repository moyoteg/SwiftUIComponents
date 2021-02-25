//
//  PageView.swift
//  SwiftUIComponents
//
//  Created by Moi Gutierrez on 2/25/21.
//

import SwiftUI
import UIKit

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Utilities

public struct PageView<Page: View>: UIViewControllerRepresentable {
    
    var pageCount: Int
    @Binding var currentPage: Int
    var transitionStyle: UIPageViewController.TransitionStyle
    var navigationOrientation: UIPageViewController.NavigationOrientation
    var content: (Int) -> Page

    public init(pageCount: Int,
                currentPage: Binding<Int>,
                transitionStyle: UIPageViewController.TransitionStyle = .scroll,
                navigationOrientation: UIPageViewController.NavigationOrientation = .horizontal,
                @ViewBuilder content: @escaping (_ index: Int) -> Page) {
        self.pageCount = pageCount
        self._currentPage = currentPage
        self.transitionStyle = transitionStyle
        self.navigationOrientation = navigationOrientation
        self.content = content
    }
    
    public func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(transitionStyle: transitionStyle, navigationOrientation: navigationOrientation, options: nil)
        
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator

        return pageViewController
    }
    
    public func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        var direction: UIPageViewController.NavigationDirection = .forward
        var animated: Bool = false
        
        if let previousViewController = pageViewController.viewControllers?.first,
            let previousPage = context.coordinator.controllers.firstIndex(of: previousViewController) {
            direction = (currentPage >= previousPage) ? .forward : .reverse
            animated = (currentPage != previousPage)
        }
        
        let currentViewController = context.coordinator.controllers[currentPage]
        pageViewController.setViewControllers([currentViewController], direction: direction, animated: animated)
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self, pageCount: pageCount, content: content)
    }
    
    public class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        
        var parent: PageView
        var controllers: [UIViewController] = []

        init(parent: PageView,
             pageCount: Int,
             @ViewBuilder content: @escaping (_ index: Int) -> Page) {
            self.parent = parent
            for currentPage in 0..<pageCount {
                let hostingController = UIHostingController(rootView: content(currentPage))
                hostingController.view.backgroundColor = .clear
                self.controllers.append(hostingController)
            }
        }
        
        public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index == 0 {
                return nil
            }
            return controllers[safe: index - 1]
        }
        
        public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index + 1 == controllers.count {
                return nil
            }
            return controllers[safe: index + 1]
        }
        
        public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed,
                let currentViewController = pageViewController.viewControllers?.first,
                let currentIndex = controllers.firstIndex(of: currentViewController)
            {
                parent.currentPage = currentIndex
            }
        }
    }
}

#endif
