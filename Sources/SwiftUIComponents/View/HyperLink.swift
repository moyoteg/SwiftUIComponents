//
//  HyperLink.swift
//  SwiftUIComponents
//
//  Created by Moi Gutierrez on 5/27/22.
//

import SwiftUI

#if !os(watchOS)
struct TextLabelWithHyperLink: UIViewRepresentable {
  
  @State var tintColor: UIColor
  
  @State var hyperLinkItems: Set<HyperLinkItem>
  
  private var _attributedString: NSMutableAttributedString
  
  private var openLink: (HyperLinkItem) -> Void
  
  init (
    tintColor: UIColor,
    string: String,
    attributes: [NSAttributedString.Key : Any],
    hyperLinkItems: Set<HyperLinkItem>,
    openLink: @escaping (HyperLinkItem) -> Void
  ) {
    self.tintColor = tintColor
    self.hyperLinkItems = hyperLinkItems
    self._attributedString = NSMutableAttributedString(
      string: string,
      attributes: attributes
    )
    self.openLink = openLink
  }
  
  func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()
    textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
#if !os(tvOS)
    textView.isEditable = false      
#endif
    textView.isSelectable = true
    textView.tintColor = self.tintColor
    textView.delegate = context.coordinator
    textView.isScrollEnabled = false
    return textView
  }
  
  func updateUIView(_ uiView: UITextView, context: Context) {
   
    for item in hyperLinkItems {
      let subText = item.subText
      let link = item.subText.replacingOccurrences(of: " ", with: "_")
      
      _attributedString
        .addAttribute(
          .link,
          value: String(format: "https://%@", link),
          range: (_attributedString.string as NSString).range(of: subText)
        )
    }
    
    uiView.attributedText = _attributedString
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }
  
  class Coordinator: NSObject, UITextViewDelegate {
    var parent : TextLabelWithHyperLink
    
    init( parent: TextLabelWithHyperLink ) {
      self.parent = parent
    }
    
    func textView(
      _ textView: UITextView,
      shouldInteractWith URL: URL,
      in characterRange: NSRange,
      interaction: UITextItemInteraction
    ) -> Bool {
      
      let strPlain = URL.absoluteString
        .replacingOccurrences(of: "https://", with: "")
        .replacingOccurrences(of: "_", with: " ")
      
      if let ret = parent.hyperLinkItems.first(where: { $0.subText == strPlain }) {
        parent.openLink(ret)
      }
      
      return false
    }
  }
}

struct HyperLinkItem: Hashable {
    
  let subText : String
  let attributes : [NSAttributedString.Key : Any]?
  
  init (
    subText: String,
    attributes: [NSAttributedString.Key : Any]? = nil
  ) {
    self.subText = subText
    self.attributes = attributes
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(subText)
  }
    
  static func == (lhs: HyperLinkItem, rhs: HyperLinkItem) -> Bool {
    lhs.hashValue == rhs.hashValue
  }
}
#endif
