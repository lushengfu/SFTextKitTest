//
//  SFLable.swift
//  SFTextKitTest
//
//  Created by happy on 2018/2/9.
//  Copyright © 2018年 happy. All rights reserved.
//

import UIKit

/**
 1.使用TextKit接管Label的底层实现
 2.使用正则表达式过滤URL
 3.交互
 */

class SFLable: UILabel {

    override var text: String? {
        didSet {
            prapareTextContent()
        }
    }
    
    // MARK - 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prapareTextSystem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        prapareTextSystem()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textContainer.size = bounds.size
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1. 获取用户点击的位置
        guard let location = touches.first?.location(in: self) else {
            return
        }
        
        // 2. 获取当前点中字符的索引
        let index = layoutManager.glyphIndex(for: location, in: textContainer)
        
        // 3. 判断 index 是否在 urls 的ranges 范围内, 如果在, 就高亮
        print("点我了 \(String(describing: index))")
        
        for r in urlRanges ?? [] {
            // 判断点击的索引是否在range内
            if NSLocationInRange(index, r) {
                print("需要高亮")
                
                textStorage.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.blue], range: r)
                // 重绘机制
                setNeedsDisplay()
            }
            else {
                print("没点中")
            }
        }
        
    }
    
    // 绘制文本
    /**
        - 在 iOS 中绘制工作是类似于 '油画' 似的, 后绘制的内容, 会把之前绘制的内容覆盖!
        - 尽量避免使用带透明度的颜色,会严重影响性能!
     */
    override func drawText(in rect: CGRect) {
        
        let range = NSRange(location: 0, length: textStorage.length)
        
        // 绘制背景
        layoutManager.drawBackground(forGlyphRange: range, at: CGPoint())
        // 绘制字形
        layoutManager.drawGlyphs(forGlyphRange: range, at: CGPoint())
        
//        layoutManager.drawBackground(forGlyphRange: range, at: CGPoint())
    }
    
    // MARK: - TextKit 的核心对象
    /// 属性文本存储
    private lazy var textStorage = NSTextStorage()
    /// 负责文本'字形'布局
    private lazy var layoutManager = NSLayoutManager()
    /// 设定文本绘制的范围
    private lazy var textContainer = NSTextContainer()
    
}

fileprivate extension SFLable {
    
    func prapareTextSystem() {
        
        isUserInteractionEnabled = true
        // 文本绘制内容
        prapareTextContent()
        
        // 处理核心对象的关系
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
    }
    
    // 设置textStorage的内容
    func prapareTextContent() {
        if let attributedText = attributedText {
            textStorage.setAttributedString(attributedText)
        }
        else if let text = text {
            textStorage.setAttributedString(NSAttributedString(string: text))
        }
        else {
            textStorage.setAttributedString(NSAttributedString(string: ""))
        }
        
//        print(urlRanges)
        
        for r in urlRanges ?? [] {
            textStorage.addAttributes(
                [NSAttributedStringKey.foregroundColor : UIColor.red,
                 NSAttributedStringKey.backgroundColor : UIColor.init(white: 0.9, alpha: 1.0)
                 ],
                range: r)
        }
    }
}

// MARK: 正则表达式函数
extension SFLable {
    
    var urlRanges: [NSRange]? {
        
        // 1. 正则表达式
        let pattern = "[a-zA-Z]*://[a-zA-Z0-9/\\.]*"
        
        guard let regx = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        
        // 多重匹配
        let matches = regx.matches(in: textStorage.string, options: [], range: NSRange(location: 0, length: textStorage.length))
        
        //遍历数组,生成range的数组
        var ranges = [NSRange]()
        
        for m in matches {
            ranges.append(m.range(at: 0))
        }
        
        return ranges
    }
    
}
