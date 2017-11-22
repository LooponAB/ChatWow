//
//  ChatBubbleView.swift
//  ChatWowDemo
//
//  Created by Bruno Resende on 26/09/2017.
//  Copyright © 2017 Loopon AB
//  Contact us at support@loopon.com
//  
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 
//  following conditions are met:
//  
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following
//  disclaimer.
//  
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the 
//  following disclaimer in the documentation and/or other materials provided with the distribution.
//  
//  3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote
//  products derived from this software without specific prior written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
//  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
//  USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import UIKit

/// View responsible for drawing the background bubble of a chat message view.
@IBDesignable
class ChatBubbleView: UIView
{
	@IBInspectable
	var legOnLeft: Bool = false

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
			tintColor.setFill()
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
			tintColor.setFill()
			bezier2Path.fill()

			context.restoreGState()
		}
		else
		{
			//// Rectangle Drawing
			let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: width, height: height), cornerRadius: radius)
			tintColor.setFill()
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
			tintColor.setFill()
			bezierPath.fill()

			context.restoreGState()
		}
	}
}
