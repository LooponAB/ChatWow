//
//  ChatBubbleView.swift
//  ChatWowDemo
//
//  Created by Bruno Resende on 26/09/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import UIKit

/// View responsible for drawing the background bubble of a chat message view.
@IBDesignable
class ChatBubbleView: UIView
{
	@IBInspectable
	var legOnLeft: Bool = false

	@IBInspectable
	var bubbleColor: UIColor = #colorLiteral(red: 0.0083760079, green: 0.4918244481, blue: 0.9989399314, alpha: 1)

	@IBInspectable
	var bubbleBorderRadius: CGFloat = 12.0

	override func draw(_ rect: CGRect)
	{
		super.draw(rect)

		//// General Declarations
		let context = UIGraphicsGetCurrentContext()!
		let width = bounds.width - 8.0
		let height = bounds.height
		let radius: CGFloat = bubbleBorderRadius

		if legOnLeft
		{
			//// Rectangle 2 Drawing
			let rectangle2Path = UIBezierPath(roundedRect: CGRect(x: 8, y: 0, width: width, height: height), cornerRadius: radius)
			bubbleColor.setFill()
			rectangle2Path.fill()


			//// Bezier 2 Drawing
			context.saveGState()
			context.translateBy(x: 0, y: height - 30.0)

			let bezier2Path = UIBezierPath()
			bezier2Path.move(to: CGPoint(x: 8, y: 14))
			bezier2Path.addLine(to: CGPoint(x: 8, y: 13.5))
			bezier2Path.addCurve(to: CGPoint(x: 0, y: 30), controlPoint1: CGPoint(x: 8, y: 13.5), controlPoint2: CGPoint(x: 9, y: 29))
			bezier2Path.addCurve(to: CGPoint(x: 15.8, y: 25.99), controlPoint1: CGPoint(x: -0, y: 30), controlPoint2: CGPoint(x: 10.87, y: 30.48))
			bezier2Path.addCurve(to: CGPoint(x: 8, y: 14), controlPoint1: CGPoint(x: 20.74, y: 19.99), controlPoint2: CGPoint(x: 8, y: 0))
			bezier2Path.close()
			bubbleColor.setFill()
			bezier2Path.fill()

			context.restoreGState()
		}
		else
		{
			//// Rectangle Drawing
			let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: width, height: height), cornerRadius: radius)
			bubbleColor.setFill()
			rectanglePath.fill()


			//// Bezier Drawing
			context.saveGState()
			context.translateBy(x: (width - 10.0 + 1.05760374554), y: height - 30.0)

			let bezierPath = UIBezierPath()
			bezierPath.move(to: CGPoint(x: 8.94, y: 14))
			bezierPath.addLine(to: CGPoint(x: 8.94, y: 13.5))
			bezierPath.addCurve(to: CGPoint(x: 16.94, y: 30), controlPoint1: CGPoint(x: 8.94, y: 13.5), controlPoint2: CGPoint(x: 7.94, y: 29))
			bezierPath.addCurve(to: CGPoint(x: 1.14, y: 25.99), controlPoint1: CGPoint(x: 16.94, y: 30), controlPoint2: CGPoint(x: 6.08, y: 30.48))
			bezierPath.addCurve(to: CGPoint(x: 8.94, y: 14), controlPoint1: CGPoint(x: -3.8, y: 19.99), controlPoint2: CGPoint(x: 8.94, y: 0))
			bezierPath.close()
			bubbleColor.setFill()
			bezierPath.fill()

			context.restoreGState()
		}
	}
}
